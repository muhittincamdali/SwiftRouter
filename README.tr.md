<!-- i18n-source: README.md@b948148be6b8a4b9165602f99c57a96aa585850a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/banner-light.svg" alt="SwiftRouter: Type-safe SwiftUI navigation: stacks, sheets, deep links, guards and tabs in one router."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftRouter/actions/workflows/ci.yml/badge.svg" alt="CI durumu"></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-version-light.svg" alt="Son sürüm: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-platforms-light.svg" alt="Desteklenen platformlar: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-language-light.svg" alt="Dil sürümü: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/badge-license-light.svg" alt="Lisans: MIT"></picture></a>
</p>

<p align="center">
<a href="#hızlı-başlangıç"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-start-tr-light.svg" alt="Başlayın"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-docs-tr-light.svg" alt="Dokümantasyon"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftRouter/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftRouter/main/.github/brand/button-examples-tr-light.svg" alt="Örnekler"></picture></a>
</p>

> Bu belge İngilizce README'nin çevirisidir. İkisi arasında fark varsa güncel olan İngilizce sürümdür.

<!-- brand:end -->

SwiftRouter, iOS 17+, macOS 14+, tvOS 17+, watchOS 10+ ve visionOS 1+ üzerindeki SwiftUI
uygulamalarında gezinme (navigation) için bir Swift paketidir. Ekranlarınızı bir enum içinde
listelersiniz; tek bir `Router` tüm gezinme durumunu tutar: push edilen ekranları, bunların
üzerindeki sheet'leri ve tam ekran kapakları (full-screen cover) ve bu sheet'lerin içinde push
edilen ekranları. Deep link'ler bu duruma eşlenir, guard'lar her ekranı görünmeden önce denetler
ve her sekme kendi stack'ini tutabilir. Paketin hiçbir bağımlılığı yoktur.

<table>
<tr>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/product-dark.png"><img src="docs/images/product-light.png" width="200" alt="routerdemo://products/2 bağlantısıyla açılan bir ürün ekranı"></picture><br><sub><code>routerdemo://products/2</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/reviews-dark.png"><img src="docs/images/reviews-light.png" width="200" alt="Tek bir bağlantıyla ürünün üzerine push edilen yorumlar ekranı"></picture><br><sub><code>…/products/2/reviews</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/cart-dark.png"><img src="docs/images/cart-light.png" width="200" alt="Bir bağlantıyla sheet olarak sunulan sepet"></picture><br><sub><code>routerdemo://cart</code></sub></td>
<td align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/sign-in-dark.png"><img src="docs/images/sign-in-light.png" width="200" alt="Oturum kapalıyken bir siparişe giden bağlantı, giriş sheet'ini gösterir"></picture><br><sub><code>…/account/orders/1001</code></sub></td>
</tr>
</table>

Ekran görüntüleri, bir iPhone simülatöründe [örnek uygulamadan](Examples/RouterDemo) alınmıştır:
her biri, altındaki bağlantıdan router'ın ulaştığı durumdur
([`scripts/capture-screens.sh`](scripts/capture-screens.sh)).

## Öne çıkanlar

- **Tipli rotalar** — ekranlar ilişkili değerleri olan enum case'leridir; bu yüzden var olmayan
  bir hedef derlenmez.
- **Stack'ler ve sheet'ler için tek durum** — `router.entries`, push edilen her ekranı, sheet'i
  ve tam ekran kapağı listeler. Bir sheet'in kendi gezinme stack'i vardır ve başka bir sheet
  sunabilir. Geri düğmesi, geri kaydırma ve sheet'i aşağı kaydırma router'a geri yazılır.
- **Bütün durumlara giden deep link'ler** — `shop://products/42` ve
  `https://shop.example.com/products/42` bağlantıları kataloğu üstünde ürünle ya da bir sheet
  olarak açabilir. `/products/:id` gibi kalıplar en özelinden başlayarak eşleştirilir; paylaşım için
  yollar aynı kalıplardan üretilir.
- **Bağlantılar kullanılmadan önce denetlenir** — uzunluk, segment ve sorgu sınırları, yalnızca
  listelediğiniz host'larda `https`, `..` segmentleri yok, kontrol karakterleri yok ve çökmek
  yerine `nil` olan tipli değerler (`Int` taşması, `nan`, `inf`).
- **Hiçbir yolun atlayamadığı guard'lar** — bir guard; push, sheet, deep link, geri yüklenen
  snapshot ya da `NavigationLink` ile eklenen her ekranı görür. Girişe yönlendirme isteği
  saklar ve `resumePending()` girişten sonra onu açar.
- **Sekmeler ve durum geri yükleme** — `TabRouter` her sekme için bir stack tutar ve seçili
  sekme yeniden seçildiğinde kök ekrana döner; `routerStateRestoration(_:key:)` durumu scene
  başına kaydeder ve geri geldiğinde guard'lardan geçirir.
