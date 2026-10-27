<!-- i18n-source: README.md@b948148be6b8a4b9165602f99c57a96aa585850a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-light.svg" alt="SwiftRouter: Type-safe SwiftUI navigation: stacks, sheets, deep links, guards and tabs in one router."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml/badge.svg" alt="Status da CI"></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-light.svg" alt="Versão mais recente: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-light.svg" alt="Plataformas compatíveis: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-light.svg" alt="Versão da linguagem: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-light.svg" alt="Licença: MIT"></picture></a>
</p>

<p align="center">
<a href="#início-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-pt-BR-light.svg" alt="Começar"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-pt-BR-light.svg" alt="Documentação"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-pt-BR-light.svg" alt="Exemplos"></picture></a>
</p>

> Esta é uma tradução do README em inglês. Se houver diferença, vale a versão em inglês.

<!-- brand:end -->

SwiftRouter é um pacote Swift para navegação em apps SwiftUI em iOS 17+, macOS 14+, tvOS 17+,
watchOS 10+ e visionOS 1+. Você lista suas telas em um enum, e um único `Router` guarda todo o
estado de navegação: as telas empilhadas com push, os sheets e as coberturas de tela cheia
(full-screen cover) sobre elas, e as telas empilhadas dentro desses sheets. Os deep links são
mapeados para esse estado, os guards verificam cada tela antes de ela aparecer e cada aba pode
manter o próprio stack. O pacote não tem dependências.

<table>
<tr>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/product-dark.png"><img src="docs/images/product-light.png" width="200" alt="Uma tela de produto aberta pelo link routerdemo://products/2"></picture><br><sub><code>routerdemo://products/2</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/reviews-dark.png"><img src="docs/images/reviews-light.png" width="200" alt="A tela de avaliações empilhada sobre o produto por um único link"></picture><br><sub><code>…/products/2/reviews</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/cart-dark.png"><img src="docs/images/cart-light.png" width="200" alt="O carrinho apresentado como sheet por um link"></picture><br><sub><code>routerdemo://cart</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/sign-in-dark.png"><img src="docs/images/sign-in-light.png" width="200" alt="Um link para um pedido, sem sessão iniciada, mostra o sheet de login"></picture><br><sub><code>…/account/orders/1001</code></sub></td>
</tr>
</table>

As capturas de tela vêm do [app de exemplo](Examples/RouterDemo) em um simulador de iPhone: cada
uma é o estado a que o router chegou a partir do link abaixo dela
([`scripts/capture-screens.sh`](scripts/capture-screens.sh)).

## Destaques

- **Rotas tipadas** — as telas são cases de um enum com valores associados, então um destino que
  não existe não compila.
- **Um único estado para stacks e sheets** — `router.entries` lista cada tela empilhada, cada sheet
  e cada cobertura de tela cheia. Um sheet tem o próprio stack de navegação e pode apresentar
  outro sheet. O botão voltar, o gesto de deslizar para voltar e o gesto de deslizar um sheet para
  baixo são gravados de volta no router.
- **Deep links para estados inteiros** — `shop://products/42` e
  `https://shop.example.com/products/42` podem abrir o catálogo com o produto por cima, ou um
  sheet. Padrões como `/products/:id` são comparados do mais específico para o menos específico, e
  os caminhos para compartilhar são montados a partir dos mesmos padrões.
- **Links são verificados antes de serem usados** — limites de tamanho, de segmentos e de
  parâmetros de consulta, `https` apenas nos hosts que você listar, sem segmentos `..`, sem
  caracteres de controle e valores tipados que viram `nil` em vez de causar uma falha (estouro de
  `Int`, `nan`, `inf`).
- **Guards que nenhum caminho ignora** — um guard vê toda tela adicionada por push, sheet, deep
  link, snapshot restaurado ou `NavigationLink`. Um redirecionamento para o login guarda a
  requisição, e `resumePending()` a abre depois do login.
- **Abas e restauração de estado** — `TabRouter` mantém um stack por aba e volta à raiz quando a
  aba selecionada é escolhida de novo; `routerStateRestoration(_:key:)` salva o estado por scene e
  o envia pelos guards quando ele volta.
