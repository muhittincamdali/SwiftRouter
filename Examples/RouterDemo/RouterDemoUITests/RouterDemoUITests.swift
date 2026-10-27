import XCTest

/// Drives the demo app on an iOS simulator: taps, the back button, deep links, the sign-in
/// guard and the tab bar, checking the screens the router shows.
final class RouterDemoUITests: XCTestCase {
    private let timeout: TimeInterval = 10

    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }

    @MainActor
    private func waitForTitle(_ title: String, in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: timeout), "No screen titled \(title)", file: file, line: line)
    }

    /// Opens a URL the way a tapped link does: the running app receives it in `onOpenURL`.
    /// (`XCUIApplication.open(_:)` starts the app again, which would hide state bugs.)
    @MainActor
    private func openFromTheSystem(_ text: String) throws {
        XCUIDevice.shared.system.open(try XCTUnwrap(URL(string: text)))
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let confirm = springboard.buttons["Open"]
        if confirm.waitForExistence(timeout: 3) { confirm.tap() }
    }

    @MainActor
    private func processID(of app: XCUIApplication) -> Substring? {
        app.debugDescription.components(separatedBy: "pid: ").dropFirst().first?.prefix { $0.isNumber }
    }

    @MainActor
    func testPushingAndGoingBack() {
        let app = launch()
        app.buttons["product-2"].tap()
        waitForTitle("Pocket Map", in: app)
        app.buttons["open-reviews"].tap()
        waitForTitle("Reviews", in: app)
        app.navigationBars["Reviews"].buttons.element(boundBy: 0).tap()
        waitForTitle("Pocket Map", in: app)
    }

    @MainActor
    func testADeepLinkOpensAStackSeveralScreensDeep() throws {
        let app = launch()
        try openFromTheSystem("routerdemo://products/3/reviews")
        waitForTitle("Reviews", in: app)
        XCTAssertTrue(app.staticTexts["Bright on the lowest setting."].exists)
        app.navigationBars["Reviews"].buttons.element(boundBy: 0).tap()
        waitForTitle("Head Lamp", in: app)
    }

    @MainActor
    func testADeepLinkToAnOrderAsksToSignInFirstAndThenOpensIt() throws {
        let app = launch()
        try openFromTheSystem("routerdemo://account/orders/1002")
        waitForTitle("Sign in", in: app)
        app.buttons["sign-in"].tap()
        waitForTitle("Order 1002", in: app)
        XCTAssertTrue(app.tabBars.buttons["Account"].isSelected)
    }

    @MainActor
    func testTheSignInSheetOpensOnTopOfTheCartSheet() {
        let app = launch()
        app.buttons["open-cart"].tap()
        waitForTitle("Cart", in: app)
        app.buttons["cart-orders"].tap()
        waitForTitle("Sign in", in: app)
        app.buttons["sign-in"].tap()
        waitForTitle("Orders", in: app)
        XCTAssertTrue(app.buttons["Order 1001"].exists)
    }

    @MainActor
    func testAnUnknownProductLinkChangesNothing() throws {
        let app = launch()
        app.buttons["product-1"].tap()
        waitForTitle("Trail Compass", in: app)
        let process = processID(of: app)
        try openFromTheSystem("routerdemo://products/99")
        XCTAssertTrue(app.navigationBars["Trail Compass"].waitForExistence(timeout: timeout))
        XCTAssertEqual(processID(of: app), process, "The link must reach the running app")
    }

    @MainActor
    func testChoosingTheSelectedTabAgainPopsToTheRoot() {
        let app = launch()
        app.buttons["product-1"].tap()
        waitForTitle("Trail Compass", in: app)
        app.tabBars.buttons["Shop"].tap()
        waitForTitle("Shop", in: app)
    }

    @MainActor
    func testASheetSwipedDownCanBeOpenedAgain() {
        let app = launch()
        app.buttons["open-cart"].tap()
        waitForTitle("Cart", in: app)
        app.navigationBars["Cart"].swipeDown(velocity: .fast)
        XCTAssertTrue(app.navigationBars["Shop"].waitForExistence(timeout: timeout))
        XCTAssertFalse(app.navigationBars["Cart"].exists)
        app.buttons["open-cart"].tap()
        waitForTitle("Cart", in: app)
    }
}
