<!-- i18n-source: README.md@b948148be6b8a4b9165602f99c57a96aa585850a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-light.svg" alt="SwiftRouter: Type-safe SwiftUI navigation: stacks, sheets, deep links, guards and tabs in one router."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml/badge.svg" alt="Estado de CI"></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-light.svg" alt="Última versión: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-light.svg" alt="Plataformas compatibles: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-light.svg" alt="Versión del lenguaje: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-light.svg" alt="Licencia: MIT"></picture></a>
</p>

<p align="center">
<a href="#inicio-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-es-light.svg" alt="Empezar"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-es-light.svg" alt="Documentación"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-es-light.svg" alt="Ejemplos"></picture></a>
</p>

> Esta es una traducción del README en inglés. Si hay diferencias, la versión en inglés es la vigente.

<!-- brand:end -->

SwiftRouter es un paquete de Swift para la navegación en apps de SwiftUI en iOS 17+, macOS 14+,
tvOS 17+, watchOS 10+ y visionOS 1+. Enumeras tus pantallas en un enum y un único `Router` guarda
todo el estado de navegación: las pantallas con push, los sheets y las cubiertas a pantalla
completa (full-screen cover) que hay encima, y las pantallas con push dentro de esos sheets. Los
deep links se corresponden con ese estado, los guards comprueban cada pantalla antes de que
aparezca y cada pestaña puede conservar su propio stack. El paquete no tiene dependencias.

<table>
<tr>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/product-dark.png"><img src="docs/images/product-light.png" width="200" alt="Una pantalla de producto abierta con el enlace routerdemo://products/2"></picture><br><sub><code>routerdemo://products/2</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/reviews-dark.png"><img src="docs/images/reviews-light.png" width="200" alt="La pantalla de reseñas con push sobre el producto mediante un solo enlace"></picture><br><sub><code>…/products/2/reviews</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/cart-dark.png"><img src="docs/images/cart-light.png" width="200" alt="El carrito presentado como sheet mediante un enlace"></picture><br><sub><code>routerdemo://cart</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/sign-in-dark.png"><img src="docs/images/sign-in-light.png" width="200" alt="Un enlace a un pedido sin sesión iniciada muestra el sheet de inicio de sesión"></picture><br><sub><code>…/account/orders/1001</code></sub></td>
</tr>
</table>

Las capturas proceden de la [app de ejemplo](Examples/RouterDemo) en un simulador de iPhone: cada
una es el estado al que llegó el router a partir del enlace que tiene debajo
([`scripts/capture-screens.sh`](scripts/capture-screens.sh)).

## Lo más destacado

- **Rutas tipadas** — las pantallas son casos de un enum con valores asociados, así que un
  destino que no existe no compila.
- **Un único estado para stacks y sheets** — `router.entries` enumera cada pantalla con push,
  cada sheet y cada cubierta a pantalla completa. Un sheet tiene su propio stack de navegación y
  puede presentar otro sheet. El botón de retroceso, el gesto de deslizar para volver y deslizar
  un sheet hacia abajo se reflejan de vuelta en el router.
- **Deep links a estados completos** — `shop://products/42` y
  `https://shop.example.com/products/42` pueden abrir el catálogo con el producto encima, o un
  sheet. Los patrones como `/products/:id` se comparan empezando por el más específico, y las
  rutas para compartir se construyen con los mismos patrones.
- **Los enlaces se comprueban antes de usarse** — límites de longitud, de segmentos y de
  parámetros de consulta, `https` solo en los hosts que indiques, sin segmentos `..`, sin
  caracteres de control, y valores tipados que son `nil` en lugar de provocar un fallo
  (desbordamiento de `Int`, `nan`, `inf`).
- **Guards que ninguna ruta se salta** — un guard ve cada pantalla añadida mediante un push, un
  sheet, un deep link, un snapshot restaurado o un `NavigationLink`. Una redirección al inicio de
  sesión conserva la petición, y `resumePending()` la abre después de iniciar sesión.
- **Pestañas y restauración del estado** — `TabRouter` guarda un stack por pestaña y vuelve a la
  raíz cuando se elige otra vez la pestaña seleccionada; `routerStateRestoration(_:key:)` guarda
  el estado por scene y lo pasa por los guards cuando vuelve.
