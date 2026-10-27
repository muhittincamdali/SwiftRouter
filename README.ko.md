<!-- i18n-source: README.md@b948148be6b8a4b9165602f99c57a96aa585850a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-light.svg" alt="SwiftRouter: Type-safe SwiftUI navigation: stacks, sheets, deep links, guards and tabs in one router."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml/badge.svg" alt="CI 상태"></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-light.svg" alt="최신 버전: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-light.svg" alt="지원 플랫폼: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-light.svg" alt="언어 버전: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-light.svg" alt="라이선스: MIT"></picture></a>
</p>

<p align="center">
<a href="#빠른-시작"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-ko-light.svg" alt="시작하기"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-ko-light.svg" alt="문서"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-ko-light.svg" alt="예제"></picture></a>
</p>

> 이 문서는 영어 README의 번역본입니다. 내용이 다를 경우 영어 버전이 최신입니다.

<!-- brand:end -->

SwiftRouter는 iOS 17+, macOS 14+, tvOS 17+, watchOS 10+, visionOS 1+의 SwiftUI 앱에서
내비게이션을 처리하는 Swift 패키지입니다. 화면을 enum에 나열하면 하나의 `Router`가 내비게이션
상태 전체를 보관합니다. push된 화면, 그 위에 올라온 시트와 전체 화면 커버, 그리고 그 시트 안에서
push된 화면입니다. 딥 링크는 이 상태로 매핑되고, 가드(guard)는 모든 화면이 나타나기 전에
검사하며, 각 탭은 자신의 스택을 따로 유지할 수 있습니다. 이 패키지에는 의존성이 없습니다.

<table>
<tr>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/product-dark.png"><img src="docs/images/product-light.png" width="200" alt="링크 routerdemo://products/2로 열린 상품 화면"></picture><br><sub><code>routerdemo://products/2</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/reviews-dark.png"><img src="docs/images/reviews-light.png" width="200" alt="링크 하나로 상품 화면 위에 push된 리뷰 화면"></picture><br><sub><code>…/products/2/reviews</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/cart-dark.png"><img src="docs/images/cart-light.png" width="200" alt="링크로 시트에 표시된 장바구니"></picture><br><sub><code>routerdemo://cart</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/sign-in-dark.png"><img src="docs/images/sign-in-light.png" width="200" alt="로그아웃 상태에서 주문 링크를 열면 로그인 시트가 표시됨"></picture><br><sub><code>…/account/orders/1001</code></sub></td>
</tr>
</table>

스크린샷은 iPhone 시뮬레이터에서 [예제 앱](Examples/RouterDemo)으로 찍은 것입니다. 각 화면은
아래 링크로 router가 도달한 상태입니다
([`scripts/capture-screens.sh`](scripts/capture-screens.sh)).

## 주요 기능

- **타입이 있는 라우트** — 화면은 연관 값을 가진 enum case이므로, 존재하지 않는 목적지는
  컴파일되지 않습니다.
- **스택과 시트를 하나의 상태로** — `router.entries`는 push된 모든 화면, 시트, 전체 화면 커버를
  나열합니다. 시트는 자체 내비게이션 스택을 가지며 다른 시트를 띄울 수 있습니다. 뒤로 가기
  버튼, 스와이프 뒤로 가기, 시트를 아래로 스와이프하는 동작은 router에 다시 반영됩니다.
- **상태 전체로 연결되는 딥 링크** — `shop://products/42`나
  `https://shop.example.com/products/42` 링크는 상품이 맨 위에 있는 카탈로그나 시트를 열 수
  있습니다. `/products/:id` 같은 패턴은 가장 구체적인 것부터 매칭되며, 공유용 경로도 같은
  패턴으로 만듭니다.
- **링크는 사용하기 전에 검사** — 길이, 세그먼트, 쿼리 개수 제한, 지정한 호스트에서만 `https`
  허용, `..` 세그먼트 불가, 제어 문자 불가, 타입이 있는 값은 크래시 대신 `nil`이 됩니다
  (`Int` 오버플로, `nan`, `inf`).
- **어떤 경로도 건너뛸 수 없는 가드** — 가드는 push, 시트, 딥 링크, 복원된 스냅샷,
  `NavigationLink`로 추가되는 모든 화면을 확인합니다. 로그인으로의 리디렉션은 요청을 보관하고,
  로그인한 뒤 `resumePending()`이 그 요청을 엽니다.
- **탭과 상태 복원** — `TabRouter`는 탭마다 스택을 하나씩 유지하고, 선택된 탭을 다시 선택하면
  루트까지 pop합니다. `routerStateRestoration(_:key:)`는 씬별로 상태를 저장하고, 복원할 때
  가드를 거치게 합니다.
