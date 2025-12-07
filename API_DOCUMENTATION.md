# API Documentation

Bu dokümantasyon, Startup Heroes iOS uygulamasında kullanılan API servislerinin ve network katmanının detaylı açıklamalarını içerir.

## Table of Contents

1. [NetworkService](#networkservice)
2. [NewsAPIService](#newsapiservice)
3. [ImageLoader](#imageloader)
4. [ReadingListManager](#readinglistmanager)
5. [NetworkMonitor](#networkmonitor)

---

## NetworkService

### Overview

`NetworkService`, uygulamanın tüm HTTP isteklerini yöneten temel network katmanıdır. Alamofire kütüphanesi kullanılarak geliştirilmiştir.

### Why Alamofire?

Alamofire kullanılmasının sebepleri:

1. **Gelişmiş Hata Yönetimi**: Alamofire, network hatalarını daha detaylı ve yapılandırılmış şekilde yönetir.
2. **Request/Response Interceptor Desteği**: İstek ve yanıtları merkezi bir yerden yönetebilme imkanı sağlar.
3. **Otomatik Retry Mekanizması**: Başarısız istekleri otomatik olarak yeniden deneme özelliği sunar.
4. **Temiz API**: Daha okunabilir ve bakımı kolay kod yazılmasını sağlar.
5. **Validation**: Response validation'ı otomatik olarak yapar.

### Protocol

```swift
protocol NetworkServiceProtocol {
    func request(url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}
```

### Class

```swift
class NetworkService: NetworkServiceProtocol
```

### Initialization

```swift
init(session: Session = .default)
```

- **session**: Alamofire Session instance'ı. Varsayılan olarak `.default` kullanılır. Test için mock session enjekte edilebilir.

### Methods

#### `request(url:completion:)`

HTTP GET isteği yapar ve sonucu completion handler ile döndürür.

**Parameters:**
- `url`: İstek yapılacak URL
- `completion`: İstek tamamlandığında çağrılacak closure. `Result<Data, Error>` tipinde sonuç döndürür.

**Example:**
```swift
let networkService = NetworkService()
let url = URL(string: "https://api.example.com/data")!
networkService.request(url: url) { result in
    switch result {
    case .success(let data):
        // Process data
    case .failure(let error):
        // Handle error
    }
}
```

### Error Handling

`NetworkService`, `NetworkError` enum'unu kullanarak hataları kategorize eder:

- `.invalidURL`: Geçersiz URL
- `.invalidResponse`: Geçersiz yanıt
- `.noData`: Veri alınamadı
- `.httpError(statusCode: Int)`: HTTP hata kodları (örn: 429, 500)

---

## NewsAPIService

### Overview

`NewsAPIService`, NewsData API ile iletişim kuran servis katmanıdır. NewsData API'den haber ve haber kaynaklarını çeker.

### API Endpoints

- **Base URL**: `https://newsdata.io/api/1`
- **News Endpoint**: `/news?apikey={API_KEY}`
- **Sources Endpoint**: `/sources?apikey={API_KEY}`

### Protocol

```swift
protocol NewsAPIServiceProtocol {
    func fetchNews(completion: @escaping (Result<NewsResponse, Error>) -> Void)
    func fetchNewsSources(completion: @escaping (Result<NewsSourceResponse, Error>) -> Void)
}
```

### Class

```swift
class NewsAPIService: NewsAPIServiceProtocol
```

### Initialization

```swift
init(networkService: NetworkServiceProtocol, apiKey: String)
```

- **networkService**: Network isteklerini yapacak servis (dependency injection)
- **apiKey**: NewsData API anahtarı

### Methods

#### `fetchNews(completion:)`

Tüm haberleri çeker.

**Parameters:**
- `completion`: İstek tamamlandığında çağrılacak closure. `Result<NewsResponse, Error>` tipinde sonuç döndürür.

**Response Model:**
```swift
struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let results: [News]
    let nextPage: String?
}
```

**Example:**
```swift
let apiService = NewsAPIService(networkService: networkService, apiKey: apiKey)
apiService.fetchNews { result in
    switch result {
    case .success(let response):
        let news = response.results
    case .failure(let error):
        // Handle error
    }
}
```

#### `fetchNewsSources(completion:)`

Tüm haber kaynaklarını çeker.

**Parameters:**
- `completion`: İstek tamamlandığında çağrılacak closure. `Result<NewsSourceResponse, Error>` tipinde sonuç döndürür.

**Response Model:**
```swift
struct NewsSourceResponse: Codable {
    let status: String
    let sources: [NewsSource]
}
```

### Error Handling

- Network hataları `NetworkError` olarak döner
- JSON decode hataları `DecodingError` olarak döner
- Geçersiz URL durumunda `NetworkError.invalidURL` döner

---

## ImageLoader

### Overview

`ImageLoader`, asenkron görsel yükleme ve cache yönetimi sağlar. `NSCache` kullanarak görselleri bellekte tutar.

### Features

- **Asenkron Yükleme**: UI thread'i bloklamadan görsel yükler
- **Cache Yönetimi**: Yüklenen görselleri cache'ler (100 görsel, 50MB limit)
- **Task Yönetimi**: Aynı görsel için birden fazla istek yapılmasını önler
- **Thread Safety**: Concurrent queue kullanarak thread-safe çalışır

### Protocol

```swift
protocol ImageLoaderProtocol {
    func loadImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void)
    func cancelLoad(for url: URL)
}
```

### Class

```swift
class ImageLoader: ImageLoaderProtocol
```

### Singleton Access

```swift
static let shared = ImageLoader()
```

### Initialization

```swift
init(session: URLSession = .shared)
```

- **session**: Görsel indirmek için kullanılacak URLSession. Varsayılan olarak `.shared` kullanılır.

### Methods

#### `loadImage(from:completion:)`

URL'den görsel yükler. Önce cache'i kontrol eder, yoksa network'ten indirir.

**Parameters:**
- `url`: Yüklenecek görselin URL'i
- `completion`: Yükleme tamamlandığında çağrılacak closure. `Result<UIImage, Error>` tipinde sonuç döndürür.

**Example:**
```swift
let imageLoader = ImageLoader.shared
let url = URL(string: "https://example.com/image.jpg")!
imageLoader.loadImage(from: url) { result in
    switch result {
    case .success(let image):
        imageView.image = image
    case .failure(let error):
        // Handle error
    }
}
```

#### `cancelLoad(for:)`

Belirtilen URL için devam eden yükleme işlemini iptal eder.

**Parameters:**
- `url`: İptal edilecek görselin URL'i

### Cache Configuration

- **Count Limit**: 100 görsel
- **Total Cost Limit**: 50MB

---

## ReadingListManager

### Overview

`ReadingListManager`, kullanıcının okuma listesini yönetir. `UserDefaults` kullanarak verileri kalıcı olarak saklar.

### Storage

- **Backend**: UserDefaults
- **Key**: `Constants.readingListKey` ("readingList")
- **Format**: JSON encoded `[News]` array

### Protocol

```swift
protocol ReadingListManagerProtocol {
    func addToReadingList(_ news: News)
    func removeFromReadingList(_ news: News)
    func isInReadingList(_ news: News) -> Bool
    func getAllReadingListItems() -> [News]
}
```

### Class

```swift
class ReadingListManager: ReadingListManagerProtocol
```

### Initialization

```swift
init(userDefaults: UserDefaults = .standard)
```

- **userDefaults**: Verilerin saklanacağı UserDefaults instance'ı. Varsayılan olarak `.standard` kullanılır.

### Methods

#### `addToReadingList(_:)`

Haberleri okuma listesine ekler. Eğer haber zaten listede varsa tekrar eklenmez.

**Parameters:**
- `news`: Eklenecek haber

**Example:**
```swift
let manager = ReadingListManager()
manager.addToReadingList(news)
```

#### `removeFromReadingList(_:)`

Haberleri okuma listesinden çıkarır.

**Parameters:**
- `news`: Çıkarılacak haber

#### `isInReadingList(_:) -> Bool`

Haberin okuma listesinde olup olmadığını kontrol eder.

**Parameters:**
- `news`: Kontrol edilecek haber

**Returns:** `true` eğer haber listede varsa, `false` aksi halde

#### `getAllReadingListItems() -> [News]`

Tüm okuma listesi öğelerini döndürür.

**Returns:** Okuma listesindeki tüm haberler

**Example:**
```swift
let manager = ReadingListManager()
let readingList = manager.getAllReadingListItems()
```

---

## NetworkMonitor

### Overview

`NetworkMonitor`, cihazın internet bağlantı durumunu izler. `NWPathMonitor` kullanarak network durumunu takip eder.

### Protocol

```swift
protocol NetworkMonitorProtocol {
    var isConnected: Bool { get }
    func startMonitoring()
    func stopMonitoring()
    func onConnectionChange(_ handler: @escaping (Bool) -> Void)
}
```

### Class

```swift
class NetworkMonitor: NetworkMonitorProtocol
```

### Properties

#### `isConnected: Bool`

Cihazın şu anda internet bağlantısı olup olmadığını gösterir.

### Methods

#### `startMonitoring()`

Network izlemeyi başlatır. Otomatik olarak constructor'da çağrılır.

#### `stopMonitoring()`

Network izlemeyi durdurur. ViewController'ın `deinit` metodunda çağrılmalıdır.

#### `onConnectionChange(_:)`

Bağlantı durumu değiştiğinde çağrılacak handler'ı ayarlar.

**Parameters:**
- `handler`: Bağlantı durumu değiştiğinde çağrılacak closure. `Bool` parametresi bağlantı durumunu gösterir (`true` = bağlı, `false` = bağlı değil)

**Example:**
```swift
let monitor = NetworkMonitor()
monitor.onConnectionChange { isConnected in
    if isConnected {
        // Network connected, fetch news
    } else {
        // Network disconnected, show offline message
    }
}
```

---

## Error Types

### NetworkError

```swift
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case httpError(statusCode: Int)
}
```

Her hata tipi için kullanıcı dostu Türkçe mesajlar sağlanır.

---

## Usage Examples

### Complete News Fetching Flow

```swift
// 1. Setup dependencies
let networkService = NetworkService()
let apiService = NewsAPIService(
    networkService: networkService,
    apiKey: Constants.newsAPIKey
)

// 2. Fetch news
apiService.fetchNews { result in
    switch result {
    case .success(let response):
        let news = response.results
        // Update UI with news
    case .failure(let error):
        if let networkError = error as? NetworkError {
            switch networkError {
            case .httpError(let statusCode):
                if statusCode == 429 {
                    // Rate limit exceeded
                }
            default:
                // Other errors
            }
        }
    }
}
```

### Image Loading with Cache

```swift
let imageLoader = ImageLoader.shared
if let imageUrlString = news.imageUrl,
   let imageUrl = URL(string: imageUrlString) {
    imageLoader.loadImage(from: imageUrl) { result in
        switch result {
        case .success(let image):
            DispatchQueue.main.async {
                imageView.image = image
            }
        case .failure(let error):
            // Show placeholder or error
        }
    }
}
```

### Reading List Management

```swift
let manager = ReadingListManager()

// Add to reading list
manager.addToReadingList(news)

// Check if in reading list
if manager.isInReadingList(news) {
    // Show "Remove from reading list" button
} else {
    // Show "Add to reading list" button
}

// Remove from reading list
manager.removeFromReadingList(news)

// Get all items
let allItems = manager.getAllReadingListItems()
```

