import 'package:flutter/material.dart';
import 'package:ukk_mobile_maulid/screen/DetailProduct.dart';
import '../services/ProductService.dart';
import 'TambahProduk.dart';

class ProdukTokoScreen extends StatefulWidget {
  const ProdukTokoScreen({super.key});

  @override
  State<ProdukTokoScreen> createState() => _ProdukTokoScreenState();
}

class _ProdukTokoScreenState extends State<ProdukTokoScreen> with TickerProviderStateMixin {
  final ProductService _productService = ProductService();
  bool isLoading = true;
  List<dynamic> produk = [];
  final String defaultImageUrl = "https://learncode.biz.id/images/no-image.png";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    fetchProdukToko();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchProdukToko() async {
    setState(() => isLoading = true);
    try {
      final data = await _productService.getStoreProducts();
      if (mounted) {
        setState(() {
          produk = data;
          isLoading = false;
        });
        _animationController.forward(from: 0);
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat produk: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Widget _buildProductCard(dynamic item, int index) {
    final price = int.tryParse(item["harga"]?.toString() ?? "0") ?? 0;
    final stock = int.tryParse(item["stok"]?.toString() ?? "0") ?? 0;
    final isLowStock = stock < 10;
    final kategori = item["nama_kategori"] ?? "";
    final images = item["images"] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images[0]["url"] : defaultImageUrl;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Hero(
        tag: 'product-${item["id_produk"]}',
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailProductScreen(idProduk: item["id_produk"].toString()),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: Icon(Icons.image, size: 50, color: Colors.grey.shade400),
                          ),
                        ),
                      ),
                      if (isLowStock)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Stok Rendah",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["nama_produk"] ?? "-",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Rp $price",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "Stok: $stock",
                              style: TextStyle(
                                color: isLowStock ? Colors.red.shade700 : Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (kategori.isNotEmpty) ...[
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  kategori,
                                  style: TextStyle(color: Colors.grey.shade700, fontSize: 10),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Belum ada produk",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Tambahkan produk pertama Anda untuk memulai",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TambahProdukScreen()),
              );
              if (result == true) fetchProdukToko();
            },
            icon: const Icon(Icons.add),
            label: const Text("Tambah Produk"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Produk Toko",
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => Navigator.pop(context),
        ),

        /// 🔥 Tambahkan tombol ADD disini (sama seperti kategori)
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle, color: Colors.blue.shade700),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TambahProdukScreen()),
              );
              if (result == true) fetchProdukToko();
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: fetchProdukToko,
        color: Colors.blue.shade700,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : produk.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: produk.length,
                    itemBuilder: (_, index) => _buildProductCard(produk[index], index),
                  ),
      ),
    );
  }
}
