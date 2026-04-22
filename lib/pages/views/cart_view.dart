import 'package:flutter/material.dart';
import 'package:novastore_flutter/theme.dart';
import 'package:novastore_flutter/services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';

class CartView extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(int) onRemoveItem;
  final Function(int, int) onUpdateQuantity;
  final VoidCallback onShopPressed;
  final Future<void> Function() onOrderSuccess;

  const CartView({
    super.key,
    required this.cartItems,
    required this.onRemoveItem,
    required this.onUpdateQuantity,
    required this.onShopPressed,
    required this.onOrderSuccess,
  });

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  bool _isLoading = false;

  Future<void> _createOrder() async {
    try {
      setState(() => _isLoading = true);

      // Kullanıcı ID'sini al
      final userId = await ApiService.getUserId();
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lütfen önce giriş yapınız',
                style: GoogleFonts.montserrat(),
              ),
              backgroundColor: colorScheme.error,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Sipariş oluştur
      await ApiService.createOrder(userId, widget.cartItems);

      // Sepeti temizle
      await ApiService.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sipariş başarıyla oluşturuldu!',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );

        // Callback'i çağır - parent widget sepeti temizle ve siparişleri yükle
        await Future.delayed(const Duration(milliseconds: 500));
        await widget.onOrderSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hata: ${e.toString()}',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: widget.cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sepet Boş',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Alışveriş yapmaya başlayın',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: widget.onShopPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Alışverişe Başla',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Sepetimdeki Ürünler',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      final price = item['Price'] is String
                          ? double.parse(item['Price'])
                          : (item['Price'] as num).toDouble();
                      final totalPrice = price * (item['Quantity'] as int);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.onPrimary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.onSurface.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(item['Image']),
                                    fit: BoxFit.cover,
                                    onError: (exception, stackTrace) {},
                                  ),
                                ),
                                child: item['Image'] == null
                                    ? Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: colorScheme.onSurface
                                              .withOpacity(0.3),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['ProductName'],
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₺${item['Price']}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Quantity Controls
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            if ((item['Quantity'] as int) > 1) {
                                              widget.onUpdateQuantity(
                                                item['ProductID'],
                                                (item['Quantity'] as int) - 1,
                                              );
                                            }
                                          },
                                          icon: Icon(
                                            Icons.remove_circle_outline,
                                            color: colorScheme.primary,
                                            size: 20,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            '${item['Quantity']}',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          onPressed: () {
                                            widget.onUpdateQuantity(
                                              item['ProductID'],
                                              (item['Quantity'] as int) + 1,
                                            );
                                          },
                                          icon: Icon(
                                            Icons.add_circle_outline,
                                            color: colorScheme.primary,
                                            size: 20,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    '₺$totalPrice',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  IconButton(
                                    onPressed: () {
                                      widget.onRemoveItem(item['ProductID']);
                                    },
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Sipariş Özeti
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ürün Sayısı:',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '${widget.cartItems.fold<int>(0, (sum, item) => sum + (item['Quantity'] as int))} ürün',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kargo:',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Ücretsiz',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          color: colorScheme.onSurface.withOpacity(0.2),
                          thickness: 1,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Toplam:',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '₺${widget.cartItems.fold<double>(0, (sum, item) {
                                final price = item['Price'] is String ? double.parse(item['Price']) : (item['Price'] as num).toDouble();
                                return sum + (price * (item['Quantity'] as int));
                              }).toStringAsFixed(2)}',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sipariş Oluştur Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoading
                            ? colorScheme.primary.withOpacity(0.6)
                            : colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.onPrimary,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Sipariş Oluştur',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
