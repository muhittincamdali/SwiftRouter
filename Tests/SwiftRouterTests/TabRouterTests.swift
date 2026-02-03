//
//  TabRouterTests.swift
//  SwiftRouterTests
//
//  Created by Muhittin Camdali on 2025.
//

import XCTest
@testable import SwiftRouter

final class TabRouterTests: XCTestCase {
    
    // MARK: - Properties
    
    var tabRouter: TabRouter!
    var testTabs: [TabItem]!
    
    // MARK: - Setup & Teardown
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        testTabs = [
            TabItem(id: "home", title: "Home", systemImage: "house", routeIdentifier: "/home", order: 0),
            TabItem(id: "search", title: "Search", systemImage: "magnifyingglass", routeIdentifier: "/search", order: 1),
            TabItem(id: "profile", title: "Profile", systemImage: "person", routeIdentifier: "/profile", order: 2),
            TabItem(id: "settings", title: "Settings", systemImage: "gear", routeIdentifier: "/settings", order: 3)
        ]
        
        tabRouter = TabRouter(tabs: testTabs, initialTabId: "home")
    }
    
    @MainActor
    override func tearDown() {
        tabRouter = nil
        testTabs = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    @MainActor
    func testTabRouterInitialization() {
        XCTAssertNotNil(tabRouter)
        XCTAssertEqual(tabRouter.tabs.count, 4)
        XCTAssertEqual(tabRouter.selectedTabId, "home")
    }
    
    @MainActor
    func testTabRouterWithCustomInitialTab() {
        let router = TabRouter(tabs: testTabs, initialTabId: "search")
        XCTAssertEqual(router.selectedTabId, "search")
    }
    
    @MainActor
    func testTabRouterDefaultsToFirstTab() {
        let router = TabRouter(tabs: testTabs)
        XCTAssertEqual(router.selectedTabId, "home")
    }
    
    // MARK: - Tab Selection Tests
    
    @MainActor
    func testSelectTab() throws {
        try tabRouter.selectTab("search")
        XCTAssertEqual(tabRouter.selectedTabId, "search")
    }
    
    @MainActor
    func testSelectTabNotFound() {
        XCTAssertThrowsError(try tabRouter.selectTab("nonexistent")) { error in
            guard case TabRouterError.tabNotFound = error else {
                XCTFail("Expected tabNotFound error")
                return
            }
        }
    }
    
    @MainActor
    func testSelectDisabledTab() {
        tabRouter.setTabEnabled(false, for: "search")
        
        XCTAssertThrowsError(try tabRouter.selectTab("search")) { error in
            guard case TabRouterError.tabDisabled = error else {
                XCTFail("Expected tabDisabled error")
                return
            }
        }
    }
    
    @MainActor
    func testSelectHiddenTab() {
        tabRouter.setTabVisibility(false, for: "search")
        
        XCTAssertThrowsError(try tabRouter.selectTab("search")) { error in
            guard case TabRouterError.tabHidden = error else {
                XCTFail("Expected tabHidden error")
                return
            }
        }
    }
    
    @MainActor
    func testSelectNextTab() throws {
        XCTAssertEqual(tabRouter.selectedTabId, "home")
        
        let changed = tabRouter.selectNextTab()
        
        XCTAssertTrue(changed)
        XCTAssertEqual(tabRouter.selectedTabId, "search")
    }
    
    @MainActor
    func testSelectPreviousTab() throws {
        try tabRouter.selectTab("search")
        
        let changed = tabRouter.selectPreviousTab()
        
        XCTAssertTrue(changed)
        XCTAssertEqual(tabRouter.selectedTabId, "home")
    }
    
    @MainActor
    func testSelectNextTabWrapsAround() throws {
        try tabRouter.selectTab("settings")
        
        let changed = tabRouter.selectNextTab()
        
        XCTAssertTrue(changed)
        XCTAssertEqual(tabRouter.selectedTabId, "home")
    }
    
    // MARK: - Tab Visibility Tests
    
    @MainActor
    func testVisibleTabs() {
        XCTAssertEqual(tabRouter.visibleTabs.count, 4)
    }
    
    @MainActor
    func testSetTabVisibility() {
        tabRouter.setTabVisibility(false, for: "settings")
        
        XCTAssertEqual(tabRouter.visibleTabs.count, 3)
        XCTAssertFalse(tabRouter.visibleTabs.contains { $0.id == "settings" })
    }
    
    @MainActor
    func testHidingCurrentTabSelectsAnother() throws {
        try tabRouter.selectTab("settings")
        XCTAssertEqual(tabRouter.selectedTabId, "settings")
        
        tabRouter.setTabVisibility(false, for: "settings")
        
        XCTAssertNotEqual(tabRouter.selectedTabId, "settings")
    }
    
    // MARK: - Tab Enabled Tests
    
    @MainActor
    func testEnabledTabs() {
        XCTAssertEqual(tabRouter.enabledTabs.count, 4)
    }
    
    @MainActor
    func testSetTabEnabled() {
        tabRouter.setTabEnabled(false, for: "profile")
        
        let enabledIds = tabRouter.enabledTabs.map { $0.id }
        XCTAssertFalse(enabledIds.contains("profile"))
    }
    
    @MainActor
    func testDisablingCurrentTabSelectsAnother() throws {
        try tabRouter.selectTab("profile")
        XCTAssertEqual(tabRouter.selectedTabId, "profile")
        
        tabRouter.setTabEnabled(false, for: "profile")
        
        XCTAssertNotEqual(tabRouter.selectedTabId, "profile")
    }
    
    // MARK: - Badge Tests
    
    @MainActor
    func testUpdateBadge() {
        let badge = TabBadge.count(5)
        tabRouter.updateBadge(badge, for: "home")
        
        let homeTab = tabRouter.tabs.first { $0.id == "home" }
        XCTAssertNotNil(homeTab?.badge)
        XCTAssertEqual(homeTab?.badge?.stringValue, "5")
    }
    
    @MainActor
    func testIncrementBadge() {
        tabRouter.incrementBadge(for: "home", by: 3)
        
        let homeTab = tabRouter.tabs.first { $0.id == "home" }
        XCTAssertEqual(homeTab?.badge?.stringValue, "3")
        
        tabRouter.incrementBadge(for: "home", by: 2)
        
        let updatedTab = tabRouter.tabs.first { $0.id == "home" }
        XCTAssertEqual(updatedTab?.badge?.stringValue, "5")
    }
    
    @MainActor
    func testClearBadge() {
        tabRouter.updateBadge(.count(10), for: "home")
        XCTAssertNotNil(tabRouter.tabs.first { $0.id == "home" }?.badge)
        
        tabRouter.clearBadge(for: "home")
        XCTAssertNil(tabRouter.tabs.first { $0.id == "home" }?.badge)
    }
    
    @MainActor
    func testClearAllBadges() {
        tabRouter.updateBadge(.count(5), for: "home")
        tabRouter.updateBadge(.dot(), for: "search")
        tabRouter.updateBadge(.text("New"), for: "profile")
        
        tabRouter.clearAllBadges()
        
        for tab in tabRouter.tabs {
            XCTAssertNil(tab.badge)
        }
    }
    
    @MainActor
    func testBadgeStringValue() {
        XCTAssertEqual(TabBadge.count(5).stringValue, "5")
        XCTAssertEqual(TabBadge.count(100).stringValue, "99+")
        XCTAssertEqual(TabBadge.text("New").stringValue, "New")
        XCTAssertEqual(TabBadge.dot().stringValue, "●")
    }
    
    // MARK: - Navigation Stack Tests
    
    @MainActor
    func testGetNavigationStack() {
        let stack = tabRouter.getNavigationStack(for: "home")
        XCTAssertEqual(stack.count, 1)
        XCTAssertEqual(stack.first, "/home")
    }
    
    @MainActor
    func testPushRoute() {
        tabRouter.pushRoute("/home/detail", to: "home")
        
        let stack = tabRouter.getNavigationStack(for: "home")
        XCTAssertEqual(stack.count, 2)
        XCTAssertEqual(stack.last, "/home/detail")
    }
    
    @MainActor
    func testPopRoute() {
        tabRouter.pushRoute("/home/detail", to: "home")
        tabRouter.pushRoute("/home/detail/edit", to: "home")
        
        let popped = tabRouter.popRoute(from: "home")
        
        XCTAssertEqual(popped, "/home/detail/edit")
        XCTAssertEqual(tabRouter.getNavigationStack(for: "home").count, 2)
    }
    
    @MainActor
    func testPopRouteAtRoot() {
        let popped = tabRouter.popRoute(from: "home")
        XCTAssertNil(popped)
    }
    
    @MainActor
    func testPopToRoot() {
        tabRouter.pushRoute("/home/a", to: "home")
        tabRouter.pushRoute("/home/b", to: "home")
        tabRouter.pushRoute("/home/c", to: "home")
        
        XCTAssertEqual(tabRouter.getNavigationStack(for: "home").count, 4)
        
        tabRouter.popToRoot(for: "home")
        
        XCTAssertEqual(tabRouter.getNavigationStack(for: "home").count, 1)
    }
    
    @MainActor
    func testPopToRootAll() {
        tabRouter.pushRoute("/home/detail", to: "home")
        tabRouter.pushRoute("/search/results", to: "search")
        tabRouter.pushRoute("/profile/edit", to: "profile")
        
        tabRouter.popToRootAll()
        
        for tab in testTabs {
            XCTAssertEqual(tabRouter.getNavigationStack(for: tab.id).count, 1)
        }
    }
    
    // MARK: - Event Tests
    
    @MainActor
    func testTabChangeEvent() throws {
        var receivedEvent: TabNavigationEvent?
        
        tabRouter.onTabChange { event in
            receivedEvent = event
        }
        
        try tabRouter.selectTab("search")
        
        if case .tabSelected(let tabId, let previousId) = receivedEvent {
            XCTAssertEqual(tabId, "search")
            XCTAssertEqual(previousId, "home")
        } else {
            XCTFail("Expected tabSelected event")
        }
    }
    
    @MainActor
    func testTabReselectedEvent() throws {
        var receivedEvent: TabNavigationEvent?
        
        tabRouter.onTabChange { event in
            receivedEvent = event
        }
        
        try tabRouter.selectTab("home") // Already on home
        
        if case .tabReselected(let tabId) = receivedEvent {
            XCTAssertEqual(tabId, "home")
        } else {
            XCTFail("Expected tabReselected event")
        }
    }
    
    // MARK: - Tab Management Tests
    
    @MainActor
    func testRegisterTab() {
        let newTab = TabItem(
            id: "notifications",
            title: "Notifications",
            systemImage: "bell",
            routeIdentifier: "/notifications",
            order: 4
        )
        
        tabRouter.registerTab(newTab)
        
        XCTAssertEqual(tabRouter.tabs.count, 5)
        XCTAssertTrue(tabRouter.tabs.contains { $0.id == "notifications" })
    }
    
    @MainActor
    func testUnregisterTab() {
        tabRouter.unregisterTab("settings")
        
        XCTAssertEqual(tabRouter.tabs.count, 3)
        XCTAssertFalse(tabRouter.tabs.contains { $0.id == "settings" })
    }
    
    @MainActor
    func testUnregisterCurrentTab() throws {
        try tabRouter.selectTab("settings")
        XCTAssertEqual(tabRouter.selectedTabId, "settings")
        
        tabRouter.unregisterTab("settings")
        
        XCTAssertNotEqual(tabRouter.selectedTabId, "settings")
    }
    
    // MARK: - Configuration Tests
    
    @MainActor
    func testConfigurationDefaults() {
        let config = TabRouter.Configuration.default
        
        XCTAssertTrue(config.persistState)
        XCTAssertTrue(config.animateChanges)
        XCTAssertTrue(config.doubleTapResetsNavigation)
        XCTAssertTrue(config.trackHistory)
    }
    
    @MainActor
    func testCustomConfiguration() {
        let config = TabRouter.Configuration(
            persistState: false,
            persistenceKey: "CustomKey",
            animateChanges: false,
            doubleTapResetsNavigation: false,
            trackHistory: false,
            defaultTabId: "search",
            debounceInterval: 0.2
        )
        
        let router = TabRouter(tabs: testTabs, configuration: config)
        
        XCTAssertEqual(router.selectedTabId, "search")
    }
}

