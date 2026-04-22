import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:novastore_flutter/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novastore_flutter/services/api_service.dart';
import 'views/home_view.dart';
import 'views/products_view.dart';
import 'views/cart_view.dart';
import 'views/favorites_view.dart';
import 'views/profile_view.dart';
import 'views/orders_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  final List<Map<String, dynamic>> _favorites = [];
  final List<Map<String, dynamic>> _cartItems = [];
  String? _fullName;
  String? _email;
  Map<String, dynamic> _ordersData = {};
  late List<Map<String, dynamic>> categories = [];
  late List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCategories();
    _loadProducts();
    _loadCart();
    _loadFavorites();
    _loadOrders();
  }

  /// Kaydedilen kullanıcı verilerini yükle
  Future<void> _loadUserData() async {
    developer.log(
      'Kullanıcı verileri yükleniyor',
      name: 'HOME_SCREEN',
      level: 800,
    );

    final userData = await ApiService.getSavedLoginData();
    if (userData != null) {
      developer.log(
        'Kullanıcı verileri Response: $userData',
        name: 'HOME_SCREEN',
        level: 800,
      );
      developer.log(
        'Kullanıcı verileri yüklendi - Email: ${userData['email']}',
        name: 'HOME_SCREEN',
        level: 800,
      );

      setState(() {
        _fullName = userData['full_name'];
        _email = userData['email'];
      });
    } else {
      developer.log(
        'Kullanıcı verileri bulunamadı',
        name: 'HOME_SCREEN',
        level: 900,
      );
    }
  }

  /// API'den kategorileri yükle
  Future<void> _loadCategories() async {
    try {
      developer.log('Kategoriler yükleniyor', name: 'HOME_SCREEN', level: 800);

      final apiCategories = await ApiService.getCategories();

      developer.log(
        'Kategoriler API Response: $apiCategories',
        name: 'HOME_SCREEN',
        level: 800,
      );

      final processedCategories = apiCategories.map((category) {
        return {
          'id': category['CategoryID'],
          'name': category['CategoryName'],
          'icon': _mapCategoryIcon(category['Icon'] ?? ''),
        };
      }).toList();

      if (mounted) {
        setState(() {
          categories = processedCategories;
        });

        developer.log(
          'Kategoriler yüklendi - ${categories.length} kategori',
          name: 'HOME_SCREEN',
          level: 800,
        );
      }
    } catch (e) {
      developer.log(
        'Kategoriler yüklenemedi: $e',
        name: 'HOME_SCREEN',
        level: 1000,
      );
    }
  }

  /// Bootstrap icon string'ini IconData'ya dönüştür
  IconData _mapCategoryIcon(String iconName) {
    final iconLower = iconName.toLowerCase();
    if (iconLower.contains('phone')) return Icons.phone_android;
    if (iconLower.contains('flower')) return Icons.checkroom;
    if (iconLower.contains('book')) return Icons.book;
    if (iconLower.contains('brush')) return Icons.brush;
    if (iconLower.contains('house')) return Icons.home;
    return Icons.category;
  }

  /// API'den ürünleri yükle
  Future<void> _loadProducts() async {
    try {
      developer.log('Ürünler yükleniyor', name: 'HOME_SCREEN', level: 800);

      final apiProducts = await ApiService.getProducts();

      developer.log(
        'Ürünler API Response: $apiProducts',
        name: 'HOME_SCREEN',
        level: 800,
      );

      if (mounted) {
        setState(() {
          products = apiProducts;
        });

        developer.log(
          'Ürünler yüklendi - ${products.length} ürün',
          name: 'HOME_SCREEN',
          level: 800,
        );
      }
    } catch (e) {
      developer.log(
        'Ürünler yüklenemedi: $e',
        name: 'HOME_SCREEN',
        level: 1000,
      );
    }
  }

  Future<void> _toggleFavorite(String productName) async {
    // Ürün nesnesini bul
    final product = products.firstWhere(
      (p) => p['ProductName'] == productName,
      orElse: () => {},
    );

    if (product.isEmpty) return;

    final isFavorited = _favorites.any(
      (item) => item['ProductID'] == product['ProductID'],
    );

    setState(() {
      if (isFavorited) {
        _favorites.removeWhere(
          (item) => item['ProductID'] == product['ProductID'],
        );
      } else {
        _favorites.add(product);
      }
    });

    // Local storage'a kaydet
    if (isFavorited) {
      await ApiService.removeFromFavorites(product['ProductID']);
    } else {
      await ApiService.addToFavorites(product);
    }
  }

  Future<void> _removeFavorite(String productName) async {
    // Ürün ID'si ile favorilerden sil
    final favoriteProduct = _favorites.firstWhere(
      (item) => item['ProductName'] == productName,
      orElse: () => {},
    );

    if (favoriteProduct.isEmpty) return;

    setState(() {
      _favorites.removeWhere(
        (item) => item['ProductID'] == favoriteProduct['ProductID'],
      );
    });

    // Local storage'dan sil (async)
    await ApiService.removeFromFavorites(favoriteProduct['ProductID']);
  }

  /// Sepeti GetStorage'ten yükle
  Future<void> _loadCart() async {
    try {
      developer.log('Sepet yükleniyor', name: 'HOME_SCREEN', level: 800);

      final cartItems = await ApiService.getCart();

      developer.log(
        'Sepet API Response: $cartItems',
        name: 'HOME_SCREEN',
        level: 800,
      );

      if (mounted) {
        setState(() {
          _cartItems.clear();
          _cartItems.addAll(cartItems);
        });

        developer.log(
          'Sepet yüklendi - ${_cartItems.length} ürün',
          name: 'HOME_SCREEN',
          level: 800,
        );
      }
    } catch (e) {
      developer.log('Sepet yüklenemedi: $e', name: 'HOME_SCREEN', level: 1000);
    }
  }

  /// Favorileri GetStorage'ten yükle
  Future<void> _loadFavorites() async {
    try {
      developer.log('Favoriler yükleniyor', name: 'HOME_SCREEN', level: 800);

      final favorites = await ApiService.getFavorites();

      if (mounted) {
        setState(() {
          _favorites.clear();
          _favorites.addAll(favorites);
        });

        developer.log(
          'Favoriler yüklendi - ${_favorites.length} ürün',
          name: 'HOME_SCREEN',
          level: 800,
        );
      }
    } catch (e) {
      developer.log(
        'Favorileri yüklenemedi: $e',
        name: 'HOME_SCREEN',
        level: 1000,
      );
    }
  }

  /// Siparişleri API'den yükle
  Future<void> _loadOrders() async {
    try {
      final userId = await ApiService.getUserId();
      if (userId == null) {
        developer.log(
          'Siparişler yüklenemedi: UserID bulunamadı',
          name: 'HOME_SCREEN',
          level: 900,
        );
        return;
      }

      developer.log(
        'Siparişler yükleniyor - UserID: $userId',
        name: 'HOME_SCREEN',
        level: 800,
      );

      final orders = await ApiService.getOrders(userId);

      if (mounted) {
        setState(() {
          _ordersData = orders;
        });

        developer.log(
          'Siparişler yüklendi - Response: $orders',
          name: 'HOME_SCREEN',
          level: 800,
        );
      }
    } catch (e) {
      developer.log(
        'Siparişler yüklenemedi: $e',
        name: 'HOME_SCREEN',
        level: 1000,
      );
    }
  }

  /// Sepete ürün ekle
  Future<void> _addToCart(Map<String, dynamic> product) async {
    try {
      developer.log(
        'Sepete ürün ekleniyor: ${product['ProductName']}',
        name: 'HOME_SCREEN',
        level: 800,
      );

      await ApiService.addToCart(product, 1);

      developer.log('Ürün sepete eklendi', name: 'HOME_SCREEN', level: 800);

      // Sepeti yeniden yükle
      await _loadCart();
    } catch (e) {
      developer.log('Sepete ekle hatası: $e', name: 'HOME_SCREEN', level: 1000);
    }
  }

  /// Sepetten ürün sil
  Future<void> _removeFromCart(int productId) async {
    try {
      developer.log(
        'Sepetten ürün siliniyor: ProductID $productId',
        name: 'HOME_SCREEN',
        level: 800,
      );

      await ApiService.removeFromCart(productId);

      developer.log('Ürün sepetten silindi', name: 'HOME_SCREEN', level: 800);

      // Sepeti yeniden yükle
      await _loadCart();
    } catch (e) {
      developer.log(
        'Sepetten sil hatası: $e',
        name: 'HOME_SCREEN',
        level: 1000,
      );
    }
  }

  /// Sepetteki ürünün miktarını güncelle
  Future<void> _updateCartQuantity(int productId, int newQuantity) async {
    try {
      developer.log(
        'Sepetteki ürünün miktar güncelleniyor: ProductID $productId - Yeni Miktar: $newQuantity',
        name: 'HOME_SCREEN',
        level: 800,
      );

      await ApiService.updateCartItemQuantity(productId, newQuantity);

      developer.log('Ürün miktar güncellendi', name: 'HOME_SCREEN', level: 800);

      // Sepeti yeniden yükle
      await _loadCart();
    } catch (e) {
      developer.log(
        'Miktar güncelleme hatası: $e',
        name: 'HOME_SCREEN',
        level: 1000,
      );
    }
  }

  void _goToProducts() {
    setState(() {
      _selectedNavIndex = 1;
    });
  }

  Future<void> _handleOrderSuccess() async {
    setState(() {
      _cartItems.clear();
      _selectedNavIndex = 0;
    });

    // Siparişleri yeniden yükle
    await _loadOrders();
  }

  void _goToOrders() {
    setState(() {
      _selectedNavIndex = 5;
    });
  }

  /// Logout işlemini gerçekleştirir
  Future<void> _handleLogout() async {
    developer.log('Logout işlemi başlatıldı', name: 'HOME_SCREEN', level: 800);

    // Emin misiniz diye sor
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Çıkış Yap',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Uygulamadan çıkış yapmak istediğinizden emin misiniz?',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              developer.log(
                'Logout işlemi iptal edildi',
                name: 'HOME_SCREEN',
                level: 800,
              );
            },
            child: Text(
              'İptal',
              style: GoogleFonts.montserrat(color: colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Dialog'u kapat

              developer.log(
                'Logout işlemi onaylandı, veriler temizleniyor',
                name: 'HOME_SCREEN',
                level: 800,
              );

              // Verileri temizle
              await ApiService.logout();

              developer.log(
                'Veriler temizlendi, LoginScreen\'e yönlendiriliyor',
                name: 'HOME_SCREEN',
                level: 800,
              );

              // Login sayfasına git
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            child: Text(
              'Evet',
              style: GoogleFonts.montserrat(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent() {
    switch (_selectedNavIndex) {
      case 0:
        return HomeView(
          categories: categories,
          products: products,
          favorites: _favorites,
          onShopPressed: _goToProducts,
        );
      case 1:
        return ProductsView(
          products: products,
          favorites: _favorites,
          onFavoriteToggle: _toggleFavorite,
          onAddToCart: _addToCart,
          categories: categories,
        );
      case 2:
        return CartView(
          cartItems: _cartItems,
          onRemoveItem: _removeFromCart,
          onUpdateQuantity: _updateCartQuantity,
          onShopPressed: _goToProducts,
          onOrderSuccess: _handleOrderSuccess,
        );
      case 3:
        return FavoritesView(favorites: _favorites, onRemove: _removeFavorite);
      case 4:
        return ProfileView(
          onLogout: _handleLogout,
          fullName: _fullName,
          email: _email,
          onOrdersPressed: _goToOrders,
        );
      case 5:
        return OrdersView(
          ordersData: _ordersData,
          onBackPressed: () {
            setState(() {
              _selectedNavIndex = 0;
            });
          },
        );
      default:
        return HomeView(
          categories: categories,
          products: products,
          favorites: _favorites,
          onShopPressed: _goToProducts,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image(
            image: const AssetImage('assets/images/logo.png'),
            color: colorScheme.onSurface,
            width: 40,
            height: 40,
          ),
        ),
        backgroundColor: colorScheme.surface,
        title: Text(
          'NovaStore',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        shape: Border(
          bottom: BorderSide(color: colorScheme.onSurface, width: 1),
        ),
      ),
      body: _buildPageContent(),
      bottomNavigationBar: _selectedNavIndex != 5
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(height: 2, color: colorScheme.onSurface),
                BottomNavigationBar(
                  currentIndex: _selectedNavIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedNavIndex = index;
                    });
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: colorScheme.surface,
                  selectedItemColor: colorScheme.primary,
                  unselectedItemColor: colorScheme.onSurface,
                  selectedLabelStyle: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  unselectedLabelStyle: GoogleFonts.montserrat(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Anasayfa',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_bag),
                      label: 'Ürünler',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_cart),
                      label: 'Sepet',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.favorite),
                      label: 'Favoriler',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Profil',
                    ),
                  ],
                ),
              ],
            )
          : null,
    );
  }
}