- **Probado** — 86 tests de Swift Testing en macOS y en un simulador de iPhone, y 7 tests de UI
  que manejan la app de ejemplo en un simulador de iOS 27: push y volver, un deep link a tres
  pantallas de profundidad, el sheet de inicio de sesión sobre el sheet del carrito y la
  reanudación de la petición tras iniciar sesión.

## Inicio rápido

**1. Añade el paquete**

En Xcode, elige **File › Add Package Dependencies…** y pega la URL del repositorio en el campo de
búsqueda de la esquina superior derecha:

```text
https://github.com/muhittincamdali/SwiftRouter.git
```

Deja **Dependency Rule** en **Up to Next Major Version** desde `2.0.0` y haz clic en
**Add Package**. En la ventana siguiente, elige tu target de app junto a **SwiftRouter** y haz clic
de nuevo en **Add Package**.

**2. Importa el módulo**

```swift
import SwiftRouter
```

Pon esta línea al principio de cada archivo Swift que use el router, junto a `import SwiftUI`.

**3. Úsalo**

En una app nueva de Xcode (**File › New › Project… › App**), sustituye todo el contenido de
`ContentView.swift` por:

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

Pulsa **Run** (⌘R). **Open item 1** hace push de una pantalla, **About** abre un sheet
(deslízalo hacia abajo para cerrarlo) y **Open items 2 and 3** hace push de dos pantallas a la vez;
el botón de retroceso vuelve de una pantalla en una.

## Instalación

### Swift Package Manager

En Xcode, elige **File › Add Package Dependencies…** e introduce
`https://github.com/muhittincamdali/SwiftRouter.git`, o añádelo a las `dependencies` de tu
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

### Requisitos

|             | Mínimo                                            |
| ----------- | ------------------------------------------------- |
| Swift       | 6.2 (Xcode 26 o posterior)                        |
| Plataformas | iOS 17, macOS 14, tvOS 17, watchOS 10, visionOS 1 |

La versión 2.0.0 sustituye la API de la 1.0.0 (febrero de 2026), que buscaba las rutas por cadena
en tiempo de ejecución. En junio de 2026 el código fuente de la 1.0.0 se reemplazó por código de
relleno; la 2.0.0 es un router nuevo, creado y probado para el modo de lenguaje Swift 6, y asume
las funciones de presentación, pestañas y guardado de estado de SwiftUI-Navigation-Pro.
[CHANGELOG.md](CHANGELOG.md) enumera los cambios y
[Migrating from version 1](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1)
relaciona la API antigua con la nueva.

## Uso

Los ejemplos de abajo están copiados de
[`Examples/RouterDemo/RouterDemo/ReadmeSamples.swift`](Examples/RouterDemo/RouterDemo/ReadmeSamples.swift).
La app de ejemplo y la suite de tests compilan ese archivo, y los tests ejecutan los ejemplos de
deep links y de inicio de sesión.

### Navegar

Las pantallas dentro de un `RouterView`, sheets incluidos, leen el router del environment:

```swift
@Environment(Router<AppRoute>.self) private var router
```

| Llamada                         | Qué hace                                                                        |
| ------------------------------- | ------------------------------------------------------------------------------- |
| `push(_:)`, `push(contentsOf:)` | Hace push de una o más pantallas en el stack superior                           |
| `present(_:style:)`             | Muestra un `.sheet` o un `.fullScreenCover` con su propio stack                 |
| `pop(_:)`, `popToRoot()`        | Quita pantallas con push del stack superior; nunca cierra un sheet              |
| `popTo(_:)`                     | Retrocede hasta la última aparición de una ruta, atravesando sheets             |
| `dismiss()`, `dismissAll()`     | Cierra el sheet superior, o todos los sheets                                    |
| `reset()`                       | Lo cierra todo y vuelve a la vista raíz                                         |
| `setEntries(_:)`                | Sustituye todo el estado, por ejemplo `[.push(.product(id: 3)), .sheet(.cart)]` |

Cada llamada que añade pantallas devuelve `.applied`, `.redirected` (un guard mostró otra cosa),
`.cancelled` (un guard la rechazó) o `.rejected` (más de `maxDepth` entradas, 64 por defecto).

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

