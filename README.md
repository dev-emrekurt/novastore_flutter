# NovaStore Flutter

Modern bir e-commerce uygulaması - Flutter ile geliştirilmiş, API entegrasyonu ve local storage destekli alışveriş platformu.

## 📱 Proje Açıklaması

NovaStore Flutter, kullanıcıların ürünleri görebileceği, favorilere ekleyebileceği, sepete koyabileceği ve sipariş verebileceği kapsamlı bir e-commerce uygulamasıdır. Uygulama **GetStorage** ile local storage yönetimi, **HTTP** ile API entegrasyonu ve **Google Fonts** ile modern tasarım sunar.

## ✨ Özellikler

### 🔐 Kimlik Doğrulama
- Email/Şifre ile login
- Kayıt sistemi
- Token-based authentication
- Oturum yönetimi (localStorage)

### 🏪 Ürün Yönetimi
- Kategori bazlı ürün listeleme
- Tümü / Kategoriye göre filtreleme
- Ürün detayları (fiyat, görsel, açıklama)
- Arama ve filtreleme (hazır)

### ❤️ Favoriler
- Ürün favorilere ekleme/çıkarma
- GetStorage ile persistent depolama
- Favoriler sekmesinde tam ürün bilgisi
- App yeniden açılışında favorilerin yüklenmesi

### 🛒 Sepet Yönetimi
- Ürün sepete ekleme
- Miktar artır/azalt
- Ürün silme
- Sepet toplam hesabı
- GetStorage ile sepet kalıcılığı

### 📦 Sipariş İşlemleri
- Siparişi API'ye gönder (customerId, items)
- Başarılı sipariş sonrası sepet temizleme
- Siparişleri görüntüle
- Siparişler otomatik olarak yüklenir

### 👤 Profil
- Kullanıcı bilgileri görüntüleme
- Siparişler geçmişi
- Logout işlemi
- Veriler temizleme

## 📂 Proje Yapısı

```
lib/
├── main.dart                 # Uygulama başlangıç noktası
├── theme.dart               # Renk şeması ve tema
├── services/
│   └── api_service.dart     # API ve localStorage işlemleri
├── pages/
│   ├── home_screen.dart     # Ana ekran ve navigation
│   ├── login_screen.dart    # Giriş ekranı
│   ├── register_screen.dart # Kayıt ekranı
│   └── views/
│       ├── home_view.dart       # Anasayfa görüntüsü
│       ├── products_view.dart   # Ürünler sekmesi
│       ├── cart_view.dart       # Sepet sekmesi
│       ├── favorites_view.dart  # Favoriler sekmesi
│       ├── profile_view.dart    # Profil sekmesi
│       └── orders_view.dart     # Siparişler sekmesi
└── assets/
    ├── images/
    └── icons/
```

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK (en son sürüm)
- Dart SDK
- Android Studio / Xcode
- Git

### Adımlar

1. **Projeyi klonla**
```bash
git clone https://github.com/yourusername/novastore_flutter.git
cd novastore_flutter
```

2. **Bağımlılıkları yükle**
```bash
flutter pub get
```

3. **Android/iOS setup (gerekirse)**
```bash
flutter pub get
cd ios
pod install
cd ..
```

4. **Uygulamayı çalıştır**
```bash
flutter run
```

## 🔧 Bağımlılıklar

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0              # API istekleri
  get_storage: ^2.1.1       # Local storage
  google_fonts: ^5.1.0      # Modern yazı tipleri
  flutter_svg: ^2.0.0       # SVG desteği
