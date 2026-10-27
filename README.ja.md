<!-- i18n-source: README.md@09ab6810d8d96e3ea94fe665de84ba5080b46572 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-light.svg" alt="SwiftRouter: Type-safe SwiftUI navigation: stacks, sheets, deep links, guards and tabs in one router."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml/badge.svg" alt="CI ステータス"></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-light.svg" alt="最新バージョン: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-light.svg" alt="対応プラットフォーム: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-light.svg" alt="言語バージョン: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-light.svg" alt="ライセンス: MIT"></picture></a>
</p>

<p align="center">
<a href="#クイックスタート"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-ja-light.svg" alt="はじめる"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-ja-light.svg" alt="ドキュメント"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-ja-light.svg" alt="サンプル"></picture></a>
</p>

> このドキュメントは英語版 README の翻訳です。内容が異なる場合は英語版が最新です。

<!-- brand:end -->

SwiftRouter は、iOS 17+、macOS 14+、tvOS 17+、watchOS 10+、visionOS 1+ の SwiftUI アプリでナビゲーションを扱うための Swift パッケージです。画面を enum に列挙すると、1 つの `Router` がナビゲーションの状態全体を保持します。push された画面、その上に重なるシートやフルスクリーンカバー、そしてそのシートの中で push された画面です。ディープリンクはこの状態に対応づけられ、ガード（guard）はすべての画面が表示される前にチェックし、各タブは独自のスタックを保持できます。このパッケージに依存関係はありません。

<table>
<tr>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/product-dark.png"><img src="docs/images/product-light.png" width="200" alt="リンク routerdemo://products/2 で開かれた商品画面"></picture><br><sub><code>routerdemo://products/2</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/reviews-dark.png"><img src="docs/images/reviews-light.png" width="200" alt="1 つのリンクで商品画面の上に push されたレビュー画面"></picture><br><sub><code>…/products/2/reviews</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/cart-dark.png"><img src="docs/images/cart-light.png" width="200" alt="リンクでシートとして表示されたカート"></picture><br><sub><code>routerdemo://cart</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/sign-in-dark.png"><img src="docs/images/sign-in-light.png" width="200" alt="サインアウト中に注文へのリンクを開くと、サインインシートが表示される"></picture><br><sub><code>…/account/orders/1001</code></sub></td>
</tr>
</table>

スクリーンショットは iPhone シミュレータ上の[サンプルアプリ](Examples/RouterDemo)から取得したものです。それぞれ、下に示すリンクから router が到達した状態です（[`scripts/capture-screens.sh`](scripts/capture-screens.sh)）。

## 主な特長

- **型付きルート** — 画面は関連値を持つ enum のケースなので、存在しない遷移先はコンパイルできません。
- **スタックとシートを 1 つの状態で管理** — `router.entries` は、push された画面、シート、フルスクリーンカバーをすべて列挙します。シートは独自のナビゲーションスタックを持ち、別のシートを表示できます。戻るボタン、スワイプバック、シートの下スワイプは router に書き戻されます。
- **状態全体へのディープリンク** — `shop://products/42` や `https://shop.example.com/products/42` で、商品を最上位に置いたカタログや、シートを開けます。`/products/:id` のようなパターンは最も具体的なものから照合され、共有用のパスも同じパターンから組み立てられます。
- **リンクは使う前に検証** — 長さ、セグメント数、クエリ数の上限、指定したホストでのみ `https` を許可、`..` セグメントなし、制御文字なし、型付きの値はクラッシュせずに `nil` になります（`Int` のオーバーフロー、`nan`、`inf`）。
- **どの経路からも回避できないガード** — ガードは、push、シート、ディープリンク、復元されたスナップショット、`NavigationLink` のいずれで追加された画面も確認します。サインインへのリダイレクトはリクエストを保持し、サインイン後に `resumePending()` がそれを開きます。
- **タブと状態の復元** — `TabRouter` はタブごとに 1 つのスタックを保持し、選択中のタブをもう一度選ぶとルートまで戻ります。`routerStateRestoration(_:key:)` は状態をシーンごとに保存し、復元時にガードを通します。
- **テスト済み** — macOS と iPhone シミュレータでの 86 件の Swift Testing テストと、iOS 27 シミュレータでサンプルアプリを操作する 7 件の UI テストがあります。push と戻る、3 画面深いディープリンク、カートのシートの上に重なるサインインシート、サインイン後のリクエスト再開を確認しています。

