<!-- i18n-source: README.md@09ab6810d8d96e3ea94fe665de84ba5080b46572 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-light.svg" alt="SwiftRouter: Type-safe SwiftUI navigation: stacks, sheets, deep links, guards and tabs in one router."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml/badge.svg" alt="État de la CI"></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-light.svg" alt="Dernière version: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-light.svg" alt="Plateformes prises en charge: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-light.svg" alt="Version du langage: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-light.svg" alt="Licence: MIT"></picture></a>
</p>

<p align="center">
<a href="#démarrage-rapide"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-fr-light.svg" alt="Commencer"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-fr-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-fr-light.svg" alt="Exemples"></picture></a>
</p>

> Ceci est une traduction du README anglais. En cas de différence, la version anglaise fait foi.

<!-- brand:end -->

SwiftRouter est un paquet Swift pour la navigation dans les apps SwiftUI sur iOS 17+, macOS 14+,
tvOS 17+, watchOS 10+ et visionOS 1+. Vous listez vos écrans dans un enum, et un seul `Router`
conserve tout l’état de navigation : les écrans poussés, les sheets et les couvertures plein écran
(full-screen cover) qui les recouvrent, et les écrans poussés à l’intérieur de ces sheets. Les deep
links correspondent à cet état, les guards vérifient chaque écran avant qu’il n’apparaisse, et
chaque onglet peut garder son propre stack. Le paquet n’a aucune dépendance.

<table>
<tr>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/product-dark.png"><img src="docs/images/product-light.png" width="200" alt="Un écran produit ouvert par le lien routerdemo://products/2"></picture><br><sub><code>routerdemo://products/2</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/reviews-dark.png"><img src="docs/images/reviews-light.png" width="200" alt="L’écran des avis poussé sur le produit par un seul lien"></picture><br><sub><code>…/products/2/reviews</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/cart-dark.png"><img src="docs/images/cart-light.png" width="200" alt="Le panier présenté comme sheet par un lien"></picture><br><sub><code>routerdemo://cart</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/sign-in-dark.png"><img src="docs/images/sign-in-light.png" width="200" alt="Un lien vers une commande, sans être connecté, affiche le sheet de connexion"></picture><br><sub><code>…/account/orders/1001</code></sub></td>
</tr>
</table>

Les captures d’écran viennent de l’[app d’exemple](Examples/RouterDemo) sur un simulateur
d’iPhone : chacune est l’état atteint par le router à partir du lien qui se trouve en dessous
([`scripts/capture-screens.sh`](scripts/capture-screens.sh)).

## Points forts

- **Routes typées** — les écrans sont des cas d’un enum avec des valeurs associées ; une
  destination qui n’existe pas ne compile donc pas.
- **Un seul état pour les stacks et les sheets** — `router.entries` liste chaque écran poussé,
  chaque sheet et chaque couverture plein écran. Un sheet a son propre stack de navigation et peut
  en présenter un autre. Le bouton retour, le balayage pour revenir en arrière et le balayage vers
  le bas sur un sheet sont répercutés dans le router.
- **Des deep links vers des états entiers** — `shop://products/42` et
  `https://shop.example.com/products/42` peuvent ouvrir le catalogue avec le produit au-dessus, ou
  un sheet. Les motifs comme `/products/:id` sont comparés du plus spécifique au moins spécifique,
  et les chemins à partager sont construits à partir des mêmes motifs.
- **Les liens sont vérifiés avant d’être utilisés** — limites de longueur, de segments et de
  paramètres de requête, `https` uniquement sur les hôtes que vous indiquez, aucun segment `..`,
  aucun caractère de contrôle, et des valeurs typées qui valent `nil` au lieu de provoquer un
  plantage (dépassement de capacité d’`Int`, `nan`, `inf`).
- **Des guards qu’aucun chemin ne contourne** — un guard voit chaque écran ajouté par un push, un
  sheet, un deep link, un snapshot restauré ou un `NavigationLink`. Une redirection vers la
  connexion conserve la requête, et `resumePending()` l’ouvre une fois connecté.
- **Onglets et restauration de l’état** — `TabRouter` garde un stack par onglet et revient à la
  racine quand on sélectionne à nouveau l’onglet actif ; `routerStateRestoration(_:key:)`
  enregistre l’état par scene et le fait repasser par les guards à son retour.