- **Testado** — 86 testes do Swift Testing no macOS e em um simulador de iPhone, e 7 testes de UI
  que controlam o app de exemplo em um simulador do iOS 27: push e voltar, um deep link a três
  telas de profundidade, o sheet de login sobre o sheet do carrinho e a retomada da requisição
  depois do login.

## Início rápido

**1. Adicione o pacote**

No Xcode, escolha **File › Add Package Dependencies…** e cole a URL do repositório no campo de
busca no canto superior direito:

```text
https://github.com/muhittincamdali/SwiftRouter.git
```

Deixe **Dependency Rule** em **Up to Next Major Version** a partir de `2.0.0` e clique em
**Add Package**. Na janela seguinte, escolha o target do seu app ao lado de **SwiftRouter** e
clique em **Add Package** de novo.

**2. Importe o módulo**

```swift
import SwiftRouter
```

Coloque esta linha no topo de cada arquivo Swift que usa o router, ao lado de `import SwiftUI`.

**3. Use**

Em um app novo do Xcode (**File › New › Project… › App**), substitua todo o conteúdo de
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

Pressione **Run** (⌘R). **Open item 1** faz push de uma tela, **About** abre um sheet (deslize-o
para baixo para fechar) e **Open items 2 and 3** faz push de duas telas de uma vez; o botão voltar
retorna uma tela por vez.

## Instalação

### Swift Package Manager

No Xcode, escolha **File › Add Package Dependencies…** e informe
`https://github.com/muhittincamdali/SwiftRouter.git`, ou adicione-o às `dependencies` do seu
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
| Swift       | 6.2 (Xcode 26 ou posterior)                       |
| Plataformas | iOS 17, macOS 14, tvOS 17, watchOS 10, visionOS 1 |

A versão 2.0.0 substitui a API da 1.0.0 (fevereiro de 2026), que procurava as rotas por string em
tempo de execução. Em junho de 2026, o código-fonte da 1.0.0 foi substituído por código
provisório; a 2.0.0 é um router novo, criado e testado para o modo de linguagem Swift 6, e
incorpora os recursos de apresentação, abas e salvamento de estado do SwiftUI-Navigation-Pro. O
[CHANGELOG.md](CHANGELOG.md) lista as mudanças e
[Migrating from version 1](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1)
relaciona a API antiga com a nova.

## Uso

Os exemplos abaixo foram copiados de
[`Examples/RouterDemo/RouterDemo/ReadmeSamples.swift`](Examples/RouterDemo/RouterDemo/ReadmeSamples.swift).
O app de exemplo e a suíte de testes compilam esse arquivo, e os testes executam os exemplos de
deep link e de login.

### Navegar

As telas dentro de uma `RouterView`, sheets inclusos, leem o router do environment:

```swift
@Environment(Router<AppRoute>.self) private var router
```

| Chamada                         | O que faz                                                                      |
| ------------------------------- | ------------------------------------------------------------------------------ |
| `push(_:)`, `push(contentsOf:)` | Faz push de uma ou mais telas no stack mais acima                              |
| `present(_:style:)`             | Mostra um `.sheet` ou um `.fullScreenCover` com o próprio stack                |
| `pop(_:)`, `popToRoot()`        | Remove telas empilhadas do stack mais acima; nunca fecha um sheet              |
| `popTo(_:)`                     | Volta até a última ocorrência de uma rota, atravessando sheets                 |
| `dismiss()`, `dismissAll()`     | Fecha o sheet mais acima, ou todos os sheets                                   |
| `reset()`                       | Fecha tudo e volta à view raiz                                                 |
| `setEntries(_:)`                | Substitui todo o estado, por exemplo `[.push(.product(id: 3)), .sheet(.cart)]` |

Cada chamada que adiciona telas retorna `.applied`, `.redirected` (um guard mostrou outra coisa),
`.cancelled` (um guard recusou) ou `.rejected` (mais de `maxDepth` entradas, 64 por padrão).

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