// MARK: - Tab Item Tests

final class TabItemTests: XCTestCase {
    
    func testTabItemCreation() {
        let tab = TabItem(
            id: "test",
            title: "Test",
            systemImage: "star",
            routeIdentifier: "/test"
        )
        
        XCTAssertEqual(tab.id, "test")
        XCTAssertEqual(tab.title, "Test")
        XCTAssertEqual(tab.systemImage, "star")
        XCTAssertTrue(tab.isEnabled)
        XCTAssertTrue(tab.isVisible)
    }
    
    func testTabItemAccessibility() {
        let tab = TabItem(
            id: "test",
            title: "Test",
            systemImage: "star",
            accessibilityLabel: "Custom Label",
            accessibilityHint: "Custom Hint",
            routeIdentifier: "/test"
        )
        
        XCTAssertEqual(tab.accessibilityLabel, "Custom Label")
        XCTAssertEqual(tab.accessibilityHint, "Custom Hint")
    }
    
    func testTabItemDefaultAccessibility() {
        let tab = TabItem(
            id: "test",
            title: "Test Tab",
            systemImage: "star",
            routeIdentifier: "/test"
        )
        
        XCTAssertEqual(tab.accessibilityLabel, "Test Tab")
        XCTAssertTrue(tab.accessibilityHint.contains("Test Tab"))
    }
}

// MARK: - Tab Badge Tests

final class TabBadgeTests: XCTestCase {
    
    func testCountBadge() {
        let badge = TabBadge.count(10)
        
        XCTAssertEqual(badge.stringValue, "10")
        XCTAssertTrue(badge.isVisible)
    }
    
    func testCountBadgeOverflow() {
        let badge = TabBadge.count(150)
        
        XCTAssertEqual(badge.stringValue, "99+")
    }
    
    func testZeroCountBadgeHidden() {
        let badge = TabBadge.count(0)
        
        XCTAssertNil(badge.stringValue)
        XCTAssertFalse(badge.isVisible)
    }
    
    func testTextBadge() {
        let badge = TabBadge.text("New")
        
        XCTAssertEqual(badge.stringValue, "New")
        XCTAssertTrue(badge.isVisible)
    }
    
    func testDotBadge() {
        let badge = TabBadge.dot()
        
        XCTAssertEqual(badge.stringValue, "●")
        XCTAssertTrue(badge.isVisible)
    }
    
    func testCustomColorBadge() {
        let badge = TabBadge(
            type: .count(5),
            color: .custom(red: 1.0, green: 0.5, blue: 0.0)
        )
        
        XCTAssertEqual(badge.stringValue, "5")
    }
}
