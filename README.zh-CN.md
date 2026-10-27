<!-- i18n-source: README.md@09ab6810d8d96e3ea94fe665de84ba5080b46572 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-light.svg" alt="SwiftRouter: Type-safe SwiftUI navigation: stacks, sheets, deep links, guards and tabs in one router."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml/badge.svg" alt="CI 状态"></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-light.svg" alt="最新版本: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-light.svg" alt="支持的平台: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-light.svg" alt="语言版本: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-light.svg" alt="许可证: MIT"></picture></a>
</p>

<p align="center">
<a href="#快速开始"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-zh-CN-light.svg" alt="开始使用"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-zh-CN-light.svg" alt="文档"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-zh-CN-light.svg" alt="示例"></picture></a>
</p>

> 本文是英文 README 的译文。如两者内容不一致，以英文版为准。

<!-- brand:end -->

SwiftRouter 是一个用于 SwiftUI 应用导航的 Swift 软件包，支持 iOS 17+、macOS 14+、tvOS 17+、watchOS 10+ 和 visionOS 1+。你在一个枚举中列出所有页面，由一个 `Router` 保存全部导航状态：已 push 的页面、位于其上的 sheet 和全屏 cover，以及在这些 sheet 内部 push 的页面。深度链接（deep link）会映射到这一状态，guard 会在每个页面出现之前进行检查，每个标签页也可以保留各自的导航栈。该软件包没有任何依赖。

<table>
<tr>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/product-dark.png"><img src="docs/images/product-light.png" width="200" alt="通过链接 routerdemo://products/2 打开的商品页面"></picture><br><sub><code>routerdemo://products/2</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/reviews-dark.png"><img src="docs/images/reviews-light.png" width="200" alt="通过一个链接 push 到商品页之上的评价页面"></picture><br><sub><code>…/products/2/reviews</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/cart-dark.png"><img src="docs/images/cart-light.png" width="200" alt="通过链接以 sheet 形式展示的购物车"></picture><br><sub><code>routerdemo://cart</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/sign-in-dark.png"><img src="docs/images/sign-in-light.png" width="200" alt="未登录时打开订单链接会显示登录 sheet"></picture><br><sub><code>…/account/orders/1001</code></sub></td>
</tr>
</table>

截图来自 iPhone 模拟器上的[示例应用](Examples/RouterDemo)：每张图都是 router 通过其下方的链接所到达的状态（[`scripts/capture-screens.sh`](scripts/capture-screens.sh)）。

## 亮点

- **类型化路由** — 页面是带关联值的枚举 case，因此不存在的目标无法通过编译。
- **栈与 sheet 共用一个状态** — `router.entries` 列出每一个已 push 的页面、sheet 和全屏 cover。sheet 拥有自己的导航栈，还可以再弹出另一个 sheet。返回按钮、右滑返回以及下滑关闭 sheet 的操作都会写回 router。
- **深度链接可还原完整状态** — `shop://products/42` 和 `https://shop.example.com/products/42` 可以打开商品目录并在其上显示该商品，也可以打开一个 sheet。`/products/:id` 这样的模式按最具体者优先匹配，用于分享的路径也由同样的模式生成。
- **链接在使用前先检查** — 限制长度、路径段和查询参数的数量，只允许你列出的主机使用 `https`，不允许 `..` 路径段，不允许控制字符，类型化的值在无法解析时为 `nil`，而不是触发崩溃（`Int` 溢出、`nan`、`inf`）。
- **任何路径都绕不过的 guard** — guard 能看到通过 push、sheet、深度链接、恢复的快照或 `NavigationLink` 添加的每一个页面。重定向到登录页时会保留原请求，登录后 `resumePending()` 会将其打开。
- **标签页与状态恢复** — `TabRouter` 为每个标签页保留一个导航栈，再次选择已选中的标签页时回到根页面；`routerStateRestoration(_:key:)` 按 scene 保存状态，并在状态恢复时让它重新经过各个 guard。
- **经过测试** — 在 macOS 和 iPhone 模拟器上运行 86 个 Swift Testing 测试，另有 7 个 UI 测试在 iOS 27 模拟器上驱动示例应用：push 与返回、三层深的深度链接、叠在购物车 sheet 之上的登录 sheet，以及登录后继续之前的请求。

## 快速开始

**1. 添加软件包**

在 Xcode 中选择 **File › Add Package Dependencies…**，然后将仓库地址粘贴到右上角的搜索框中：

```text
https://github.com/muhittincamdali/SwiftRouter.git
```

将 **Dependency Rule** 保持为从 `2.0.0` 开始的 **Up to Next Major Version**，然后点击 **Add Package**。在接下来的窗口中，在 **SwiftRouter** 旁选择你的应用 target，再次点击 **Add Package**。

**2. 导入模块**

```swift
import SwiftRouter
```

把这一行放在每个使用 router 的 Swift 文件顶部，紧挨着 `import SwiftUI`。

**3. 开始使用**

在新建的 Xcode 应用中（**File › New › Project… › App**），将 `ContentView.swift` 中的全部内容替换为：

