import SwiftRouter
import SwiftUI

@main
struct RouterDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var model = AppModel()

    var body: some View {
        TabView(selection: model.tabs.selectionBinding) {
            RouterView(router: model.tabs.router(for: .shop)) {
                CatalogScreen()
            }
            .routerStateRestoration(model.tabs.router(for: .shop), key: "shop")
            .tabItem { Label("Shop", systemImage: "bag") }
            .tag(DemoTab.shop)

            RouterView(router: model.tabs.router(for: .account)) {
                AccountScreen(signOut: model.signOut)
            }
            .routerStateRestoration(model.tabs.router(for: .account), key: "account")
            .tabItem { Label("Account", systemImage: "person.crop.circle") }
            .tag(DemoTab.account)
        }
        .environment(model.session)
        .onOpenURL { url in model.open(url) }
        .tint(.blue)
    }
}
