<!-- i18n-source: README.md@b948148be6b8a4b9165602f99c57a96aa585850a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-light.svg" alt="SwiftRouter: Type-safe SwiftUI navigation: stacks, sheets, deep links, guards and tabs in one router."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml/badge.svg" alt="Статус CI"></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-light.svg" alt="Последняя версия: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-light.svg" alt="Поддерживаемые платформы: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-light.svg" alt="Версия языка: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-light.svg" alt="Лицензия: MIT"></picture></a>
</p>

<p align="center">
<a href="#быстрый-старт"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-ru-light.svg" alt="Начать"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-ru-light.svg" alt="Документация"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-ru-light.svg" alt="Примеры"></picture></a>
</p>

> Это перевод README на английском языке. Если они расходятся, актуальна английская версия.

<!-- brand:end -->

SwiftRouter — это Swift-пакет для навигации в приложениях SwiftUI на iOS 17+, macOS 14+, tvOS 17+,
watchOS 10+ и visionOS 1+. Вы перечисляете экраны в enum, а один `Router` хранит всё состояние
навигации: экраны, добавленные через push, sheet и full-screen cover поверх них и экраны,
добавленные через push внутри этих sheet. Deep links сопоставляются с этим состоянием, guards
проверяют каждый экран до его появления, а у каждой вкладки может быть свой стек. У пакета нет
зависимостей.

<table>
<tr>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/product-dark.png"><img src="docs/images/product-light.png" width="200" alt="Экран товара, открытый по ссылке routerdemo://products/2"></picture><br><sub><code>routerdemo://products/2</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/reviews-dark.png"><img src="docs/images/reviews-light.png" width="200" alt="Экран отзывов, добавленный поверх товара одной ссылкой"></picture><br><sub><code>…/products/2/reviews</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/cart-dark.png"><img src="docs/images/cart-light.png" width="200" alt="Корзина, показанная по ссылке как sheet"></picture><br><sub><code>routerdemo://cart</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/sign-in-dark.png"><img src="docs/images/sign-in-light.png" width="200" alt="Ссылка на заказ без выполненного входа показывает sheet входа"></picture><br><sub><code>…/account/orders/1001</code></sub></td>
</tr>
</table>

Скриншоты сделаны в [примере приложения](Examples/RouterDemo) на симуляторе iPhone: каждый
показывает состояние, до которого router дошёл по ссылке под ним
([`scripts/capture-screens.sh`](scripts/capture-screens.sh)).

## Основные возможности

- **Типизированные маршруты** — экраны — это case перечисления со связанными значениями, поэтому
  несуществующий пункт назначения не скомпилируется.
- **Одно состояние для стеков и sheet** — `router.entries` перечисляет каждый экран, добавленный
  через push, каждый sheet и каждый full-screen cover. У sheet есть собственный навигационный
  стек, и он может показать другой sheet. Кнопка «Назад», свайп назад и свайп вниз по sheet
  записываются обратно в router.
- **Deep links на целые состояния** — `shop://products/42` и
  `https://shop.example.com/products/42` могут открыть каталог с товаром сверху или sheet.
  Шаблоны вроде `/products/:id` сопоставляются, начиная с самого конкретного, а пути для
  отправки другим строятся из тех же шаблонов.
- **Ссылки проверяются до использования** — ограничения на длину, число сегментов и параметров
  запроса, `https` только на указанных вами хостах, никаких сегментов `..`, никаких управляющих
  символов, а типизированные значения становятся `nil` вместо аварийного завершения
  (переполнение `Int`, `nan`, `inf`).
- **Guards, которые не обойти** — guard видит каждый экран, добавленный через push, sheet,
  deep link, восстановленный снимок состояния или `NavigationLink`. Перенаправление на вход
  сохраняет запрос, а `resumePending()` открывает его после входа.
- **Вкладки и восстановление состояния** — `TabRouter` хранит по одному стеку на вкладку и
  возвращается к корню, когда выбранную вкладку выбирают снова; `routerStateRestoration(_:key:)`
  сохраняет состояние для каждой scene и при возврате пропускает его через guards.