- **Testé** — 86 tests Swift Testing sur macOS et sur un simulateur d’iPhone, et 7 tests d’UI qui
  pilotent l’app d’exemple sur un simulateur iOS 27 : push et retour, un deep link à trois écrans
  de profondeur, le sheet de connexion au-dessus du sheet du panier, et la reprise de la requête
  après la connexion.

## Démarrage rapide

**1. Ajouter le paquet**

Dans Xcode, choisissez **File › Add Package Dependencies…** et collez l’URL du dépôt dans le champ
de recherche en haut à droite :

```text
https://github.com/muhittincamdali/SwiftRouter.git
```

Laissez **Dependency Rule** sur **Up to Next Major Version** à partir de `2.0.0` et cliquez sur
**Add Package**. Dans la fenêtre suivante, choisissez la cible de votre app à côté de
**SwiftRouter** et cliquez de nouveau sur **Add Package**.

**2. Importer le module**

```swift
import SwiftRouter
```

Placez cette ligne en haut de chaque fichier Swift qui utilise le router, à côté de
`import SwiftUI`.

**3. L’utiliser**

Dans une nouvelle app Xcode (**File › New › Project… › App**), remplacez tout le contenu de
`ContentView.swift` par :

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

Appuyez sur **Run** (⌘R). **Open item 1** pousse un écran, **About** ouvre un sheet (faites-le
glisser vers le bas pour le fermer) et **Open items 2 and 3** pousse deux écrans à la fois ; le
bouton retour revient d’un écran à la fois.

## Installation

### Swift Package Manager

Dans Xcode, choisissez **File › Add Package Dependencies…** et saisissez
`https://github.com/muhittincamdali/SwiftRouter.git`, ou ajoutez-le aux `dependencies` de votre
`Package.swift` :

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

### Prérequis

|             | Minimum                                           |
| ----------- | ------------------------------------------------- |
| Swift       | 6.2 (Xcode 26 ou version ultérieure)              |
| Plateformes | iOS 17, macOS 14, tvOS 17, watchOS 10, visionOS 1 |

La version 2.0.0 remplace l’API de la 1.0.0 (février 2026), qui recherchait les routes par chaîne à
l’exécution. En juin 2026, les sources de la 1.0.0 ont été remplacées par du code de substitution ;
la 2.0.0 est un nouveau router, conçu et testé pour le mode de langage Swift 6, qui reprend les
fonctions de présentation, d’onglets et de sauvegarde d’état de SwiftUI-Navigation-Pro.
[CHANGELOG.md](CHANGELOG.md) liste les changements et
[Migrating from version 1](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1)
fait correspondre l’ancienne API à la nouvelle.

## Utilisation

Les exemples ci-dessous sont copiés depuis
[`Examples/RouterDemo/RouterDemo/ReadmeSamples.swift`](Examples/RouterDemo/RouterDemo/ReadmeSamples.swift).
L’app d’exemple et la suite de tests compilent toutes deux ce fichier, et les tests exécutent les
exemples de deep link et de connexion.

### Naviguer

Les écrans à l’intérieur d’une `RouterView`, sheets compris, lisent le router depuis l’environment :

```swift
@Environment(Router<AppRoute>.self) private var router
```

| Appel                           | Effet                                                                       |
| ------------------------------- | --------------------------------------------------------------------------- |
| `push(_:)`, `push(contentsOf:)` | Pousse un ou plusieurs écrans sur le stack le plus haut                     |
| `present(_:style:)`             | Affiche un `.sheet` ou un `.fullScreenCover` avec son propre stack          |
| `pop(_:)`, `popToRoot()`        | Dépile les écrans poussés du stack le plus haut ; ne ferme jamais un sheet  |
| `popTo(_:)`                     | Dépile jusqu’à la dernière occurrence d’une route, en traversant les sheets |
| `dismiss()`, `dismissAll()`     | Ferme le sheet le plus haut, ou tous les sheets                             |
| `reset()`                       | Ferme tout et revient à la vue racine                                       |
| `setEntries(_:)`                | Remplace tout l’état, par exemple `[.push(.product(id: 3)), .sheet(.cart)]` |

Chaque appel qui ajoute des écrans renvoie `.applied`, `.redirected` (un guard a affiché autre
chose), `.cancelled` (un guard a refusé) ou `.rejected` (plus de `maxDepth` entrées, 64 par
défaut).

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