`shop://products/42` y `https://shop.example.com/products/42` abren ambos el catálogo con el
producto 42 encima, de modo que el botón de retroceso lleva al catálogo. En una URL con esquema
personalizado, el host se lee como el primer segmento de la ruta. `onDeepLink` recibe los esquemas
personalizados mediante `onOpenURL` y los universal links mediante `onContinueUserActivity`.
Registra el esquema en **URL Types** de tu target; los universal links necesitan además el
entitlement Associated Domains.

Un handler devuelve `nil` cuando un valor no es aceptable, y se prueba el siguiente patrón que
coincida. Un enlace que no coincide con ningún patrón, o que se rechaza, deja el estado de
navegación como está.

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

Sin sesión iniciada, `shop://orders` muestra el sheet de inicio de sesión y conserva la petición.
Después, `signIn` sustituye el sheet por la pantalla de pedidos. Tras cerrar sesión, llama a
`router.revalidate()` para quitar las pantallas que ya no están permitidas.

### Pestañas y restauración del estado

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

Cada pestaña conserva su propio stack, y elegir otra vez la pestaña seleccionada la devuelve a la
raíz. `tabs.open(url, using: [.shop: shopLinks, .orders: orderLinks])` abre un enlace en la primera
pestaña cuyos enlaces coinciden con él. El estado se guarda en el almacenamiento de la scene, así
que cada ventana conserva el suyo, y vuelve después de que el sistema cierre la app en segundo
plano. Para eso, las rutas deben ser `Codable`.

## Cómo se comprueban los enlaces

Una URL llega desde fuera de la app, así que `DeepLinks` la comprueba antes de ejecutar ningún
patrón:

| Entrada                                                                            | Resultado                                           |
| ---------------------------------------------------------------------------------- | --------------------------------------------------- |
| Más de 2048 bytes, más de 32 segmentos o más de 32 elementos de consulta           | Se rechaza; primero se comprueba la longitud        |
| `http`, un esquema desconocido, `https` en un host que no has indicado             | Se rechaza; `*.example.com` solo acepta subdominios |
| Un nombre de usuario o una contraseña en la URL                                    | Se rechaza                                          |
| Un segmento `.` o `..`, también escrito como `%2e`                                 | Se rechaza, no se resuelve                          |
| `%2F`                                                                              | Se queda dentro de un segmento                      |
| Caracteres de control, caracteres de formato bidireccional, bytes que no son UTF-8 | Se rechaza                                          |
| `nan`, `inf`, `4.5` o `99999999999999999999` leídos con `int` o `double`           | `nil`                                               |

Los límites se configuran con `DeepLinkLimits`. El paquete nunca imprime ni registra URLs ni
rutas; los enlaces pueden llevar tokens de inicio de sesión o de restablecimiento. El artículo
[Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking)
enumera todas las reglas.

## App de ejemplo

[`Examples/RouterDemo`](Examples/RouterDemo) es una pequeña tienda para iOS y macOS: pestañas Shop
y Account, productos con reseñas, un sheet de carrito, pedidos tras un guard de inicio de sesión,
deep links con el esquema `routerdemo://` y estado guardado. Abre
`Examples/RouterDemo/RouterDemo.xcodeproj`, elige el scheme **RouterDemo** y un simulador de
iPhone o **My Mac**, y pulsa **Run** (⌘R). Para probar un enlace en el simulador:

```sh
xcrun simctl openurl booted "routerdemo://products/2/reviews"
```

El target **RouterDemoUITests** (⌘U en un simulador de iPhone) comprueba los flujos en pantalla.

## Documentación

La [documentación](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/) cubre
cada tipo público, con estos artículos:

- [Getting started](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/gettingstarted)
- [Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking)
- [Guarding screens](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/guardingscreens)
- [Tabs and state restoration](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/tabsandstaterestoration)
- [Migrating from version 1](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1)

## Contribuir

Se agradecen los informes de errores y las pull requests; [CONTRIBUTING.md](CONTRIBUTING.md)
explica cómo ejecutar los tests y la app de ejemplo. Informa de los problemas de seguridad de
forma privada, como se describe en [SECURITY.md](SECURITY.md).

## Licencia

SwiftRouter se publica bajo la licencia MIT. Consulta [LICENSE](LICENSE).
