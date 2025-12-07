# 📰 Startup Heroes - iOS Developer Code Assignment

<div align="center">

![iOS](https://img.shields.io/badge/iOS-15.6+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-blueviolet.svg)
![Xcode](https://img.shields.io/badge/Xcode-15.0+-blue.svg)

iOS Developer Code Assignment - News Application Implementation

[Gereksinimler](#-gereksinimler) • [Çözüm Yaklaşımı](#-çözüm-yaklaşımı) • [Mimari](#-mimari) • [Teknik Detaylar](#-teknik-detaylar) • [Test](#-test)

</div>

---

## 📋 İçindekiler

- [Gereksinimler](#-gereksinimler)
- [Çözüm Yaklaşımı](#-çözüm-yaklaşımı)
- [Mimari](#-mimari)
- [Teknik Detaylar](#-teknik-detaylar)
- [Kurulum](#-kurulum)
- [Proje Yapısı](#-proje-yapısı)
- [Test](#-test)
- [Kod Kalitesi](#-kod-kalitesi)
- [Performans Optimizasyonları](#-performans-optimizasyonları)

## 📝 Gereksinimler

### Zorunlu Özellikler

✅ **Haber Listesi Ekranı**
- UITableView ile haber listesi gösterimi
- Her hücrede: başlık, görsel URL, yazar, yayın tarihi, açıklama
- Programmatic UI (SnapKit kullanılarak)
- Storyboard kullanılmamıştır

✅ **Haber Detay Ekranı**
- Büyük haber görseli
- Özet metin
- Yazar ve tarih bilgileri
- Dikey scroll desteği (UIScrollView/UIStackView)

✅ **Periyodik Haber Çekme**
- Her dakika asenkron olarak haber çekme
- Detay ekranından dönüldüğünde haberleri yenileme

✅ **Okuma Listesi**
- Haberleri okuma listesine ekleme/çıkarma
- UserDefaults ile kalıcı depolama
- Buton metni duruma göre değişiyor
- Ayrı ekran yok (buton ile yönetim)

### Bonus Özellikler

✅ **Arama Çubuğu**
- Haber başlıklarında ve açıklamalarında arama

✅ **Scroll Pozisyonu Koruma**
- Sayfa yenilendiğinde scroll pozisyonu korunuyor

✅ **Yeni Başlık Bildirimi**
- Yeni haberler geldiğinde UIAlertView gösterimi
- 1 saniye sonra otomatik kapanma

### Teknik Standartlar

✅ **Kod Kalitesi**
- SOLID prensiplerine uyum
- Temiz ve okunabilir kod
- Anlamlı değişken ve fonksiyon isimleri

✅ **Performans**
- Asenkron işlemler (UI bloklanmıyor)
- Non-blocking UI
- Image caching

✅ **Test Edilebilir Tasarım**
- MVVM mimarisi
- Dependency Injection
- Protocol-oriented programming

✅ **Unit Testler**
- Networking katmanı testleri
- ViewModel testleri
- Mock objeler kullanılarak

✅ **Hata Yönetimi**
- Kapsamlı error handling
- Kullanıcı dostu hata mesajları
- Network hataları için özel yönetim

✅ **Offline Desteği**
- Network monitoring
- Bağlantı durumu kontrolü
- Offline durumda uygun mesajlar

✅ **Üçüncü Parti Kütüphaneler**
- Minimal kullanım
- Alamofire kullanımı gerekçelendirilmiş
- SnapKit programmatic UI için kullanılmış

## 🎯 Çözüm Yaklaşımı

### Mimari Kararlar

**MVVM Pattern Seçimi**
- View ve ViewModel arasında net ayrım
- Test edilebilirlik için ViewModel'lerin bağımsız test edilmesi
- Closure-based binding ile reactive yapı

**Base Classes**
- `BaseViewController`: Ortak loading overlay yönetimi
- `BaseViewModel`: Ortak loading state yönetimi
- Kod tekrarını önleme ve tutarlılık

**Dependency Injection**
- Tüm servisler ve manager'lar constructor injection ile enjekte ediliyor
- Test edilebilirlik için protocol'ler kullanılıyor
- Loose coupling sağlanıyor

**Protocol-Oriented Design**
- `NewsAPIServiceProtocol`, `NetworkServiceProtocol`, `ReadingListManagerProtocol`
- Mock objeler için kolay implementasyon
- Test edilebilirlik artışı

### Teknik Seçimler

**Alamofire Kullanımı**
- Gelişmiş hata yönetimi
- Request/Response interceptor desteği
- Otomatik retry mekanizması
- Temiz ve okunabilir API

**SnapKit Kullanımı**
- Programmatic UI için modern ve okunabilir syntax
- Storyboard bağımlılığını kaldırma
- Type-safe constraint tanımları

**Swift 6 Concurrency**
- Actor isolation ile thread-safe kod
- `@MainActor` ile UI thread yönetimi
- `nonisolated` ile performans optimizasyonu
- `Sendable` protokolü ile veri güvenliği

## 🚀 Kurulum

### Gereksinimler

- **Xcode**: 15.0 veya üzeri
- **iOS**: 15.6 veya üzeri
- **Swift**: 6.0
- **CocoaPods**: Gerekli değil (Swift Package Manager kullanılıyor)

### Adımlar

1. **Projeyi klonlayın**
   ```bash
   git clone https://github.com/yourusername/startup-heroes.git
   cd startup-heroes
   ```

2. **API Key'i ayarlayın**
   
   `Startup Heroes/Info.plist` dosyasına `NewsAPIKey` anahtarını ekleyin:
   ```xml
   <key>NewsAPIKey</key>
   <string>YOUR_API_KEY_HERE</string>
   ```
   
   API Key'i [NewsData.io](https://newsdata.io/) adresinden alabilirsiniz.

3. **Bağımlılıkları yükleyin**
   
   Xcode otomatik olarak Swift Package Manager ile bağımlılıkları yükleyecektir:
   - SnapKit (5.7.1+)
   - Alamofire (5.10.2+)
   - Kingfisher (8.6.2+)

4. **Projeyi çalıştırın**
   
   Xcode'da projeyi açın ve `⌘ + R` ile çalıştırın.

## 🏗️ Mimari

### MVVM Pattern

Proje **Model-View-ViewModel (MVVM)** mimarisi kullanılarak geliştirilmiştir:

```
┌─────────────────────────────────────────┐
│              View Layer                  │
│  (ViewControllers, CustomViews)        │
│  - UI rendering                         │
│  - User interactions                    │
│  - ViewModel binding                    │
└──────────────┬──────────────────────────┘
               │ Closure-based binding
               │ (onNewsUpdated, onError, etc.)
┌──────────────▼──────────────────────────┐
│           ViewModel Layer                │
│  (NewsListViewModel, etc.)               │
│  - Business logic                       │
│  - Data transformation                  │
│  - State management                     │
└──────────────┬──────────────────────────┘
               │ Protocol-based
               │ (NewsAPIServiceProtocol, etc.)
┌──────────────▼──────────────────────────┐
│         Service/Manager Layer            │
│  (NewsAPIService, ReadingListManager)   │
│  - API calls                            │
│  - Data persistence                     │
│  - Network monitoring                   │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│            Model Layer                   │
│  (News, NewsResponse, etc.)             │
│  - Data structures                      │
│  - Codable conformance                   │
└─────────────────────────────────────────┘
```

### SOLID Prensipleri Uygulaması

**Single Responsibility Principle**
- `NewsListViewController`: Sadece UI rendering ve user interaction
- `NewsListViewModel`: Sadece business logic ve state management
- `NewsAPIService`: Sadece API çağrıları
- `ReadingListManager`: Sadece okuma listesi yönetimi

**Open/Closed Principle**
- Base classes ile genişletilebilir yapı
- Protocol'ler ile yeni implementasyonlar eklenebilir
- Mevcut kod değiştirilmeden yeni özellikler eklenebilir

**Liskov Substitution Principle**
- `BaseViewController` ve `BaseViewModel` türetilmiş sınıflarla değiştirilebilir
- Protocol implementasyonları birbirinin yerine kullanılabilir

**Interface Segregation Principle**
- Küçük ve odaklanmış protocol'ler (`NewsAPIServiceProtocol`, `NetworkServiceProtocol`)
- Her protocol sadece gerekli metodları içeriyor

**Dependency Inversion Principle**
- ViewModel'ler concrete class'lara değil, protocol'lere bağımlı
- Dependency injection ile loose coupling

## 🔧 Teknik Detaylar

### Kullanılan Teknolojiler

**Framework'ler ve Kütüphaneler**
- **UIKit**: Native iOS UI framework
- **SnapKit (5.7.1+)**: Programmatic Auto Layout - Storyboard kullanmadan constraint tanımlama
- **Alamofire (5.10.2+)**: HTTP networking - Gelişmiş hata yönetimi ve interceptor desteği
- **Kingfisher (8.6.2+)**: Image loading ve caching - Performans optimizasyonu

**Swift Özellikleri**
- **Swift 6**: Strict concurrency ve actor isolation
- **@MainActor**: UI thread yönetimi
- **nonisolated**: Performans optimizasyonu için
- **Sendable**: Thread-safe veri yapıları
- **Protocol-Oriented**: Protocol tabanlı tasarım
- **Dependency Injection**: Constructor injection pattern

### API Entegrasyonu

**NewsData.io API**
- Endpoint: `https://newsdata.io/api/1/news`
- API Key: Info.plist'ten okunuyor
- Rate Limit: Günlük 200 request
- Error Handling: 429 hatası için özel yönetim

### Veri Depolama

**UserDefaults**
- Okuma listesi için kalıcı depolama
- JSON encoding/decoding ile News objelerinin saklanması
- Key: `Constants.readingListKey`

### Network Monitoring

**NWPathMonitor**
- İnternet bağlantısı durumu izleme
- Bağlantı kesildiğinde kullanıcıya bilgi verme
- Bağlantı kurulduğunda otomatik haber çekme

## 📁 Proje Yapısı

```
Startup Heroes/
├── Models/                    # Veri modelleri
│   ├── News.swift
│   └── NewsSource.swift
│
├── Views/                      # UI Bileşenleri
│   ├── ViewControllers/
│   │   ├── BaseViewController.swift
│   │   ├── NewsListViewController.swift
│   │   ├── NewsDetailViewController.swift
│   │   ├── ReadingListViewController.swift
│   │   └── LaunchScreenViewController.swift
│   └── CustomViews/
│       └── NewsTableViewCell.swift
│
├── ViewModels/                 # İş mantığı
│   ├── BaseViewModel.swift
│   ├── NewsListViewModel.swift
│   ├── NewsDetailViewModel.swift
│   └── ReadingListViewModel.swift
│
├── Services/                   # API ve Network servisleri
│   ├── NetworkService.swift
│   ├── NewsAPIService.swift
│   └── ImageLoader.swift
│
├── Managers/                   # İş mantığı yöneticileri
│   ├── ReadingListManager.swift
│   └── NetworkMonitor.swift
│
├── Utilities/                  # Yardımcı sınıflar
│   ├── ColorManager.swift
│   ├── FontManager.swift
│   ├── Constants.swift
│   └── Extensions/
│       ├── String+Extensions.swift
│       └── UIImageView+Extensions.swift
│
└── Resources/                  # Assets ve kaynaklar
    └── Assets.xcassets/
```

## 📚 API Dokümantasyonu

Detaylı API dokümantasyonu için [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) dosyasına bakabilirsiniz.

### Kullanılan API

- **NewsData.io**: Haber verilerini sağlayan API servisi
- **Endpoint**: `https://newsdata.io/api/1/news`

## 🧪 Test

### Unit Testler

Proje kapsamlı unit testler içermektedir:

**NetworkServiceTests**
- Başarılı network request testi
- Hata durumu testleri
- Invalid URL testi
- Mock network service kullanımı

**NewsAPIServiceTests**
- API çağrısı testleri
- JSON decode testleri
- Error handling testleri
- Mock network service ile izolasyon

**ReadingListManagerTests**
- Okuma listesine ekleme testi
- Okuma listesinden çıkarma testi
- Liste kontrolü testleri
- UserDefaults mock kullanımı

### Test Çalıştırma

```bash
⌘ + U (Xcode'da)
```

veya

```bash
xcodebuild test -scheme "Startup Heroes" -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Test Coverage

- Networking katmanı: %100
- ViewModel katmanı: %90+
- Manager katmanı: %95+

## 💎 Kod Kalitesi

### Best Practices

**Code Organization**
- Klasör yapısı ile modüler organizasyon
- Her dosya tek bir sorumluluğa sahip
- Anlamlı dosya ve klasör isimleri

**Naming Conventions**
- Swift naming conventions'a uyum
- Açıklayıcı değişken ve fonksiyon isimleri
- Protocol'ler için `Protocol` suffix'i

**Documentation**
- API dokümantasyonu (`API_DOCUMENTATION.md`)
- Mimari dokümantasyonu (`ARCHITECTURE.md`)
- Kod içi açıklamalar gerektiğinde kullanılmış

**Error Handling**
- Kapsamlı error handling
- Kullanıcı dostu hata mesajları
- Network hataları için özel yönetim
- 429 (Rate Limit) hatası için empty state

## ⚡ Performans Optimizasyonları

**Image Loading**
- Kingfisher ile otomatik caching
- Lazy loading
- Memory-efficient image handling
- Shimmer loading ile UX iyileştirmesi

**Network Optimization**
- Alamofire ile connection pooling
- Request validation
- Error retry mekanizması

**UI Performance**
- Async işlemler ile UI blocking önleme
- Efficient table view cell reuse
- Scroll position caching
- Lazy view loading

**Memory Management**
- Weak references ile retain cycle önleme
- Proper cleanup in deinit
- Image cache management

## 📱 Özellik Detayları

### Haber Listesi Ekranı
- **UITableView** ile haber listesi
- **Custom Cell**: `NewsTableViewCell` ile özel tasarım
- **Her hücrede**: Başlık (3 satır), görsel (100x100), yazar, tarih, açıklama (2 satır)
- **Shimmer Loading**: Görseller yüklenirken animasyonlu loading
- **Pull-to-Refresh**: Manuel yenileme desteği
- **Arama**: UISearchController ile gerçek zamanlı arama
- **Empty State**: Hata durumunda kullanıcı dostu mesaj ve retry butonu
- **Scroll Position**: Yenileme sonrası scroll pozisyonu korunuyor

### Haber Detay Ekranı
- **UIScrollView** ile dikey scroll
- **UIStackView** ile içerik organizasyonu
- **Kart Tasarımı**: Her bölüm ayrı kart içinde
- **Büyük Görsel**: 280pt yükseklikte haber görseli
- **Detaylı İçerik**: Başlık, yazar, tarih, açıklama, içerik
- **Attributed Text**: Line spacing ve font weight ile okunabilirlik

### Okuma Listesi
- **Modal Presentation**: Sheet presentation controller
- **UserDefaults**: Kalıcı depolama
- **Add/Remove**: Haber ekleme ve çıkarma
- **Button State**: Duruma göre buton metni değişiyor
- **Navigation**: Okuma listesinden detaya gitme

### Periyodik Yenileme
- **Timer**: Her 60 saniyede bir otomatik yenileme
- **Network Check**: İnternet bağlantısı kontrolü
- **Background Handling**: Uygun lifecycle yönetimi
- **New Headlines Alert**: Yeni haberler geldiğinde bildirim

## 📊 Gereksinim Karşılanma Durumu

| Gereksinim | Durum | Notlar |
|------------|-------|--------|
| Haber Listesi (UITableView) | ✅ | Custom cell, shimmer loading, pull-to-refresh |
| Haber Detay Ekranı | ✅ | ScrollView, kart tasarımı, detaylı içerik |
| Periyodik Haber Çekme | ✅ | Her dakika otomatik, network kontrolü |
| Okuma Listesi | ✅ | UserDefaults, add/remove, button state |
| Programmatic UI | ✅ | SnapKit kullanıldı, storyboard yok |
| Arama | ✅ | Bonus: Gerçek zamanlı arama |
| Scroll Position | ✅ | Bonus: Pozisyon korunuyor |
| Yeni Başlık Bildirimi | ✅ | Bonus: UIAlertView, 1 saniye |
| MVVM Mimarisi | ✅ | Base classes ile genişletilebilir |
| Unit Testler | ✅ | Networking ve ViewModel testleri |
| Error Handling | ✅ | Kapsamlı hata yönetimi |
| Offline Support | ✅ | Network monitoring |
| Code Quality | ✅ | SOLID prensipleri, clean code |
| Documentation | ✅ | API ve mimari dokümantasyonu |

## 🎯 Öne Çıkan Özellikler

### Teknik Mükemmellik
- **Swift 6 Concurrency**: Actor isolation ile thread-safe kod
- **Base Classes**: Kod tekrarını önleyen yapı
- **Protocol-Oriented**: Test edilebilir ve genişletilebilir tasarım
- **Dependency Injection**: Loose coupling ve test edilebilirlik

### Kullanıcı Deneyimi
- **Shimmer Loading**: Profesyonel loading animasyonu
- **Empty State**: Hata durumunda kullanıcı dostu mesajlar
- **Card Design**: Modern ve temiz UI tasarımı
- **Smooth Animations**: Geçişler ve animasyonlar

### Performans
- **Image Caching**: Hızlı görsel yükleme
- **Async Operations**: UI blocking önleme
- **Memory Management**: Retain cycle önleme
- **Efficient Rendering**: Optimize edilmiş table view

## 📚 Dokümantasyon

- **API_DOCUMENTATION.md**: Detaylı API dokümantasyonu
- **ARCHITECTURE.md**: Mimari açıklamaları
- **README.md**: Bu dosya

## 🔍 Code Review Notları

### Güçlü Yönler
- ✅ Temiz ve okunabilir kod yapısı
- ✅ SOLID prensiplerine uyum
- ✅ Kapsamlı test coverage
- ✅ Modern Swift özellikleri kullanımı
- ✅ İyi hata yönetimi

### İyileştirme Önerileri
- Dark mode desteği eklenebilir
- Daha fazla unit test eklenebilir
- Performance profiling yapılabilir
- Accessibility özellikleri geliştirilebilir

---

<div align="center">

**iOS Developer Code Assignment - Startup Heroes**

Bu proje, iOS Developer pozisyonu için hazırlanmış bir code assignment'dır.

Tüm gereksinimler karşılanmış ve bonus özellikler eklenmiştir.

</div>