- **Test edilmiş** — macOS'ta ve bir iPhone simülatöründe 86 Swift Testing testi ve örnek
  uygulamayı iOS 27 simülatöründe süren 7 UI testi: push ve geri dönme, üç ekran derinliğindeki
  bir deep link, sepet sheet'inin üzerindeki giriş sheet'i ve giriş yaptıktan sonra isteğin
  sürdürülmesi.

## Hızlı başlangıç

**1. Paketi ekleyin**

Xcode'da **File › Add Package Dependencies…** menüsünü seçin ve sağ üstteki arama alanına depo
adresini yapıştırın:

```text
https://github.com/muhittincamdali/SwiftRouter.git
```

**Dependency Rule** ayarını `2.0.0` sürümünden itibaren **Up to Next Major Version** olarak
bırakın ve **Add Package**'a tıklayın. Açılan pencerede **SwiftRouter**'ın yanında uygulama
hedefinizi (target) seçin ve yeniden **Add Package**'a tıklayın.

**2. Modülü içe aktarın**

```swift
import SwiftRouter
```

Bu satırı, router'ı kullanan her Swift dosyasının en üstüne, `import SwiftUI` satırının yanına
ekleyin.

**3. Kullanın**

Yeni bir Xcode uygulamasında (**File › New › Project… › App**) `ContentView.swift` dosyasının
içeriğinin tamamını şununla değiştirin:

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

**Run**'a (⌘R) basın. **Open item 1** bir ekran push eder, **About** bir sheet açar (kapatmak
için aşağı kaydırın), **Open items 2 and 3** ise iki ekranı birden push eder; geri düğmesi her
seferinde bir ekran geri gider.

## Kurulum

### Swift Package Manager

Depo adresi `https://github.com/muhittincamdali/SwiftRouter.git`, Xcode'da
**File › Add Package Dependencies…** menüsüne girilir ya da `Package.swift` dosyanızdaki
`dependencies` listesine eklenir:

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

### Gereksinimler

|             | En düşük sürüm                                    |
| ----------- | ------------------------------------------------- |
| Swift       | 6.2 (Xcode 26 veya üstü)                          |
| Platformlar | iOS 17, macOS 14, tvOS 17, watchOS 10, visionOS 1 |

2.0.0 sürümü, rotaları çalışma zamanında string ile arayan 1.0.0 (Şubat 2026) API'sinin yerini
alır. Haziran 2026'da 1.0.0 kaynakları yer tutucu kodla değiştirilmişti; 2.0.0, Swift 6 dil modu
için yazılıp test edilmiş yeni bir router'dır ve SwiftUI-Navigation-Pro'nun sunum, sekme ve
durum kaydetme özelliklerini devralır. Değişiklikleri [CHANGELOG.md](CHANGELOG.md) listeler;
[Migrating from version 1](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1)
eski API'yi yenisiyle eşleştirir.

## Kullanım

Aşağıdaki örnekler
[`Examples/RouterDemo/RouterDemo/ReadmeSamples.swift`](Examples/RouterDemo/RouterDemo/ReadmeSamples.swift)
dosyasından kopyalanmıştır. Örnek uygulama ve test paketi bu dosyayı birlikte derler; testler
deep link ve giriş örneklerini çalıştırır.

### Gezinme

