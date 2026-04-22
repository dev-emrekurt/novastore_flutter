import 'package:flutter/material.dart';
import 'package:novastore_flutter/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdersView extends StatelessWidget {
  final Map<String, dynamic> ordersData;
  final VoidCallback? onBackPressed;

  const OrdersView({super.key, required this.ordersData, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    List<dynamic> orders = (ordersData['orders'] as List<dynamic>?) ?? [];

    // Siparişleri tarih açılı sırala (günümüzden geçmişe)
    orders.sort((a, b) {
      final dateA = DateTime.tryParse(a['orderDate'] as String? ?? '');
      final dateB = DateTime.tryParse(b['orderDate'] as String? ?? '');

      if (dateA == null || dateB == null) return 0;
      return dateB.compareTo(dateA); // Ters sıra (yeni siparişler önce)
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (onBackPressed != null) {
                    onBackPressed!();
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
              ),
              Text(
                'Sipariş Geçmişi',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sipariş Geçmişi Boş',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Henüz sipariş oluşturmadınız',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index] as Map<String, dynamic>;
                            final items =
                                order['items'] as List<dynamic>? ?? [];
                            final totalAmount = order['totalAmount'] ?? 0;
                            final orderDateStr =
                                order['orderDate'] as String? ??
                                'Tarih Bilinmiyor';
                            final orderDate = _formatDate(orderDateStr);
                            final orderId = order['orderId'] ?? index + 1;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.onPrimary,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.1,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Sipariş #$orderId',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            'Tamamlandı',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tarih: $orderDate',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ürün Sayısı: ${items.length}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Divider(
                                      color: colorScheme.onSurface.withOpacity(
                                        0.1,
                                      ),
                                      thickness: 1,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Toplam:',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          '₺$totalAmount',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (items.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      ExpansionTile(
                                        title: Text(
                                          'Ürünleri Gör',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                        children: [
                                          ...items.map((item) {
                                            final itemData =
                                                item as Map<String, dynamic>;
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6,
                                                    horizontal: 0,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      itemData['productName'] ??
                                                          'Ürün',
                                                      style:
                                                          GoogleFonts.montserrat(
                                                            fontSize: 11,
                                                            color: colorScheme
                                                                .onSurface,
                                                          ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Text(
                                                    'x${itemData['quantity'] ?? 1}',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: colorScheme
                                                              .onSurface,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      final months = [
        'Ocak',
        'Şubat',
        'Mart',
        'Nisan',
        'Mayıs',
        'Haziran',
        'Temmuz',
        'Ağustos',
        'Eylül',
        'Ekim',
        'Kasım',
        'Aralık',
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
