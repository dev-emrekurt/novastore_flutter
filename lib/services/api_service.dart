import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ApiService {
  static const String baseUrl =
      'https://site--novastore--8vnyqvdcq6fp.code.run/api';
  static final _storage = GetStorage();

  /// Login endpoint'ine POST isteği yapır ve response'taki verileri local hafızaya kaydeder
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Login isteğini log et
      developer.log(
        'LOGIN İSTEĞİ BAŞLATILDI',
        name: 'AUTH',
        level: 800, // INFO seviyesi
      );

      developer.log('Email: $email', name: 'AUTH', level: 800);

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Başarılı yanıtı log et
        developer.log('LOGIN BAŞARILI', name: 'AUTH', level: 800);

        developer.log(
          'User ID: ${jsonResponse['userId']}',
          name: 'AUTH',
          level: 800,
        );

        developer.log(
          'Full Name: ${jsonResponse['fullName']}',
          name: 'AUTH',
          level: 800,
        );

        developer.log(
          'Token: ${jsonResponse['token'].substring(0, 20)}...', // Token'ın ilk 20 karakterini göster
          name: 'AUTH',
          level: 800,
        );

        // Response'taki token, userId ve fullName bilgilerini local hafızaya kaydet
        await _saveLoginData(
          token: jsonResponse['token'],
          userId: jsonResponse['userId'],
          fullName: jsonResponse['fullName'],
          email: jsonResponse['email'],
        );

        developer.log(
          'Kullanıcı verileri local hafızaya kaydedildi',
          name: 'AUTH',
          level: 800,
        );

        return jsonResponse;
      } else {
        final errorMessage =
            'Login başarısız: ${response.statusCode} - ${response.body}';

        developer.log(
          errorMessage,
          name: 'AUTH',
          level: 900, // WARNING seviyesi
        );

        throw Exception(errorMessage);
      }
    } catch (e) {
      developer.log(
        'Login hatası: $e',
        name: 'AUTH',
        level: 1000, // ERROR seviyesi
      );

      throw Exception('Login hatası: $e');
    }
  }

  /// Login verilerini local hafızaya kaydet
  static Future<void> _saveLoginData({
    required String token,
    required int userId,
    required String fullName,
    required String email,
  }) async {
    await _storage.write('auth_token', token);
    await _storage.write('user_id', userId);
    await _storage.write('full_name', fullName);
    await _storage.write('user_email', email);
  }

  /// Kaydedilen token'ı al
  static Future<String?> getToken() async {
    return _storage.read('auth_token');
  }

  /// Kaydedilen user id'yi al
  static Future<int?> getUserId() async {
    return _storage.read('user_id');
  }

  /// Kaydedilen full name'i al
  static Future<String?> getFullName() async {
    return _storage.read('full_name');
  }

  /// Kaydedilen email'i al
  static Future<String?> getUserEmail() async {
    return _storage.read('user_email');
  }

  /// Tüm login verilerini al
  static Future<Map<String, dynamic>?> getSavedLoginData() async {
    final token = _storage.read('auth_token');

    if (token == null) return null;

    return {
      'token': token,
      'user_id': _storage.read('user_id'),
      'full_name': _storage.read('full_name'),
      'email': _storage.read('user_email'),
    };
  }

  /// Login verilerini temizle (çıkış yap)
  static Future<void> logout() async {
    await _storage.remove('auth_token');
    await _storage.remove('user_id');
    await _storage.remove('full_name');
    await _storage.remove('user_email');
  }

  /// Kategorileri API'den al
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      developer.log('KATEGORİLER İSTENİYOR', name: 'CATEGORIES', level: 800);

      final token = await getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);

        developer.log(
          'KATEGORİLER BAŞARIYLA ALINDı - ${jsonResponse.length} kategori',
          name: 'CATEGORIES',
          level: 800,
        );

        return List<Map<String, dynamic>>.from(jsonResponse);
      } else {
        throw Exception(
          'Kategoriler yüklenemedi: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      developer.log('Kategoriler hatası: $e', name: 'CATEGORIES', level: 1000);
      throw Exception('Kategoriler hatası: $e');
    }
  }

  /// Ürünleri API'den al
  static Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      developer.log('ÜRÜNLER İSTENİYOR', name: 'PRODUCTS', level: 800);

      final token = await getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);

        developer.log(
          'ÜRÜNLER BAŞARIYLA ALINDı - ${jsonResponse.length} ürün',
          name: 'PRODUCTS',
          level: 800,
        );

        return List<Map<String, dynamic>>.from(jsonResponse);
      } else {
        throw Exception(
          'Ürünler yüklenemedi: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      developer.log('Ürünler hatası: $e', name: 'PRODUCTS', level: 1000);
      throw Exception('Ürünler hatası: $e');
    }
  }

  /// Sepete ürün ekle
  static Future<void> addToCart(
    Map<String, dynamic> product,
    int quantity,
  ) async {
    try {
      developer.log(
        'Sepete ürün ekleniyor: ${product['ProductName']} (Miktar: $quantity)',
        name: 'CART',
        level: 800,
      );

      final cartItems = await getCart();

      // Aynı ürün zaten sepette varsa miktarı artır
      final existingIndex = cartItems.indexWhere(
        (item) => item['ProductID'] == product['ProductID'],
      );

      if (existingIndex >= 0) {
        cartItems[existingIndex]['Quantity'] =
            (cartItems[existingIndex]['Quantity'] as int) + quantity;
      } else {
        // Yeni ürün olarak ekle
        final cartItem = {...product, 'Quantity': quantity};
        cartItems.add(cartItem);
      }

      // GetStorage'e kaydet
      await _storage.write('cart', cartItems);

      developer.log(
        'Sepete ürün eklendi - Toplam ürün sayısı: ${cartItems.length}',
        name: 'CART',
        level: 800,
      );
    } catch (e) {
      developer.log('Sepete ekle hatası: $e', name: 'CART', level: 1000);
      throw Exception('Sepete ekle hatası: $e');
    }
  }

  /// Sepeti al
  static Future<List<Map<String, dynamic>>> getCart() async {
    try {
      final cart = _storage.read('cart');

      if (cart == null) {
        return [];
      }

      return List<Map<String, dynamic>>.from(
        (cart as List).map((item) => Map<String, dynamic>.from(item as Map)),
      );
    } catch (e) {
      developer.log('Sepeti getir hatası: $e', name: 'CART', level: 1000);
      return [];
    }
  }

  /// Sepetten ürün sil
  static Future<void> removeFromCart(int productId) async {
    try {
      developer.log(
        'Sepetten ürün siliniyor: ProductID $productId',
        name: 'CART',
        level: 800,
      );

      final cartItems = await getCart();
      cartItems.removeWhere((item) => item['ProductID'] == productId);

      await _storage.write('cart', cartItems);

      developer.log(
        'Sepetten ürün silindi - Kalan ürün sayısı: ${cartItems.length}',
        name: 'CART',
        level: 800,
      );
    } catch (e) {
      developer.log('Sepetten sil hatası: $e', name: 'CART', level: 1000);
      throw Exception('Sepetten sil hatası: $e');
    }
  }

  /// Sepetteki ürünün miktarını güncelle
  static Future<void> updateCartItemQuantity(
    int productId,
    int newQuantity,
  ) async {
    try {
      developer.log(
        'Sepetteki ürünün miktar güncelleniyor: ProductID $productId - Yeni Miktar: $newQuantity',
        name: 'CART',
        level: 800,
      );

      final cartItems = await getCart();
      final itemIndex = cartItems.indexWhere(
        (item) => item['ProductID'] == productId,
      );

      if (itemIndex >= 0) {
        cartItems[itemIndex]['Quantity'] = newQuantity;
        await _storage.write('cart', cartItems);

        developer.log('Ürün miktar güncellendi', name: 'CART', level: 800);
      }
    } catch (e) {
      developer.log('Miktar güncelleme hatası: $e', name: 'CART', level: 1000);
      throw Exception('Miktar güncelleme hatası: $e');
    }
  }

  /// Sepeti temizle
  static Future<void> clearCart() async {
    try {
      developer.log('Sepet temizleniyor', name: 'CART', level: 800);
      await _storage.remove('cart');
      developer.log('Sepet temizlendi', name: 'CART', level: 800);
    } catch (e) {
      developer.log('Sepet temizle hatası: $e', name: 'CART', level: 1000);
      throw Exception('Sepet temizle hatası: $e');
    }
  }

  /// Sepet toplam fiyatını hesapla
  static Future<double> getCartTotal() async {
    try {
      final cartItems = await getCart();
      double total = 0;

      for (var item in cartItems) {
        final price = item['Price'] is String
            ? double.parse(item['Price'])
            : (item['Price'] as num).toDouble();
        total += price * (item['Quantity'] as int);
      }

      return total;
    } catch (e) {
      developer.log('Sepet toplam hatası: $e', name: 'CART', level: 1000);
      return 0;
    }
  }

  /// Siparişleri al
  static Future<Map<String, dynamic>> getOrders(int userId) async {
    try {
      developer.log(
        'SİPARİŞLER İSTENİYOR - UserID: $userId',
        name: 'ORDERS',
        level: 800,
      );

      final token = await getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/orders/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        developer.log(
          'SİPARİŞLER BAŞARIYLA ALINDı',
          name: 'ORDERS',
          level: 800,
        );

        return Map<String, dynamic>.from(jsonResponse);
      } else {
        throw Exception(
          'Siparişler yüklenemedi: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      developer.log('Siparişler hatası: $e', name: 'ORDERS', level: 1000);
      throw Exception('Siparişler hatası: $e');
    }
  }

  /// Sipariş oluştur
  static Future<Map<String, dynamic>> createOrder(
    int customerId,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      developer.log(
        'SİPARİŞ OLUŞTURULUYOR - CustomerID: $customerId, İtem Sayısı: ${items.length}',
        name: 'ORDERS',
        level: 800,
      );

      final token = await getToken();

      // API için gerekli format
      final orderData = {
        'customerId': customerId,
        'items': items
            .map(
              (item) => {
                'productId': item['ProductID'],
                'quantity': item['Quantity'],
              },
            )
            .toList(),
      };

      developer.log(
        'Gönderilen veri: ${jsonEncode(orderData)}',
        name: 'ORDERS',
        level: 800,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);

        developer.log(
          'SİPARİŞ BAŞARIYLA OLUŞTURULDU - OrderID: ${jsonResponse['orderId'] ?? 'N/A'}',
          name: 'ORDERS',
          level: 800,
        );

        return Map<String, dynamic>.from(jsonResponse);
      } else {
        final errorMessage =
            'Sipariş oluşturulamadı: ${response.statusCode} - ${response.body}';

        developer.log(errorMessage, name: 'ORDERS', level: 900);

        throw Exception(errorMessage);
      }
    } catch (e) {
      developer.log(
        'Sipariş oluşturma hatası: $e',
        name: 'ORDERS',
        level: 1000,
      );
      throw Exception('Sipariş oluşturma hatası: $e');
    }
  }

  /// Favorileri GetStorage'ten al
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final favorites = _storage.read('favorites');

      if (favorites == null) {
        return [];
      }

      return List<Map<String, dynamic>>.from(
        (favorites as List).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      );
    } catch (e) {
      developer.log(
        'Favorileri getir hatası: $e',
        name: 'FAVORITES',
        level: 1000,
      );
      return [];
    }
  }

  /// Favorilere ürün ekle
  static Future<void> addToFavorites(Map<String, dynamic> product) async {
    try {
      developer.log(
        'Favorilere ürün ekleniyor: ${product['ProductName']}',
        name: 'FAVORITES',
        level: 800,
      );

      final favorites = await getFavorites();

      // Aynı ürün zaten favorilerde varsa ekleme
      final exists = favorites.any(
        (item) => item['ProductID'] == product['ProductID'],
      );

      if (!exists) {
        favorites.add(product);
        await _storage.write('favorites', favorites);

        developer.log(
          'Favorilere ürün eklendi - Toplam: ${favorites.length}',
          name: 'FAVORITES',
          level: 800,
        );
      }
    } catch (e) {
      developer.log(
        'Favorilere ekle hatası: $e',
        name: 'FAVORITES',
        level: 1000,
      );
      throw Exception('Favorilere ekle hatası: $e');
    }
  }

  /// Favorilerden ürün sil
  static Future<void> removeFromFavorites(int productId) async {
    try {
      developer.log(
        'Favorilerden ürün siliniyor: ProductID $productId',
        name: 'FAVORITES',
        level: 800,
      );

      final favorites = await getFavorites();
      favorites.removeWhere((item) => item['ProductID'] == productId);

      await _storage.write('favorites', favorites);

      developer.log(
        'Favorilerden ürün silindi - Kalan: ${favorites.length}',
        name: 'FAVORITES',
        level: 800,
      );
    } catch (e) {
      developer.log(
        'Favorilerden sil hatası: $e',
        name: 'FAVORITES',
        level: 1000,
      );
      throw Exception('Favorilerden sil hatası: $e');
    }
  }

  /// Favorileri temizle
  static Future<void> clearFavorites() async {
    try {
      developer.log('Favoriler temizleniyor', name: 'FAVORITES', level: 800);
      await _storage.remove('favorites');
      developer.log('Favoriler temizlendi', name: 'FAVORITES', level: 800);
    } catch (e) {
      developer.log(
        'Favoriler temizle hatası: $e',
        name: 'FAVORITES',
        level: 1000,
      );
      throw Exception('Favoriler temizle hatası: $e');
    }
  }

  /// Ürün favorilerde mi kontrol et
  static Future<bool> isFavorite(int productId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((item) => item['ProductID'] == productId);
    } catch (e) {
      developer.log(
        'Favoride kontrol hatası: $e',
        name: 'FAVORITES',
        level: 1000,
      );
      return false;
    }
  }
}