`RouterView` içindeki ekranlar (sheet'ler dahil) router'ı environment'tan okur:

```swift
@Environment(Router<AppRoute>.self) private var router
```

| Çağrı                           | Ne yapar                                                                 |
| ------------------------------- | ------------------------------------------------------------------------ |
| `push(_:)`, `push(contentsOf:)` | Bir ya da daha fazla ekranı en üstteki stack'e push eder                 |
| `present(_:style:)`             | Kendi stack'i olan bir `.sheet` ya da `.fullScreenCover` gösterir        |
| `pop(_:)`, `popToRoot()`        | En üstteki stack'te push edilen ekranları çıkarır; sheet'i asla kapatmaz |
| `popTo(_:)`                     | Bir rotanın son geçtiği yere kadar çıkarır, sheet'leri de aşarak         |
| `dismiss()`, `dismissAll()`     | En üstteki sheet'i ya da tüm sheet'leri kapatır                          |
| `reset()`                       | Her şeyi kapatır ve kök görünüme döner                                   |
| `setEntries(_:)`                | Tüm durumu değiştirir, örneğin `[.push(.product(id: 3)), .sheet(.cart)]` |

Ekran ekleyen her çağrı `.applied`, `.redirected` (bir guard başka bir şey gösterdi),
`.cancelled` (bir guard reddetti) ya da `.rejected` (`maxDepth` değerinden, varsayılan 64'ten
fazla kayıt) döndürür.

### Deep link'ler

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

`shop://products/42` ve `https://shop.example.com/products/42` ikisi de kataloğu, üstünde 42
numaralı ürünle açar; böylece geri düğmesi kataloğa götürür. Özel şemalı (custom-scheme) bir
URL'de host, ilk yol segmenti olarak okunur. `onDeepLink`, özel şemaları `onOpenURL` ile,
universal link'leri `onContinueUserActivity` ile alır. Şemayı hedefinizde **URL Types** altında
kaydedin; universal link'ler ayrıca Associated Domains entitlement'ı gerektirir.

Bir handler, değer kabul edilemezse `nil` döndürür ve sıradaki eşleşen kalıp denenir. Hiçbir
kalıba uymayan ya da reddedilen bir bağlantı gezinme durumunu olduğu gibi bırakır.

### Guard'lar

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

Oturum kapalıyken `shop://orders` giriş sheet'ini gösterir ve isteği saklar. `signIn` ise sheet'in
yerine siparişler ekranını koyar. Çıkış yaptıktan sonra, artık izin verilmeyen ekranları
kaldırmak için `router.revalidate()` çağırın.

### Sekmeler ve durum geri yükleme

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

Her sekme kendi stack'ini tutar ve seçili sekmeyi yeniden seçmek onu köke döndürür.
`tabs.open(url, using: [.shop: shopLinks, .orders: orderLinks])`, bir bağlantıyı, bağlantıları
ona uyan ilk sekmede açar. Durum scene'in depolamasına kaydedilir; böylece her pencere kendi
durumunu tutar ve sistem uygulamayı arka planda sonlandırdıktan sonra durum geri gelir. Bunun
için rotaların `Codable` olması gerekir.

## Bağlantılar nasıl denetlenir

Bir URL uygulamanın dışından gelir; bu yüzden `DeepLinks` herhangi bir kalıp çalışmadan önce onu
denetler:

| Girdi                                                                              | Sonuç                                                             |
| ---------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| 2.048 bayttan uzun, 32'den fazla segment ya da 32'den fazla sorgu öğesi            | Reddedilir; önce uzunluk denetlenir                               |
| `http`, bilinmeyen bir şema, listelemediğiniz bir host'ta `https`                  | Reddedilir; `*.example.com` yalnızca alt alan adlarını kabul eder |
| URL'de kullanıcı adı ya da parola                                                  | Reddedilir                                                        |
| `.` ya da `..` segmenti, `%2e` olarak yazılmış hali de dahil                       | Reddedilir, çözümlenmez                                           |
| `%2F`                                                                              | Tek bir segmentin içinde kalır                                    |
| Kontrol karakterleri, çift yönlü biçimlendirme karakterleri, UTF-8 olmayan baytlar | Reddedilir                                                        |
| `int` ya da `double` ile okunan `nan`, `inf`, `4.5` veya `99999999999999999999`    | `nil`                                                             |

Sınırlar `DeepLinkLimits` ile ayarlanır. Paket URL'leri ya da rotaları asla yazdırmaz veya
loglamaz; bağlantılar giriş ya da sıfırlama token'ları taşıyabilir.
[Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking)
makalesi her kuralı listeler.

## Örnek uygulama

[`Examples/RouterDemo`](Examples/RouterDemo), iOS ve macOS için küçük bir mağazadır: Shop ve
Account sekmeleri, yorumları olan ürünler, bir sepet sheet'i, giriş guard'ının arkasındaki
siparişler, `routerdemo://` şemasında deep link'ler ve kaydedilen durum.
`Examples/RouterDemo/RouterDemo.xcodeproj` dosyasını açın, **RouterDemo** scheme'ini ve bir
iPhone simülatörünü ya da **My Mac**'i seçip **Run**'a (⌘R) basın. Simülatörde bir bağlantıyı
denemek için:

```sh
xcrun simctl openurl booted "routerdemo://products/2/reviews"
```

**RouterDemoUITests** hedefi (bir iPhone simülatöründe ⌘U) akışları ekranda denetler.

## Dokümantasyon

[Dokümantasyon](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/),
her genel tipi kapsar ve şu makaleleri içerir:

- [Getting started](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/gettingstarted)
- [Deep linking](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/deeplinking)
- [Guarding screens](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/guardingscreens)
- [Tabs and state restoration](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/tabsandstaterestoration)
- [Migrating from version 1](https://muhittincamdali.github.io/SwiftRouter/documentation/swiftrouter/migratingfromversion1)

## Katkıda bulunma

Hata bildirimleri ve pull request'ler memnuniyetle karşılanır; testlerin ve örnek uygulamanın
nasıl çalıştırılacağını [CONTRIBUTING.md](CONTRIBUTING.md) anlatır. Güvenlik açıklarını
[SECURITY.md](SECURITY.md) dosyasında anlatıldığı gibi gizli olarak bildirin.

## Lisans

SwiftRouter, MIT lisansıyla yayımlanmıştır. Ayrıntılar için [LICENSE](LICENSE) dosyasına bakın.