```

## 🌐 API Endpoints

### Base URL
```
https://site--novastore--8vnyqvdcq6fp.code.run/api
```

### Endpoints

#### Kimlik Doğrulama
- `POST /auth/login` - Giriş yap
  ```json
  {
    "email": "user@example.com",
    "password": "password"
  }
  ```

#### Ürünler
- `GET /products` - Tüm ürünleri al
- `GET /categories` - Kategorileri al

#### Siparişler
- `POST /orders` - Sipariş oluştur
  ```json
  {
    "customerId": 1,
    "items": [
      {"productId": 5, "quantity": 2},
      {"productId": 3, "quantity": 1}
    ]
  }
  ```
- `GET /orders/:userId` - Kullanıcının siparişlerini al

## 💾 Local Storage Yapısı

GetStorage ile aşağıdaki veriler saklanır:

```json
{
  "auth_token": "jwt_token_here",
  "user_id": 1,
  "full_name": "Kullanıcı Adı",
  "user_email": "user@example.com",
  "cart": [
    {
      "ProductID": 5,
      "ProductName": "Ürün Adı",
      "Price": "99.99",
      "Image": "url",
      "Quantity": 2
    }
  ],
  "favorites": [
    {
      "ProductID": 3,
      "ProductName": "Favori Ürün",
      "Price": "49.99",
      "Image": "url",
      "CategoryID": 1
    }
  ]
}
```

## 📱 Ana Ekran Flow

```
┌─────────────────────────┐
│     Login Screen        │
│   (Email + Password)    │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│    HomeScreen (Tab)     │
├─────────────────────────┤
│ 0. Anasayfa            │
│ 1. Ürünler             │
│ 2. Sepet               │
│ 3. Favoriler           │
│ 4. Profil              │
│ 5. Siparişler (Modal)  │
└─────────────────────────┘
```

## 🔑 Önemli Metodlar

### ApiService (api_service.dart)

**Kimlik Doğrulama**
- `login()` - Giriş yap ve token kaydet
- `logout()` - Çıkış yap
- `getSavedLoginData()` - Kaydedilen verileri al
- `getToken()`, `getUserId()`, `getUserEmail()`, `getFullName()`

**Sepet**
- `addToCart()` - Sepete ürün ekle
- `getCart()` - Sepeti al
- `removeFromCart()` - Sepetten ürün sil
- `updateCartItemQuantity()` - Miktar güncelle
- `clearCart()` - Sepeti temizle
- `getCartTotal()` - Sepet toplamı hesapla

**Favoriler**
- `addToFavorites()` - Favorilere ekle
- `removeFromFavorites()` - Favorilerden sil
- `getFavorites()` - Favorileri al
- `isFavorite()` - Ürün favori mi kontrol et
- `clearFavorites()` - Favorileri temizle

**Siparişler**
- `createOrder()` - Sipariş oluştur
- `getOrders()` - Kullanıcının siparişlerini al

**Ürünler**
- `getProducts()` - Tüm ürünleri al
- `getCategories()` - Kategorileri al

## 🎨 Tema

Proje custom color scheme kullanır (`theme.dart`):
- `colorScheme.primary` - Ana renk
- `colorScheme.secondary` - İkincil renk
- `colorScheme.surface` - Arka plan
- `colorScheme.onSurface` - Metin rengi

## 📝 Sipariş Akışı

1. **Ürün Seçimi** → Sepete ekleme
2. **Sepet Kontrol** → Miktar düzenleme
3. **Sipariş Oluştur** → API'ye POST
4. **Başarılı Cevap** → Sepet temizle
5. **Siparişler Güncelle** → API'den yeniden yükle
6. **Ana Sayfaya Dön** → Akış tamamlandı

## 🐛 Hata Yönetimi

Tüm API işlemleri `try-catch` ile sarılmış:
- Ağ hataları ele alınır
- Kullanıcıya SnackBar ile bildirim verilir
- Debugger'a log yazılır (developer.log)

```dart
developer.log('İşlem başarılı', name: 'TAG_NAME', level: 800);
developer.log('Hata oluştu: $error', name: 'TAG_NAME', level: 1000);
```

## 🔐 Güvenlik

- **Token Storage**: JWT token GetStorage'te şifrelenmiş şekilde tutulur
- **HTTPS**: API tüm istekleri HTTPS üzerinden gönderir
- **Logout**: Çıkış yapıldığında tüm veriler silinir
- **Authorization Header**: API isteklerine token eklenmiş gider

## 📊 State Management

**Provider yok, setState kullanılıyor** (basit yapı):
- HomeScreen'de merkezi state yönetimi
- View'ler callback'ler aracılığıyla parent'a iletişim kurar
- Local storage ile persistent state

## 🚦 Tip Güvenliği

```dart
// Kategoriler
List<Map<String, dynamic>> categories

// Ürünler
List<Map<String, dynamic>> products

// Favoriler ve Sepet
List<Map<String, dynamic>> _favorites
List<Map<String, dynamic>> _cartItems

// Siparişler
Map<String, dynamic> _ordersData
```

## 📱 Desteklenen Platformlar

- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- ⏳ Web (planlanan)
- ⏳ macOS (planlanan)

## 🎯 Gelecek Geliştirmeler

- [ ] Arama ve filtreleme iyileştirmesi
- [ ] Ödeme gateway'i entegrasyonu
- [ ] Bildirim sistemi
- [ ] Ürün yorumları
- [ ] Wishlist paylaşımı
- [ ] Sürüm geçmişi/siparişlerim detayları

## 👨‍💻 Geliştirici Bilgileri

- Geliştiriciler: Emre Kurt
- Son Güncelleme: 20 Nisan 2026
- Versiyon: 1.0.0


**Not**: Bu proje eğitim amaçlı geliştirilmiştir. Production ortamında ek güvenlik önlemleri alınması önerilir.