## クイックスタート

**1. パッケージを追加する**

Xcode で **File › Add Package Dependencies…** を選び、右上の検索欄にリポジトリの URL を貼り付けます。

```text
https://github.com/muhittincamdali/SwiftRouter.git
```

**Dependency Rule** は `2.0.0` からの **Up to Next Major Version** のままにして、**Add Package** をクリックします。次のウィンドウで **SwiftRouter** の横にアプリのターゲットを選び、もう一度 **Add Package** をクリックします。

**2. モジュールをインポートする**

```swift
import SwiftRouter
```

この行は、router を使う各 Swift ファイルの先頭、`import SwiftUI` の隣に書きます。

**3. 使ってみる**

新しい Xcode アプリ（**File › New › Project… › App**）で、`ContentView.swift` の内容をすべて次のコードに置き換えます。

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

**Run**（⌘R）を押します。**Open item 1** は画面を push し、**About** はシートを開きます（下にスワイプして閉じます）。**Open items 2 and 3** は 2 つの画面を一度に push し、戻るボタンは 1 画面ずつ戻ります。

## インストール

### Swift Package Manager

リポジトリの URL は `https://github.com/muhittincamdali/SwiftRouter.git`, これを Xcode の **File › Add Package Dependencies…** に入力するか、`Package.swift` の `dependencies` に追加します。

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

### 動作要件

|                  | 最小バージョン                                    |
| ---------------- | ------------------------------------------------- |
| Swift            | 6.2（Xcode 26 以降）                              |
| プラットフォーム | iOS 17、macOS 14、tvOS 17、watchOS 10、visionOS 1 |

バージョン 2.0.0 は、ルートを実行時に文字列で検索していた 1.0.0（2026 年 2 月）の API を置き換えます。2026 年 6 月に 1.0.0 のソースはプレースホルダーのコードに置き換えられました。2.0.0 は Swift 6 言語モードに向けて新しく作成しテストした router で、SwiftUI-Navigation-Pro のプレゼンテーション、タブ、状態保存の機能を引き継いでいます。変更点は [CHANGELOG.md](CHANGELOG.md) にまとめてあり、[Migrating from version 1](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1) が旧 API と新 API の対応を示しています。

## 使い方

以下のサンプルは [`Examples/RouterDemo/RouterDemo/ReadmeSamples.swift`](Examples/RouterDemo/RouterDemo/ReadmeSamples.swift) からコピーしたものです。サンプルアプリとテストスイートはどちらもこのファイルをコンパイルし、テストではディープリンクとサインインのサンプルを実行します。

### 画面遷移

`RouterView` 内の画面（シートを含む）は、environment から router を読み取ります。

```swift
@Environment(Router<AppRoute>.self) private var router
```

| 呼び出し                        | 動作                                                                  |
| ------------------------------- | --------------------------------------------------------------------- |
| `push(_:)`, `push(contentsOf:)` | 最上位のスタックに 1 つ以上の画面を push します                       |
| `present(_:style:)`             | 独自のスタックを持つ `.sheet` または `.fullScreenCover` を表示します  |
| `pop(_:)`, `popToRoot()`        | 最上位のスタックで push された画面を pop します。シートは閉じません   |
| `popTo(_:)`                     | ルートが最後に現れた位置まで、シートをまたいで pop します             |
| `dismiss()`, `dismissAll()`     | 最上位のシート、またはすべてのシートを閉じます                        |
| `reset()`                       | すべてを閉じて、ルートビューまで pop します                           |
| `setEntries(_:)`                | 状態全体を置き換えます。例: `[.push(.product(id: 3)), .sheet(.cart)]` |

画面を追加する呼び出しは、`.applied`、`.redirected`（ガードが別の画面を表示した）、`.cancelled`（ガードが拒否した）、`.rejected`（エントリが `maxDepth` を超えた。デフォルトは 64）のいずれかを返します。

### ディープリンク

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

