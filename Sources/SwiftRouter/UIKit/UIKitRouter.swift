// UIKitRouter.swift
// SwiftRouter
//
// Created by Muhittin Camdali
// Copyright © 2026 Muhittin Camdali. All rights reserved.

#if canImport(UIKit) && !os(watchOS)
import UIKit
import Combine

// MARK: - View Controller Factory

/// A protocol for creating view controllers from routes.
///
/// Implement ``ViewControllerFactory`` to map your routes to UIKit
/// view controllers.
@MainActor
public protocol ViewControllerFactory: AnyObject {

    /// Creates a view controller for the given route.
    ///
    /// - Parameter route: The route to create a view controller for.
    /// - Returns: A configured view controller, or `nil` if this factory doesn't handle the route.
    func viewController(for route: any Route) -> UIViewController?
}

// MARK: - UIKit Router

/// A UIKit adapter for the ``Router`` that manages `UINavigationController` based navigation.
///
/// ``UIKitRouter`` bridges SwiftRouter's navigation model with UIKit's
/// `UINavigationController`, providing push, pop, present, and dismiss
/// operations backed by the router's middleware and stack management.
///
/// ## Usage
///
/// ```swift
/// let navController = UINavigationController()
/// let router = Router(configuration: .default)
/// let uiKitRouter = UIKitRouter(router: router, navigationController: navController)
/// uiKitRouter.factory = myFactory
///
/// try await uiKitRouter.navigate(to: ProfileRoute(userId: "42"))
/// ```
@MainActor
public final class UIKitRouter: NSObject {

    // MARK: - Properties

    /// The underlying SwiftRouter instance.
    public let router: Router

    /// The root navigation controller.
    public let navigationController: UINavigationController

    /// The view controller factory.
    public weak var factory: (any ViewControllerFactory)?

    /// Whether transitions should be animated by default.
    public var defaultAnimated: Bool = true

    /// The currently presented view controller (if any modal is showing).
    public private(set) var presentedViewController: UIViewController?

    /// Custom transition delegates keyed by transition style identifier.
    public var customTransitions: [String: UIViewControllerAnimatedTransitioning] = [:]

    private var cancellables = Set<AnyCancellable>()
    private var viewControllerMap: [UUID: UIViewController] = [:]

    // MARK: - Initialization

    /// Creates a UIKit router.
    ///
    /// - Parameters:
    ///   - router: The SwiftRouter instance.
    ///   - navigationController: The root navigation controller.
    public init(
        router: Router,
        navigationController: UINavigationController
    ) {
        self.router = router
        self.navigationController = navigationController
        super.init()
        setupObservers()
        navigationController.delegate = self
    }

    // MARK: - Navigation

    /// Navigates to a route using UIKit.
    ///
    /// - Parameters:
    ///   - route: The target route.
    ///   - action: The navigation action. Defaults to `.push`.
    ///   - animated: Whether to animate. Defaults to `defaultAnimated`.
    /// - Throws: ``RouterError`` if navigation fails.
    public func navigate(
        to route: any Route,
        action: NavigationAction = .push,
        animated: Bool? = nil
    ) async throws {
        let shouldAnimate = animated ?? defaultAnimated

        // Use the router for middleware and stack management
        try await router.navigate(to: route, action: action, animated: shouldAnimate)

        // Perform UIKit navigation
        switch action {
        case .push:
            try performPush(route: route, animated: shouldAnimate)
        case .present(let style):
            try performPresent(route: route, style: style, animated: shouldAnimate)
        case .pop:
            performPop(animated: shouldAnimate)
        case .popToRoot:
            performPopToRoot(animated: shouldAnimate)
        case .dismiss:
            performDismiss(animated: shouldAnimate)
        case .replace:
            try performReplace(route: route, animated: shouldAnimate)
        case .deepLink:
            break // Handled by the router
        }
    }

    /// Pushes a view controller for the given route.
    ///
    /// - Parameters:
    ///   - route: The route.
    ///   - animated: Whether to animate.
    /// - Throws: ``RouterError`` if no factory or the factory returns nil.
    public func performPush(route: any Route, animated: Bool) throws {
        guard let viewController = createViewController(for: route) else {
            throw RouterError.routeNotFound(type(of: route).pattern)
        }

        if let entry = router.navigationStack.entries.last {
            viewControllerMap[entry.id] = viewController
        }

        navigationController.pushViewController(viewController, animated: animated)
    }