- **Протестировано** — 86 тестов Swift Testing на macOS и на симуляторе iPhone и 7 UI-тестов,
  которые управляют примером приложения на симуляторе iOS 27: push и возврат, deep link на
  глубину в три экрана, sheet входа поверх sheet корзины и продолжение запроса после входа.

## Быстрый старт

**1. Добавьте пакет**

В Xcode выберите **File › Add Package Dependencies…** и вставьте адрес репозитория в поле поиска
в правом верхнем углу:

```text
https://github.com/muhittincamdali/SwiftRouter.git
```

Оставьте **Dependency Rule** равным **Up to Next Major Version** от `2.0.0` и нажмите
**Add Package**. В следующем окне выберите рядом с **SwiftRouter** таргет вашего приложения и
снова нажмите **Add Package**.

**2. Импортируйте модуль**

```swift
import SwiftRouter
```

Поставьте эту строку в начало каждого Swift-файла, который использует router, рядом с
`import SwiftUI`.

**3. Используйте**

В новом приложении Xcode (**File › New › Project… › App**) замените всё содержимое
`ContentView.swift` на:

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

Нажмите **Run** (⌘R). **Open item 1** выполняет push экрана, **About** открывает sheet (смахните
его вниз, чтобы закрыть), а **Open items 2 and 3** выполняет push сразу двух экранов; кнопка
«Назад» возвращает по одному экрану.

## Установка

### Swift Package Manager

В Xcode выберите **File › Add Package Dependencies…** и введите
`https://github.com/muhittincamdali/SwiftRouter.git`, либо добавьте его в `dependencies` вашего
`Package.swift`:

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

### Требования

|           | Минимум                                           |
| --------- | ------------------------------------------------- |
| Swift     | 6.2 (Xcode 26 или новее)                          |
| Платформы | iOS 17, macOS 14, tvOS 17, watchOS 10, visionOS 1 |

Версия 2.0.0 заменяет API версии 1.0.0 (февраль 2026 года), которая искала маршруты по строке во
время выполнения. В июне 2026 года исходный код 1.0.0 заменили кодом-заглушкой; 2.0.0 — это новый
router, написанный и протестированный для языкового режима Swift 6, который перенимает
возможности показа экранов, вкладок и сохранения состояния из SwiftUI-Navigation-Pro. Изменения
перечислены в [CHANGELOG.md](CHANGELOG.md), а
[Migrating from version 1](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1)
сопоставляет старый API с новым.

## Использование

Примеры ниже скопированы из
[`Examples/RouterDemo/RouterDemo/ReadmeSamples.swift`](Examples/RouterDemo/RouterDemo/ReadmeSamples.swift).
Пример приложения и набор тестов компилируют этот файл, а тесты выполняют примеры с deep link и
входом.

### Навигация

Экраны внутри `RouterView`, включая sheet, читают router из environment:

```swift
@Environment(Router<AppRoute>.self) private var router
```

| Вызов                           | Что делает                                                                                |
| ------------------------------- | ----------------------------------------------------------------------------------------- |
| `push(_:)`, `push(contentsOf:)` | Выполняет push одного или нескольких экранов в верхний стек                               |
| `present(_:style:)`             | Показывает `.sheet` или `.fullScreenCover` с собственным стеком                           |
| `pop(_:)`, `popToRoot()`        | Выполняет pop экранов, добавленных через push в верхнем стеке; sheet никогда не закрывает |
| `popTo(_:)`                     | Возвращается к последнему вхождению маршрута, проходя через sheet                         |
| `dismiss()`, `dismissAll()`     | Закрывает верхний sheet или все sheet                                                     |
| `reset()`                       | Закрывает всё и возвращается к корневому представлению                                    |
| `setEntries(_:)`                | Заменяет всё состояние, например `[.push(.product(id: 3)), .sheet(.cart)]`                |

Каждый вызов, добавляющий экраны, возвращает `.applied`, `.redirected` (guard показал что-то
другое), `.cancelled` (guard отказал) или `.rejected` (больше `maxDepth` записей; по умолчанию 64).

### Deep links

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

