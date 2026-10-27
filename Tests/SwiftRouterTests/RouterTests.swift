import Testing
@testable import SwiftRouter

@MainActor
@Suite("Router stack and presentation")
struct RouterTests {
    @Test func pushAndPopKeepOrder() {
        let router = Router<TestRoute>()
        router.push(.catalog)
        router.navigate(to: .product(1))
        #expect(router.path == [.catalog, .product(1)])
        #expect(router.top == .product(1))
        #expect(router.pop() == 1)
        #expect(router.path == [.catalog])
    }

    @Test func popNeverRemovesMoreThanThePushedScreensOfTheTopLevel() {
        let router = Router<TestRoute>(entries: [.push(.catalog), .sheet(.settings), .push(.account)])
        #expect(router.pop(5) == 1)
        #expect(router.entries == [.push(.catalog), .sheet(.settings)])
        #expect(router.canPop == false)
        #expect(router.pop() == 0)
    }

    @Test func popToRootStaysInsideTheSheet() {
        let router = Router<TestRoute>(entries: [.push(.catalog), .sheet(.settings), .push(.account), .push(.orders)])
        router.popToRoot()
        #expect(router.entries == [.push(.catalog), .sheet(.settings)])
    }

    @Test func popToFindsTheLastOccurrenceAcrossSheets() {
        let router = Router<TestRoute>(entries: [.push(.catalog), .push(.product(1)), .sheet(.catalog), .push(.product(2))])
        #expect(router.popTo(.catalog))
        #expect(router.entries == [.push(.catalog), .push(.product(1)), .sheet(.catalog)])
        #expect(router.popTo { if case .product = $0 { true } else { false } })
        #expect(router.entries == [.push(.catalog), .push(.product(1))])
    }

    @Test func popToAMissingRouteChangesNothing() {
        let router = Router<TestRoute>(entries: [.push(.catalog)])
        #expect(router.popTo(.settings) == false)
        #expect(router.path == [.catalog])
    }

    @Test func dismissRemovesTheTopModalLevelWithItsPushes() {
        let router = Router<TestRoute>()
        router.push(.catalog)
        router.present(.settings)
        router.push(.account)
        router.present(.signIn, style: .fullScreenCover)
        #expect(router.isPresenting)
        #expect(router.dismiss())
        #expect(router.entries == [.push(.catalog), .sheet(.settings), .push(.account)])
        #expect(router.dismiss())
        #expect(router.entries == [.push(.catalog)])
        #expect(router.dismiss() == false)
    }

    @Test func dismissAllKeepsTheRootStack() {
        let router = Router<TestRoute>(entries: [.push(.catalog), .sheet(.settings), .fullScreenCover(.signIn)])
        router.dismissAll()
        #expect(router.entries == [.push(.catalog)])
        router.reset()
        #expect(router.entries.isEmpty)
    }

    @Test func settingThePathReplacesTheStateWithPushes() {
        let router = Router<TestRoute>(entries: [.sheet(.settings)])
        router.path = [.catalog, .product(3)]
        #expect(router.entries == [.push(.catalog), .push(.product(3))])
    }

    @Test func requestsLongerThanMaxDepthAreRejectedWithoutChange() {
        let router = Router<TestRoute>(maxDepth: 2)
        #expect(router.push(contentsOf: [.catalog, .product(1)]) == .applied)
        #expect(router.push(.product(2)) == .rejected(.depthLimitExceeded(limit: 2)))
        #expect(router.present(.settings) == .rejected(.depthLimitExceeded(limit: 2)))
        #expect(router.path == [.catalog, .product(1)])
    }

    @Test func levelsSplitAtEveryModalEntry() {
        let router = Router<TestRoute>(entries: [
            .push(.catalog), .push(.product(1)), .sheet(.settings), .push(.account), .fullScreenCover(.signIn)
        ])
        #expect(router.modalStarts == [2, 4])
        #expect(router.pushes(atLevel: 0) == [.catalog, .product(1)])
        #expect(router.pushes(atLevel: 1) == [.account])
        #expect(router.pushes(atLevel: 2) == [])
        #expect(router.pushes(atLevel: 3) == [])
        #expect(router.modalEntry(atLevel: 1) == .sheet(.settings))
        #expect(router.modalEntry(atLevel: 2) == .fullScreenCover(.signIn))
        #expect(router.modalEntry(atLevel: 3) == nil)
        #expect(router.modalEntry(atLevel: 0) == nil)
    }

    @Test func theSystemBackButtonOnALowerLevelDismissesTheLevelsAbove() {
        let router = Router<TestRoute>(entries: [.push(.catalog), .push(.product(1)), .sheet(.settings)])
        router.setPushes([.catalog], atLevel: 0)
        #expect(router.entries == [.push(.catalog)])
    }

    @Test func aNavigationLinkInsideASheetAppendsToThatSheet() {
        let router = Router<TestRoute>(entries: [.push(.catalog), .sheet(.settings)])
        router.setPushes([.account], atLevel: 1)
        #expect(router.entries == [.push(.catalog), .sheet(.settings), .push(.account)])
    }

    @Test func swipingASheetDownDismissesOnlyThatLevel() {
        let router = Router<TestRoute>(entries: [.sheet(.settings), .push(.account), .sheet(.signIn)])
        router.dismissLevel(2)
        #expect(router.entries == [.sheet(.settings), .push(.account)])
        router.dismissLevel(5)
        #expect(router.entries == [.sheet(.settings), .push(.account)])
        router.dismissLevel(1)
        #expect(router.entries.isEmpty)
    }

    @Test func writesForALevelThatIsNotShownAreIgnored() {
        let router = Router<TestRoute>(entries: [.push(.catalog)])
        router.setPushes([.settings], atLevel: 3)
        #expect(router.entries == [.push(.catalog)])
    }

    @Test func entryHelpersSetTheStyle() {
        #expect(RouteEntry<TestRoute>.push(.catalog).style == .push)
        #expect(RouteEntry<TestRoute>.sheet(.catalog).style == .sheet)
        #expect(RouteEntry<TestRoute>.fullScreenCover(.catalog).style == .fullScreenCover)
        #expect(PresentationStyle.allCases.filter(\.isModal) == [.sheet, .fullScreenCover])
    }
}