`shop://products/42` と `https://shop.example.com/products/42` はどちらも、商品 42 を最上位に置いてカタログを開くため、戻るボタンでカタログに戻れます。カスタムスキームの URL では、ホストが最初のパスセグメントとして読み取られます。`onDeepLink` は、カスタムスキームを `onOpenURL` で、ユニバーサルリンクを `onContinueUserActivity` で受け取ります。スキームはターゲットの **URL Types** に登録してください。ユニバーサルリンクには Associated Domains entitlement も必要です。

ハンドラは、値が受け入れられない場合に `nil` を返し、次に一致するパターンが試されます。どのパターンにも一致しないリンクや拒否されたリンクは、ナビゲーションの状態をそのままにします。

### ガード

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

サインアウト中は、`shop://orders` はサインインシートを表示してリクエストを保持します。その後 `signIn` がシートを注文画面に置き換えます。サインアウトしたあとは、`router.revalidate()` を呼び出して、許可されなくなった画面を取り除きます。

### タブと状態の復元

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

各タブは独自のスタックを保持し、選択中のタブをもう一度選ぶとルートまで pop します。`tabs.open(url, using: [.shop: shopLinks, .orders: orderLinks])` は、そのリンクに一致するリンク定義を持つ最初のタブでリンクを開きます。状態はシーンのストレージに保存されるため、ウィンドウごとに独自の状態が保持され、バックグラウンドでシステムがアプリを終了したあとも復元されます。そのためには、ルートが `Codable` である必要があります。

## リンクの検証方法

URL はアプリの外から届くため、`DeepLinks` はどのパターンを実行するよりも前に検証します。

| 入力                                                                           | 結果                                                   |
| ------------------------------------------------------------------------------ | ------------------------------------------------------ |
| 2,048 バイトを超える、32 を超えるセグメント、または 32 を超えるクエリ項目      | 拒否。長さを最初に確認します                           |
| `http`、未知のスキーム、指定していないホストの `https`                         | 拒否。`*.example.com` はサブドメインのみを受け付けます |
| URL 内のユーザー名またはパスワード                                             | 拒否                                                   |
| `.` または `..` のセグメント（`%2e` と書かれたものも含む）                     | 拒否。解決はしません                                   |
| `%2F`                                                                          | 1 つのセグメント内にとどまります                       |
| 制御文字、双方向書式文字、UTF-8 ではないバイト                                 | 拒否                                                   |
| `int` または `double` で読み取った `nan`、`inf`、`4.5`、`99999999999999999999` | `nil`                                                  |

上限は `DeepLinkLimits` で設定します。パッケージが URL やルートを出力したりログに記録したりすることはありません。リンクにはサインインやリセット用のトークンが含まれることがあるためです。[Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking) の記事にすべてのルールが載っています。

## サンプルアプリ

[`Examples/RouterDemo`](Examples/RouterDemo) は iOS と macOS 向けの小さなショップです。Shop と Account のタブ、レビュー付きの商品、カートのシート、サインインのガードで守られた注文、`routerdemo://` スキームのディープリンク、保存された状態を備えています。`Examples/RouterDemo/RouterDemo.xcodeproj` を開き、**RouterDemo** スキームと iPhone シミュレータまたは **My Mac** を選んで、**Run**（⌘R）を押します。シミュレータでリンクを試すには、次のようにします。

```sh
xcrun simctl openurl booted "routerdemo://products/2/reviews"
```

**RouterDemoUITests** ターゲット（iPhone シミュレータで ⌘U）は、これらのフローを画面上で確認します。

## ドキュメント

[ドキュメント](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/)はすべての公開型を網羅し、次の記事を含みます。

- [Getting started](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/gettingstarted)
- [Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking)
- [Guarding screens](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/guardingscreens)
- [Tabs and state restoration](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/tabsandstaterestoration)
- [Migrating from version 1](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1)

## コントリビューション

バグ報告と pull request を歓迎します。テストとサンプルアプリの実行方法は [CONTRIBUTING.md](CONTRIBUTING.md) に記載しています。セキュリティ上の問題は、[SECURITY.md](SECURITY.md) の手順に従って非公開で報告してください。

## ライセンス

SwiftRouter は MIT ライセンスで公開しています。詳細は [LICENSE](LICENSE) を参照してください。