`shop://products/42` et `https://shop.example.com/products/42` ouvrent tous deux le catalogue avec
le produit 42 au-dessus, si bien que le bouton retour mène au catalogue. Dans une URL à schéma
personnalisé, l’hôte est lu comme le premier segment du chemin. `onDeepLink` reçoit les schémas
personnalisés par `onOpenURL` et les universal links par `onContinueUserActivity`. Enregistrez le
schéma sous **URL Types** dans votre cible ; les universal links nécessitent aussi l’entitlement
Associated Domains.

Un handler renvoie `nil` lorsqu’une valeur n’est pas acceptable, et le motif correspondant suivant
est essayé. Un lien qui ne correspond à aucun motif, ou qui est refusé, laisse l’état de
navigation tel quel.

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

Tant que l’utilisateur est déconnecté, `shop://orders` affiche le sheet de connexion et conserve la
requête. `signIn` remplace ensuite le sheet par l’écran des commandes. Après la déconnexion,
appelez `router.revalidate()` pour retirer les écrans qui ne sont plus autorisés.

### Onglets et restauration de l’état

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

Chaque onglet garde son propre stack, et sélectionner à nouveau l’onglet actif le ramène à la
racine. `tabs.open(url, using: [.shop: shopLinks, .orders: orderLinks])` ouvre un lien dans le
premier onglet dont les liens lui correspondent. L’état est enregistré dans le stockage de la
scene : chaque fenêtre garde donc le sien, et il revient après que le système a arrêté l’app en
arrière-plan. Pour cela, les routes doivent être `Codable`.

## Comment les liens sont vérifiés

Une URL vient de l’extérieur de l’app ; `DeepLinks` la vérifie donc avant l’exécution de tout
motif :

| Entrée                                                                                            | Résultat                                                 |
| ------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| Plus de 2 048 octets, plus de 32 segments ou plus de 32 éléments de requête                       | Refusé ; la longueur est vérifiée en premier             |
| `http`, un schéma inconnu, `https` sur un hôte que vous n’avez pas indiqué                        | Refusé ; `*.example.com` n’accepte que les sous-domaines |
| Un nom d’utilisateur ou un mot de passe dans l’URL                                                | Refusé                                                   |
| Un segment `.` ou `..`, y compris écrit `%2e`                                                     | Refusé, non résolu                                       |
| `%2F`                                                                                             | Reste à l’intérieur d’un segment                         |
| Caractères de contrôle, caractères de formatage bidirectionnel, octets qui ne sont pas de l’UTF-8 | Refusé                                                   |
| `nan`, `inf`, `4.5` ou `99999999999999999999` lus avec `int` ou `double`                          | `nil`                                                    |

Les limites se règlent avec `DeepLinkLimits`. Le paquet n’affiche ni n’enregistre jamais les URL ni
les routes ; les liens peuvent contenir des jetons de connexion ou de réinitialisation. L’article
[Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking)
liste toutes les règles.

## App d’exemple

[`Examples/RouterDemo`](Examples/RouterDemo) est une petite boutique pour iOS et macOS : un onglet
Shop et un onglet Account, des produits avec avis, un sheet de panier, des commandes derrière un
guard de connexion, des deep links sur le schéma `routerdemo://` et un état enregistré. Ouvrez
`Examples/RouterDemo/RouterDemo.xcodeproj`, choisissez le scheme **RouterDemo** et un simulateur
d’iPhone ou **My Mac**, puis appuyez sur **Run** (⌘R). Pour essayer un lien dans le simulateur :

```sh
xcrun simctl openurl booted "routerdemo://products/2/reviews"
```

La cible **RouterDemoUITests** (⌘U sur un simulateur d’iPhone) vérifie les parcours à l’écran.

## Documentation

La [documentation](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/)
couvre chaque type public, avec ces articles :

- [Getting started](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/gettingstarted)
- [Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking)
- [Guarding screens](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/guardingscreens)
- [Tabs and state restoration](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/tabsandstaterestoration)
- [Migrating from version 1](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1)

## Contribuer

Les rapports de bogues et les pull requests sont les bienvenus ; [CONTRIBUTING.md](CONTRIBUTING.md)
explique comment lancer les tests et l’app d’exemple. Signalez les problèmes de sécurité en privé,
comme indiqué dans [SECURITY.md](SECURITY.md).

## Licence

SwiftRouter est publié sous licence MIT. Voir [LICENSE](LICENSE).