    /// Presents a view controller modally.
    ///
    /// - Parameters:
    ///   - route: The route.
    ///   - style: The presentation style.
    ///   - animated: Whether to animate.
    /// - Throws: ``RouterError`` if no factory or the factory returns nil.
    public func performPresent(
        route: any Route,
        style: TransitionStyle,
        animated: Bool
    ) throws {
        guard let viewController = createViewController(for: route) else {
            throw RouterError.routeNotFound(type(of: route).pattern)
        }

        configureModalPresentation(viewController, style: style)

        if let entry = router.navigationStack.modalEntries.last {
            viewControllerMap[entry.id] = viewController
        }

        let presenter = navigationController.presentedViewController ?? navigationController
        presenter.present(viewController, animated: animated)
        presentedViewController = viewController
    }

    /// Pops the top view controller.
    ///
    /// - Parameter animated: Whether to animate.
    public func performPop(animated: Bool) {
        navigationController.popViewController(animated: animated)
    }

    /// Pops to the root view controller.
    ///
    /// - Parameter animated: Whether to animate.
    public func performPopToRoot(animated: Bool) {
        navigationController.popToRootViewController(animated: animated)
    }

    /// Dismisses the presented view controller.
    ///
    /// - Parameter animated: Whether to animate.
    public func performDismiss(animated: Bool) {
        if let presented = navigationController.presentedViewController {
            presented.dismiss(animated: animated) { [weak self] in
                self?.presentedViewController = nil
            }
        }
    }

    /// Replaces the top view controller.
    ///
    /// - Parameters:
    ///   - route: The replacement route.
    ///   - animated: Whether to animate.
    /// - Throws: ``RouterError`` if the factory returns nil.
    public func performReplace(route: any Route, animated: Bool) throws {
        guard let viewController = createViewController(for: route) else {
            throw RouterError.routeNotFound(type(of: route).pattern)
        }

        var viewControllers = navigationController.viewControllers
        if !viewControllers.isEmpty {
            viewControllers[viewControllers.count - 1] = viewController
        } else {
            viewControllers.append(viewController)
        }

        navigationController.setViewControllers(viewControllers, animated: animated)
    }

    // MARK: - Deep Link

    /// Handles a deep link URL through UIKit navigation.
    ///
    /// - Parameter url: The deep link URL.
    /// - Throws: ``RouterError`` if the URL cannot be resolved.
    public func handleDeepLink(_ url: URL) async throws {
        try await router.handleDeepLink(url)

        // Sync UIKit state with router stack
        syncNavigationState()
    }

    // MARK: - Private

    private func createViewController(for route: any Route) -> UIViewController? {
        factory?.viewController(for: route)
    }

    private func configureModalPresentation(
        _ viewController: UIViewController,
        style: TransitionStyle
    ) {
        switch style {
        case .sheet:
            viewController.modalPresentationStyle = .pageSheet
        case .fullScreenCover:
            viewController.modalPresentationStyle = .fullScreen
        case .fade:
            viewController.modalPresentationStyle = .overFullScreen
            viewController.modalTransitionStyle = .crossDissolve
        case .custom(let identifier):
            viewController.modalPresentationStyle = .custom
            if let transition = customTransitions[identifier] {
                viewController.transitioningDelegate = TransitioningDelegateAdapter(transition: transition)
            }
        default:
            viewController.modalPresentationStyle = .automatic
        }
    }

    private func setupObservers() {
        router.navigationStack.stackChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handleStackChange(event)
            }
            .store(in: &cancellables)
    }

    private func handleStackChange(_ event: StackChangeEvent) {
        switch event {
        case .cleared:
            navigationController.setViewControllers([], animated: false)
            presentedViewController?.dismiss(animated: false)
            presentedViewController = nil
            viewControllerMap.removeAll()
        default:
            break
        }
    }

    private func syncNavigationState() {
        // Rebuild the UIKit navigation stack from the router stack
        var viewControllers: [UIViewController] = []
        for entry in router.navigationStack.entries {
            if let vc = viewControllerMap[entry.id] ?? createViewController(for: entry.route) {
                viewControllers.append(vc)
                viewControllerMap[entry.id] = vc
            }
        }
        navigationController.setViewControllers(viewControllers, animated: true)
    }
}

// MARK: - UINavigationControllerDelegate

extension UIKitRouter: UINavigationControllerDelegate {

    public func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        // Clean up view controller map for popped entries
        let currentVCs = Set(navigationController.viewControllers.map { ObjectIdentifier($0) })
        viewControllerMap = viewControllerMap.filter { _, vc in
            currentVCs.contains(ObjectIdentifier(vc))
        }
    }
}

// MARK: - Transitioning Delegate Adapter

/// An adapter that wraps a `UIViewControllerAnimatedTransitioning` for use as
/// a transitioning delegate.
private final class TransitioningDelegateAdapter: NSObject, UIViewControllerTransitioningDelegate {

    let transition: UIViewControllerAnimatedTransitioning

    init(transition: UIViewControllerAnimatedTransitioning) {
        self.transition = transition
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        transition
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        transition
    }
}
#endif