- **테스트됨** — macOS와 iPhone 시뮬레이터에서 실행하는 Swift Testing 테스트 86개와, iOS 27
  시뮬레이터에서 예제 앱을 조작하는 UI 테스트 7개가 있습니다. push와 뒤로 가기, 세 화면
  깊이의 딥 링크, 장바구니 시트 위의 로그인 시트, 로그인 후 요청 재개를 다룹니다.

## 빠른 시작

**1. 패키지 추가**

Xcode에서 **File › Add Package Dependencies…**를 선택하고, 오른쪽 위 검색창에 저장소 URL을 붙여
넣으세요.

```text
https://github.com/muhittincamdali/SwiftRouter.git
```

**Dependency Rule**은 `2.0.0` 이상의 **Up to Next Major Version**으로 그대로 두고
**Add Package**를 클릭하세요. 다음 창에서 **SwiftRouter** 옆에 앱 타깃을 선택하고
**Add Package**를 다시 클릭하세요.

**2. 모듈 가져오기**

```swift
import SwiftRouter
```

이 줄은 router를 사용하는 각 Swift 파일의 맨 위, `import SwiftUI` 옆에 넣으세요.

**3. 사용하기**

새 Xcode 앱(**File › New › Project… › App**)에서 `ContentView.swift`의 내용을 모두 다음으로
바꾸세요.

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

**Run**(⌘R)을 누르세요. **Open item 1**은 화면을 push하고, **About**은 시트를 엽니다(아래로
스와이프하면 닫힙니다). **Open items 2 and 3**은 화면 두 개를 한 번에 push하며, 뒤로 가기
버튼은 한 번에 한 화면씩 돌아갑니다.

## 설치

### Swift Package Manager

저장소 URL은 `https://github.com/muhittincamdali/SwiftRouter.git`, 이 URL을 Xcode의
**File › Add Package Dependencies…**에 입력하거나 `Package.swift`의 `dependencies`에
추가하세요.

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

### 요구 사항

|        | 최소 버전                                         |
| ------ | ------------------------------------------------- |
| Swift  | 6.2(Xcode 26 이상)                                |
| 플랫폼 | iOS 17, macOS 14, tvOS 17, watchOS 10, visionOS 1 |

버전 2.0.0은 런타임에 문자열로 라우트를 찾던 1.0.0(2026년 2월)의 API를 대체합니다. 2026년
6월에 1.0.0 소스는 자리 표시자 코드로 교체되었습니다. 2.0.0은 Swift 6 언어 모드에 맞춰 새로
만들고 테스트한 router이며, SwiftUI-Navigation-Pro의 표시(presentation), 탭, 상태 저장 기능을
이어받았습니다. 변경 사항은 [CHANGELOG.md](CHANGELOG.md)에, 기존 API와 새 API의 대응은
[Migrating from version 1](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1)에
정리되어 있습니다.

## 사용법

아래 예시는
[`Examples/RouterDemo/RouterDemo/ReadmeSamples.swift`](Examples/RouterDemo/RouterDemo/ReadmeSamples.swift)에서
가져온 것입니다. 예제 앱과 테스트 스위트가 모두 이 파일을 컴파일하며, 테스트는 딥 링크와
로그인 예시를 실행합니다.

### 화면 이동

`RouterView` 안의 화면은 시트를 포함해 environment에서 router를 읽습니다.

```swift
@Environment(Router<AppRoute>.self) private var router
```

| 호출                            | 동작                                                                  |
| ------------------------------- | --------------------------------------------------------------------- |
| `push(_:)`, `push(contentsOf:)` | 최상위 스택에 화면을 하나 이상 push합니다                             |
| `present(_:style:)`             | 자체 스택을 가진 `.sheet` 또는 `.fullScreenCover`를 표시합니다        |
| `pop(_:)`, `popToRoot()`        | 최상위 스택에서 push된 화면을 pop합니다. 시트는 닫지 않습니다         |
| `popTo(_:)`                     | 시트를 가로질러 라우트가 마지막으로 나타난 위치까지 pop합니다         |
| `dismiss()`, `dismissAll()`     | 최상위 시트 또는 모든 시트를 닫습니다                                 |
| `reset()`                       | 모든 것을 닫고 루트 뷰까지 pop합니다                                  |
| `setEntries(_:)`                | 전체 상태를 교체합니다. 예: `[.push(.product(id: 3)), .sheet(.cart)]` |

화면을 추가하는 호출은 `.applied`, `.redirected`(가드가 다른 화면을 보여 줌),
`.cancelled`(가드가 거부함), `.rejected`(항목이 `maxDepth`개를 초과함, 기본값 64) 중 하나를
반환합니다.

### 딥 링크

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

