import Testing
@testable import SwiftRouter

@MainActor
@Suite("Route guards")
struct GuardTests {
    @Test func aSignedOutUserIsSentToSignInAndTheRequestIsKept() {
        let session = Session()
        let router = Router<TestRoute>()
        router.addGuard(.account(session))
        router.push(.catalog)

        #expect(router.push(.orders) == .redirected)
        #expect(router.entries == [.push(.catalog), .sheet(.signIn)])
        #expect(router.pending == [.push(.catalog), .push(.orders)])
    }

    @Test func resumingAfterSignInShowsTheOriginalRequest() {
        let session = Session()
        let router = Router<TestRoute>()
        router.addGuard(.account(session))
        router.setEntries([.push(.account), .push(.orders)])

        session.isSignedIn = true
        #expect(router.resumePending() == .applied)
        #expect(router.entries == [.push(.account), .push(.orders)])
        #expect(router.pending == nil)
        #expect(router.resumePending() == nil)
    }

    @Test func resumingWhileStillSignedOutRedirectsAgain() {
        let session = Session()
        let router = Router<TestRoute>()
        router.addGuard(.account(session))
        router.push(.account)
        #expect(router.resumePending() == .redirected)
        #expect(router.pending == [.push(.account)])
        router.discardPending()
        #expect(router.pending == nil)
    }

    @Test func aCancelledRequestChangesNothing() {
        let router = Router<TestRoute>(entries: [.push(.catalog)])
        router.addGuard(RouteGuard("no settings") { entry, _ in entry.route == .settings ? .cancel : .allow })
        #expect(router.present(.settings) == .cancelled)
        #expect(router.entries == [.push(.catalog)])
        #expect(router.pending == nil)
    }

    @Test func onlyTheEntriesAfterTheSharedPrefixAreChecked() {
        let recorder = Recorder()
        let router = Router<TestRoute>(entries: [.push(.catalog), .push(.product(1))])
        router.addGuard(RouteGuard("record") { entry, context in
            recorder.routes.append(entry.route)
            #expect(context.target[context.index] == entry)
            return .allow
        })
        router.setEntries([.push(.catalog), .push(.product(1)), .push(.reviews(1)), .sheet(.settings)])
        #expect(recorder.routes == [.reviews(1), .settings])
    }

    @Test func guardsRunInOrderAndTheFirstObjectionWins() {
        let router = Router<TestRoute>()
        router.addGuard(RouteGuard("first") { entry, _ in entry.route == .orders ? .redirect([.push(.signIn)]) : .allow })
        router.addGuard(RouteGuard("second") { _, _ in .cancel })
        #expect(router.push(.orders) == .redirected)
        #expect(router.entries == [.push(.signIn)])
    }

    @Test func removingAGuardByNameLetsTheRouteThrough() {
        let session = Session()
        let router = Router<TestRoute>()
        router.addGuard(.account(session))
        router.removeGuards(named: "account")
        #expect(router.push(.account) == .applied)
    }

    @Test func aNavigationLinkToAGuardedRouteIsRedirected() {
        let session = Session()
        let router = Router<TestRoute>(entries: [.push(.catalog)])
        router.addGuard(.account(session))
        let before = router.refusals
        router.setPushes([.catalog, .account], atLevel: 0)
        #expect(router.entries == [.push(.catalog), .sheet(.signIn)])
        #expect(router.refusals == before + 1)
    }

    @Test func aRefusedNavigationLinkMakesTheViewsReadTheStateAgain() {
        let router = Router<TestRoute>(entries: [.push(.catalog)])
        router.addGuard(RouteGuard("closed") { _, _ in .cancel })
        let before = router.refusals
        router.setPushes([.catalog, .settings], atLevel: 0)
        #expect(router.entries == [.push(.catalog)])
        #expect(router.refusals == before + 1)
    }

    @Test func aRedirectLongerThanMaxDepthIsRejected() {
        let router = Router<TestRoute>(maxDepth: 2)
        router.addGuard(RouteGuard("long") { entry, _ in
            entry.route == .orders ? .redirect([.push(.signIn), .push(.settings)]) : .allow
        })
        router.push(.catalog)
        #expect(router.push(.orders) == .rejected(.depthLimitExceeded(limit: 2)))
        #expect(router.entries == [.push(.catalog)])
        #expect(router.pending == nil)
    }

    @Test func revalidateAfterSignOutReplacesTheProtectedScreens() {
        let session = Session()
        session.isSignedIn = true
        let router = Router<TestRoute>()
        router.addGuard(.account(session))
        router.push(contentsOf: [.catalog, .account, .orders])

        session.isSignedIn = false
        #expect(router.revalidate() == .redirected)
        #expect(router.entries == [.push(.catalog), .sheet(.signIn)])
        #expect(router.pending == nil)
    }

    @Test func revalidateCutsAtTheFirstCancelledEntry() {
        let closed = Flag()
        let router = Router<TestRoute>(entries: [.push(.catalog), .push(.settings), .push(.product(1))])
        router.addGuard(RouteGuard("settings") { entry, _ in closed.isOn && entry.route == .settings ? .cancel : .allow })
        #expect(router.revalidate() == .applied)
        closed.isOn = true
        #expect(router.revalidate() == .cancelled)
        #expect(router.entries == [.push(.catalog)])
    }

    @Test func popAndDismissAreNeverChecked() {
        let router = Router<TestRoute>(entries: [.push(.catalog), .sheet(.settings), .push(.account)])
        router.addGuard(RouteGuard("closed") { _, _ in .cancel })
        #expect(router.pop() == 1)
        #expect(router.dismiss())
        #expect(router.entries == [.push(.catalog)])
    }
}

@MainActor
private final class Recorder {
    var routes: [TestRoute] = []
}