`shop://products/42` и `https://shop.example.com/products/42` открывают каталог с товаром 42
сверху, поэтому кнопка «Назад» ведёт в каталог. В URL с пользовательской схемой хост читается как
первый сегмент пути. `onDeepLink` получает пользовательские схемы через `onOpenURL`, а universal
links — через `onContinueUserActivity`. Зарегистрируйте схему в разделе **URL Types** вашего
таргета; для universal links также нужен entitlement Associated Domains.

Handler возвращает `nil`, если значение недопустимо, и тогда пробуется следующий подходящий
шаблон. Ссылка, которая не подходит ни под один шаблон или отклонена, оставляет состояние
навигации как есть.

### Guards

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

Пока пользователь не вошёл, `shop://orders` показывает sheet входа и сохраняет запрос. Затем
`signIn` заменяет sheet экраном заказов. После выхода вызовите `router.revalidate()`, чтобы убрать
экраны, которые больше не разрешены.

### Вкладки и восстановление состояния

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

Каждая вкладка хранит собственный стек, а повторный выбор выбранной вкладки возвращает её к корню.
`tabs.open(url, using: [.shop: shopLinks, .orders: orderLinks])` открывает ссылку в первой вкладке,
чьи ссылки ей соответствуют. Состояние сохраняется в хранилище scene, поэтому у каждого окна своё,
и оно возвращается после того, как система завершила приложение в фоне. Для этого маршруты должны
быть `Codable`.

## Как проверяются ссылки

URL приходит извне приложения, поэтому `DeepLinks` проверяет его до запуска любого шаблона:

| Вход                                                                                 | Результат                                               |
| ------------------------------------------------------------------------------------ | ------------------------------------------------------- |
| Длиннее 2048 байт, больше 32 сегментов или больше 32 элементов запроса               | Отклоняется; длина проверяется первой                   |
| `http`, неизвестная схема, `https` на хосте, которого нет в вашем списке             | Отклоняется; `*.example.com` принимает только поддомены |
| Имя пользователя или пароль в URL                                                    | Отклоняется                                             |
| Сегмент `.` или `..`, в том числе записанный как `%2e`                               | Отклоняется, не разрешается                             |
| `%2F`                                                                                | Остаётся внутри одного сегмента                         |
| Управляющие символы, символы двунаправленного форматирования, байты не в UTF-8       | Отклоняется                                             |
| `nan`, `inf`, `4.5` или `99999999999999999999`, прочитанные через `int` или `double` | `nil`                                                   |

Ограничения задаются через `DeepLinkLimits`. Пакет никогда не выводит и не логирует URL и
маршруты: ссылки могут содержать токены входа или сброса. Статья
[Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking)
перечисляет все правила.

## Пример приложения

[`Examples/RouterDemo`](Examples/RouterDemo) — небольшой магазин для iOS и macOS: вкладки Shop и
Account, товары с отзывами, sheet корзины, заказы за guard входа, deep links по схеме
`routerdemo://` и сохранённое состояние. Откройте `Examples/RouterDemo/RouterDemo.xcodeproj`,
выберите схему **RouterDemo** и симулятор iPhone или **My Mac** и нажмите **Run** (⌘R). Чтобы
проверить ссылку на симуляторе:

```sh
xcrun simctl openurl booted "routerdemo://products/2/reviews"
```

Таргет **RouterDemoUITests** (⌘U на симуляторе iPhone) проверяет эти сценарии на экране.

## Документация

[Документация](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/) охватывает
все публичные типы и включает такие статьи:

- [Getting started](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/gettingstarted)
- [Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking)
- [Guarding screens](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/guardingscreens)
- [Tabs and state restoration](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/tabsandstaterestoration)
- [Migrating from version 1](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1)

## Участие в разработке

Отчёты об ошибках и pull request приветствуются; как запускать тесты и пример приложения,
объясняет [CONTRIBUTING.md](CONTRIBUTING.md). О проблемах безопасности сообщайте конфиденциально,
как описано в [SECURITY.md](SECURITY.md).

## Лицензия

SwiftRouter распространяется по лицензии MIT. Подробнее — в файле [LICENSE](LICENSE).
