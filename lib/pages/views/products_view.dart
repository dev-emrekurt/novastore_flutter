import 'package:flutter/material.dart';
import 'package:novastore_flutter/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductsView extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> favorites;
  final Future<void> Function(String) onFavoriteToggle;
  final Function(Map<String, dynamic>) onAddToCart;
  final List<Map<String, dynamic>> categories;

  const ProductsView({
    super.key,
    required this.products,
    required this.favorites,
    required this.onFavoriteToggle,
    required this.onAddToCart,
    required this.categories,
  });

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  String _selectedCategory = 'Tümü';
  late List<Map<String, dynamic>> _filteredProducts;

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.products;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onCategorySelected(String categoryName) {
    setState(() {
      _selectedCategory = categoryName;

      if (categoryName == 'Tümü') {
        _filteredProducts = widget.products;
      } else {
        // Seçili kategorinin ID'sini bul
        final selectedCategoryId = widget.categories.firstWhere(
          (cat) => cat['name'] == categoryName,
          orElse: () => {'id': null},
        )['id'];

        // Seçili kategoriyi filtrele
        _filteredProducts = widget.products
            .where((product) => product['CategoryID'] == selectedCategoryId)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Kategori Seçimi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.categories.length + 1,
                itemBuilder: (context, index) {
                  final categoryName = index == 0
                      ? 'Tümü'
                      : widget.categories[index - 1]['name'];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        categoryName,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: _selectedCategory == categoryName,
                      onSelected: (selected) {
                        _onCategorySelected(categoryName);
                      },
                      backgroundColor: colorScheme.onPrimary,
                      selectedColor: colorScheme.primary,
                      labelStyle: TextStyle(
                        color: _selectedCategory == categoryName
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                      side: BorderSide(
                        color: _selectedCategory == categoryName
                            ? colorScheme.primary
                            : colorScheme.onSurface.withOpacity(0.2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sonuç sayısı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredProducts.length} Ürün',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sort,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Sırala',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Ürün Grid'i
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ürün Bulunamadı',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Arama kriterlerinizi değiştirerek tekrar deneyin',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      final isFavorited = widget.favorites.any(
                        (fav) => fav['ProductID'] == product['ProductID'],
                      );

                      return GestureDetector(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.onPrimary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.onSurface.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ürün Resmi
                              Container(
                                height: 140,
                                decoration: BoxDecoration(
                                  color: colorScheme.secondary,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: Image.network(
                                        product['Image'],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: colorScheme.onSurface
                                                      .withOpacity(0.3),
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () async {
                                          await widget.onFavoriteToggle(
                                            product['ProductName'],
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: colorScheme.onPrimary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isFavorited
                                                ? Icons.favorite
                                                : Icons.favorite_outline,
                                            size: 18,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Ürün Bilgisi
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['ProductName'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '₺${product['Price']}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 32,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            widget.onAddToCart(product);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${product['ProductName']} sepete eklendi',
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        colorScheme.onSurface,
                                                  ),
                                                ),
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                                backgroundColor:
                                                    colorScheme.primary,
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                colorScheme.primary,
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: Text(
                                            'Sepete Ekle',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 11,
                                              color: colorScheme.onPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