```swift
import SwiftRouter
import SwiftUI

enum Screen: Route {
    case detail(Int)
    case about

    @ViewBuilder
    func view() -> some View {
        switch self {
        case .detail(let number):
            Text("Item \(number)")
                .navigationTitle("Detail")
        case .about:
            Text("SwiftRouter quick start")
                .navigationTitle("About")
        }
    }
}

struct ContentView: View {
    @State private var router = Router<Screen>()

    var body: some View {
        RouterView(router: router) {
            List {
                RouterLink("Open item 1", to: Screen.detail(1))
                RouterLink("About", to: Screen.about, style: .sheet)
                Button("Open items 2 and 3") {
                    router.push(contentsOf: [.detail(2), .detail(3)])
                }
            }
            .navigationTitle("Home")
        }
    }
}
```

点击 **Run**（⌘R）。**Open item 1** 会 push 一个页面，**About** 会打开一个 sheet（向下滑动即可关闭），**Open items 2 and 3** 会一次 push 两个页面；返回按钮每次返回一个页面。

## 安装

### Swift Package Manager

仓库地址是 `https://github.com/muhittincamdali/SwiftRouter.git`, 你可以在 Xcode 的 **File › Add Package Dependencies…** 中输入它，也可以把软件包添加到 `Package.swift` 的 `dependencies` 中：

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftRouter.git", from: "2.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "SwiftRouter", package: "SwiftRouter")
    ])
]
```

### 系统要求

|       | 最低版本                                          |
| ----- | ------------------------------------------------- |
| Swift | 6.2（Xcode 26 或更高版本）                        |
| 平台  | iOS 17、macOS 14、tvOS 17、watchOS 10、visionOS 1 |

2.0.0 版本取代了 1.0.0（2026 年 2 月）的 API，后者在运行时通过字符串查找路由。2026 年 6 月，1.0.0 的源码被替换为占位代码；2.0.0 是为 Swift 6 语言模式构建并测试的全新 router，并接管了 SwiftUI-Navigation-Pro 的呈现、标签页和状态保存功能。[CHANGELOG.md](CHANGELOG.md) 列出了所有变更，[Migrating from version 1](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1) 则将旧 API 与新 API 一一对应。

## 使用方法

下面的示例复制自 [`Examples/RouterDemo/RouterDemo/ReadmeSamples.swift`](Examples/RouterDemo/RouterDemo/ReadmeSamples.swift)。示例应用和测试套件都会编译该文件，测试还会运行其中的深度链接和登录示例。

### 导航

`RouterView` 内的页面（包括 sheet）从 environment 中读取 router：

```swift
@Environment(Router<AppRoute>.self) private var router
```

| 调用                            | 作用                                                         |
| ------------------------------- | ------------------------------------------------------------ |
| `push(_:)`, `push(contentsOf:)` | 将一个或多个页面 push 到最上层的导航栈                       |
| `present(_:style:)`             | 显示带有独立导航栈的 `.sheet` 或 `.fullScreenCover`          |
| `pop(_:)`, `popToRoot()`        | 弹出最上层导航栈中已 push 的页面；从不关闭 sheet             |
| `popTo(_:)`                     | 弹出到某个路由最后一次出现的位置，可跨越 sheet               |
| `dismiss()`, `dismissAll()`     | 关闭最上层的 sheet，或关闭所有 sheet                         |
| `reset()`                       | 关闭所有内容并回到根视图                                     |
| `setEntries(_:)`                | 替换整个状态，例如 `[.push(.product(id: 3)), .sheet(.cart)]` |

每个会添加页面的调用都会返回 `.applied`、`.redirected`（某个 guard 显示了其他内容）、`.cancelled`（某个 guard 拒绝了）或 `.rejected`（条目数超过 `maxDepth`，默认为 64）。

### 深度链接

```swift
enum ShopRoute: Route, Codable {
    case catalog
    case product(id: Int)
    case cart
    case orders
    case signIn

    var needsAccount: Bool { self == .orders }

    func view() -> some View {
        Text(String(describing: self))
    }
}

func makeShopLinks() -> DeepLinks<ShopRoute> {
    var links = DeepLinks<ShopRoute>(schemes: ["shop"], hosts: ["shop.example.com"])
    links.add("/products/:id") { match in
        guard let id = match.int("id") else { return nil }
        return [.catalog, .product(id: id)]
    }
    links.add("/cart", entries: { _ in [.sheet(.cart)] })
    links.add("/orders") { _ in [.orders] }
    return links
}

struct ShopView: View {
    @State private var router = Router<ShopRoute>()
    private let links = makeShopLinks()

    var body: some View {
        RouterView(router: router) {
            Text("Home")
        }
        .onDeepLink(links, router: router)
    }
}
```

`shop://products/42` 和 `https://shop.example.com/products/42` 都会打开商品目录，并把 42 号商品放在最上层，所以返回按钮会回到商品目录。在自定义 scheme 的 URL 中，host 被当作第一个路径段。`onDeepLink` 通过 `onOpenURL` 接收自定义 scheme，通过 `onContinueUserActivity` 接收通用链接（universal link）。请在 target 的 **URL Types** 下注册该 scheme；通用链接还需要 Associated Domains entitlement。