`shop://products/42`와 `https://shop.example.com/products/42` 링크는 모두 상품 42가 맨 위에 있는
카탈로그를 열기 때문에, 뒤로 가기 버튼은 카탈로그로 이어집니다. 커스텀 스킴 URL에서는 호스트를
첫 번째 경로 세그먼트로 읽습니다. `onDeepLink`는 커스텀 스킴을 `onOpenURL`로, 유니버설 링크를
`onContinueUserActivity`로 받습니다. 스킴은 타깃의 **URL Types**에 등록하세요. 유니버설
링크에는 Associated Domains entitlement도 필요합니다.

핸들러는 값을 받아들일 수 없으면 `nil`을 반환하고, 그러면 다음으로 일치하는 패턴을 시도합니다.
어떤 패턴과도 일치하지 않거나 거부된 링크는 내비게이션 상태를 그대로 둡니다.

### 가드

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

로그아웃 상태에서 `shop://orders`는 로그인 시트를 보여 주고 요청을 보관합니다. 그러면 `signIn`이
시트를 주문 화면으로 교체합니다. 로그아웃한 뒤에는 `router.revalidate()`를 호출해 더 이상
허용되지 않는 화면을 제거하세요.

### 탭과 상태 복원

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

각 탭은 자체 스택을 유지하며, 선택된 탭을 다시 선택하면 루트까지 pop합니다.
`tabs.open(url, using: [.shop: shopLinks, .orders: orderLinks])`는 링크가 일치하는 첫 번째 탭에서
링크를 엽니다. 상태는 씬의 저장소에 저장되므로 창마다 자신의 상태를 유지하며, 시스템이
백그라운드에서 앱을 종료한 뒤에도 복원됩니다. 이를 위해 라우트는 `Codable`이어야 합니다.

## 링크 검사 방식

URL은 앱 바깥에서 오므로 `DeepLinks`는 어떤 패턴이 실행되기 전에 먼저 검사합니다.

| 입력                                                                      | 결과                                               |
| ------------------------------------------------------------------------- | -------------------------------------------------- |
| 2,048바이트보다 길거나, 세그먼트가 32개를 넘거나, 쿼리 항목이 32개를 넘음 | 거부됨. 길이를 가장 먼저 검사합니다                |
| `http`, 알 수 없는 스킴, 지정하지 않은 호스트의 `https`                   | 거부됨. `*.example.com`은 하위 도메인만 허용합니다 |
| URL에 포함된 사용자 이름 또는 비밀번호                                    | 거부됨                                             |
| `.` 또는 `..` 세그먼트(`%2e`로 쓴 것도 포함)                              | 거부됨, 해석하지 않음                              |
| `%2F`                                                                     | 하나의 세그먼트 안에 그대로 남음                   |
| 제어 문자, 양방향 서식 문자, UTF-8이 아닌 바이트                          | 거부됨                                             |
| `int` 또는 `double`로 읽은 `nan`, `inf`, `4.5`, `99999999999999999999`    | `nil`                                              |

제한은 `DeepLinkLimits`로 설정합니다. 이 패키지는 URL이나 라우트를 출력하거나 로그로 남기지
않습니다. 링크에 로그인 토큰이나 재설정 토큰이 들어 있을 수 있기 때문입니다.
[Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking)
아티클에 모든 규칙이 나와 있습니다.

## 예제 앱

[`Examples/RouterDemo`](Examples/RouterDemo)는 iOS와 macOS용 작은 쇼핑 앱입니다. Shop과 Account
탭, 리뷰가 있는 상품, 장바구니 시트, 로그인 가드 뒤에 있는 주문, `routerdemo://` 스킴의 딥
링크, 저장된 상태가 들어 있습니다. `Examples/RouterDemo/RouterDemo.xcodeproj`를 열고
**RouterDemo** 스킴과 iPhone 시뮬레이터 또는 **My Mac**을 선택한 다음 **Run**(⌘R)을 누르세요.
시뮬레이터에서 링크를 시험해 보려면 다음을 실행하세요.

```sh
xcrun simctl openurl booted "routerdemo://products/2/reviews"
```

**RouterDemoUITests** 타깃(iPhone 시뮬레이터에서 ⌘U)은 이 흐름을 화면에서 검사합니다.

## 문서

[문서](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/)는 모든 공개
타입을 다루며, 다음 아티클이 있습니다.

- [Getting started](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/gettingstarted)
- [Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking)
- [Guarding screens](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/guardingscreens)
- [Tabs and state restoration](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/tabsandstaterestoration)
- [Migrating from version 1](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1)

## 기여하기

버그 리포트와 pull request를 환영합니다. 테스트와 예제 앱을 실행하는 방법은
[CONTRIBUTING.md](CONTRIBUTING.md)에 설명되어 있습니다. 보안 문제는
[SECURITY.md](SECURITY.md)에 설명된 대로 비공개로 제보해 주세요.

## 라이선스

SwiftRouter는 MIT 라이선스로 배포됩니다. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