`shop://products/42` e `https://shop.example.com/products/42` abrem ambos o catálogo com o produto
42 por cima, então o botão voltar leva ao catálogo. Em uma URL com esquema personalizado, o host é
lido como o primeiro segmento do caminho. `onDeepLink` recebe esquemas personalizados por
`onOpenURL` e universal links por `onContinueUserActivity`. Registre o esquema em **URL Types** no
seu target; universal links também exigem o entitlement Associated Domains.

Um handler retorna `nil` quando um valor não é aceitável, e o próximo padrão que corresponder é
tentado. Um link que não corresponde a nenhum padrão, ou que é recusado, deixa o estado de
navegação como está.

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

Sem sessão iniciada, `shop://orders` mostra o sheet de login e guarda a requisição. Depois,
`signIn` substitui o sheet pela tela de pedidos. Depois de encerrar a sessão, chame
`router.revalidate()` para remover as telas que não são mais permitidas.

### Abas e restauração de estado

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

Cada aba mantém o próprio stack, e escolher de novo a aba selecionada volta à raiz.
`tabs.open(url, using: [.shop: shopLinks, .orders: orderLinks])` abre um link na primeira aba cujos
links correspondem a ele. O estado é salvo no armazenamento da scene, então cada janela mantém o
seu, e ele volta depois que o sistema encerra o app em segundo plano. Para isso, as rotas precisam
ser `Codable`.

## Como os links são verificados

Uma URL vem de fora do app, então `DeepLinks` a verifica antes de qualquer padrão ser executado:

| Entrada                                                                                | Resultado                                           |
| -------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Mais de 2.048 bytes, mais de 32 segmentos ou mais de 32 itens de consulta              | Recusada; o tamanho é verificado primeiro           |
| `http`, um esquema desconhecido, `https` em um host que você não listou                | Recusada; `*.example.com` aceita apenas subdomínios |
| Um nome de usuário ou senha na URL                                                     | Recusada                                            |
| Um segmento `.` ou `..`, inclusive escrito como `%2e`                                  | Recusada, não resolvida                             |
| `%2F`                                                                                  | Permanece dentro de um segmento                     |
| Caracteres de controle, caracteres de formatação bidirecional, bytes que não são UTF-8 | Recusada                                            |
| `nan`, `inf`, `4.5` ou `99999999999999999999` lidos com `int` ou `double`              | `nil`                                               |

Os limites são definidos com `DeepLinkLimits`. O pacote nunca imprime nem registra URLs ou rotas;
os links podem conter tokens de login ou de redefinição. O artigo
[Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking)
lista todas as regras.

## App de exemplo

[`Examples/RouterDemo`](Examples/RouterDemo) é uma pequena loja para iOS e macOS: abas Shop e
Account, produtos com avaliações, um sheet de carrinho, pedidos atrás de um guard de login, deep
links no esquema `routerdemo://` e estado salvo. Abra `Examples/RouterDemo/RouterDemo.xcodeproj`,
escolha o scheme **RouterDemo** e um simulador de iPhone ou **My Mac**, e pressione **Run** (⌘R).
Para testar um link no simulador:

```sh
xcrun simctl openurl booted "routerdemo://products/2/reviews"
```

O target **RouterDemoUITests** (⌘U em um simulador de iPhone) verifica os fluxos na tela.

## Documentação

A [documentação](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/) cobre
todos os tipos públicos, com estes artigos:

- [Getting started](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/gettingstarted)
- [Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking)
- [Guarding screens](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/guardingscreens)
- [Tabs and state restoration](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/tabsandstaterestoration)
- [Migrating from version 1](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1)

## Como contribuir

Relatos de bugs e pull requests são bem-vindos; o [CONTRIBUTING.md](CONTRIBUTING.md) explica como
executar os testes e o app de exemplo. Relate problemas de segurança de forma privada, como
descrito em [SECURITY.md](SECURITY.md).

## Licença

O SwiftRouter é publicado sob a licença MIT. Veja [LICENSE](LICENSE).