当某个值不可接受时，handler 会返回 `nil`，随后会尝试下一个匹配的模式。没有匹配任何模式或被拒绝的链接，不会改变导航状态。

### Guard

```swift
@MainActor
@Observable
final class AccountSession {
    var isSignedIn = false
}

@MainActor
func protectOrders(_ router: Router<ShopRoute>, session: AccountSession) {
    router.addGuard(.requiring(
        { session.isSignedIn },
        for: { $0.needsAccount },
        otherwise: [.sheet(.signIn)]
    ))
}

@MainActor
func signIn(_ router: Router<ShopRoute>, session: AccountSession) {
    session.isSignedIn = true
    if router.resumePending() == nil {
        router.dismiss()
    }
}
```

未登录时，`shop://orders` 会显示登录 sheet 并保留该请求。随后 `signIn` 会用订单页面替换该 sheet。退出登录后，调用 `router.revalidate()` 以移除不再被允许的页面。

### 标签页与状态恢复

```swift
enum AppTab: String, Hashable, CaseIterable {
    case shop, orders
}

struct TabsView: View {
    @State private var tabs = TabRouter<AppTab, ShopRoute>(tabs: AppTab.allCases)

    var body: some View {
        TabView(selection: tabs.selectionBinding) {
            RouterView(router: tabs.router(for: .shop)) {
                Text("Catalog")
            }
            .routerStateRestoration(tabs.router(for: .shop), key: "shop")
            .tabItem { Label("Shop", systemImage: "bag") }
            .tag(AppTab.shop)

            RouterView(router: tabs.router(for: .orders)) {
                Text("Orders")
            }
            .routerStateRestoration(tabs.router(for: .orders), key: "orders")
            .tabItem { Label("Orders", systemImage: "shippingbox") }
            .tag(AppTab.orders)
        }
    }
}
```

每个标签页保留自己的导航栈，再次选择已选中的标签页会让它回到根页面。`tabs.open(url, using: [.shop: shopLinks, .orders: orderLinks])` 会在第一个链接规则与该 URL 匹配的标签页中打开链接。状态保存在 scene 的存储中，因此每个窗口各自保留自己的状态，并且在系统于后台结束应用之后仍会恢复。为此，路由必须遵循 `Codable`。

## 链接是如何被检查的

URL 来自应用之外，因此 `DeepLinks` 会在运行任何模式之前先检查它：

| 输入                                                                    | 结果                                 |
| ----------------------------------------------------------------------- | ------------------------------------ |
| 超过 2,048 字节、超过 32 个路径段或 32 个查询项                         | 被拒绝；先检查长度                   |
| `http`、未知的 scheme、位于你未列出的 host 上的 `https`                 | 被拒绝；`*.example.com` 只接受子域名 |
| URL 中含有用户名或密码                                                  | 被拒绝                               |
| `.` 或 `..` 路径段，包括写成 `%2e` 的形式                               | 被拒绝，不做解析                     |
| `%2F`                                                                   | 保留在同一个路径段内                 |
| 控制字符、双向格式控制字符、不是 UTF-8 的字节                           | 被拒绝                               |
| 用 `int` 或 `double` 读取 `nan`、`inf`、`4.5` 或 `99999999999999999999` | `nil`                                |

限制通过 `DeepLinkLimits` 设置。该软件包从不打印或记录 URL 或路由；链接可能携带登录或重置令牌。[Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking) 文章列出了全部规则。

## 示例应用

[`Examples/RouterDemo`](Examples/RouterDemo) 是一个面向 iOS 和 macOS 的小型商店：包含 Shop 和 Account 两个标签页、带评价的商品、购物车 sheet、受登录 guard 保护的订单、`routerdemo://` scheme 上的深度链接，以及保存的状态。打开 `Examples/RouterDemo/RouterDemo.xcodeproj`，选择 **RouterDemo** scheme 以及一个 iPhone 模拟器或 **My Mac**，然后点击 **Run**（⌘R）。要在模拟器上试一个链接：

```sh
xcrun simctl openurl booted "routerdemo://products/2/reviews"
```

**RouterDemoUITests** target（在 iPhone 模拟器上按 ⌘U）会在屏幕上检查这些流程。

## 文档

[文档](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/)涵盖每一个公开类型，并包含以下文章：

- [Getting started](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/gettingstarted)
- [Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking)
- [Guarding screens](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/guardingscreens)
- [Tabs and state restoration](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/tabsandstaterestoration)
- [Migrating from version 1](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1)

## 参与贡献

欢迎提交 bug 报告和 pull request；[CONTRIBUTING.md](CONTRIBUTING.md) 说明了如何运行测试和示例应用。安全问题请按照 [SECURITY.md](SECURITY.md) 中的说明私下报告。

## 许可证

SwiftRouter 基于 MIT 许可证发布。详见 [LICENSE](LICENSE)。
