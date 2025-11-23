import 'package:flutter/material.dart';
import 'package:ukk_mobile_maulid/screen/editToko.dart';
import 'package:ukk_mobile_maulid/screen/tambahToko.dart';
import 'package:ukk_mobile_maulid/services/StoreService.dart';
import 'package:ukk_mobile_maulid/services/ProductService.dart';
import 'editProduk.dart';

class TokoScreen extends StatefulWidget {
  const TokoScreen({super.key});

  @override
  State<TokoScreen> createState() => _TokoScreenState();
}

class _TokoScreenState extends State<TokoScreen> with SingleTickerProviderStateMixin {
  final StoreService _storeService = StoreService();
  final ProductService _productService = ProductService();

  Map<String, dynamic>? store;
  List<dynamic> products = [];

  bool isLoading = true;
  bool isRefreshing = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    fetchStore();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchStore({bool isRefresh = false}) async {
    if (isRefresh) setState(() => isRefreshing = true);

    final data = await _storeService.getStore();

    setState(() {
      store = data;
      isLoading = false;
      isRefreshing = false;
    });

    if (store != null) fetchProducts();

    if (!isRefresh) _animationController.forward();
  }

  Future<void> fetchProducts() async {
    final data = await _productService.getStoreProducts();
    if (mounted) setState(() => products = data);
  }

  Future<void> deleteProduct(String idProduk) async {
    final res = await _productService.deleteProduct(idProduk);

    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Produk berhasil dihapus"), backgroundColor: Colors.green),
      );
      fetchProducts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Gagal menghapus produk"), backgroundColor: Colors.red),
      );
    }
  }

  Widget infoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget productCard(dynamic p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              p["gambar"] ?? "",
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(width: 70, height: 70, color: Colors.grey.shade200, child: const Icon(Icons.image)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p["nama_produk"] ?? "-", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Rp ${p["harga"]}", style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProdukScreen(product: p)),
              ).then((_) => fetchProducts());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Hapus Produk?"),
                  content: const Text("Produk akan dihapus secara permanen."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        Navigator.pop(context);
                        deleteProduct(p["id_produk"].toString());
                      },
                      child: const Text("Hapus"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _noStoreView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 100, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "Anda belum memiliki toko",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TambahTokoScreen()),
                );
                if (result == true) fetchStore();
              },
              icon: const Icon(Icons.add),
              label: const Text("Buat Toko Baru"),
            ),
          ],
        ),
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
          "Detail Toko",
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: store == null
            ? null
            : [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    if (store!["id"] == null) return;

                    bool confirm = false;
                    await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Hapus Toko?"),
                        content: const Text("Toko akan dihapus secara permanen."),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () {
                              confirm = true;
                              Navigator.pop(context);
                            },
                            child: const Text("Hapus"),
                          ),
                        ],
                      ),
                    );

                    if (confirm) {
                      final res = await _storeService.deleteStore(store!["id"].toString());
                      if (res["success"] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res["message"] ?? "Toko berhasil dihapus"),
                            backgroundColor: Colors.green,
                          ),
                        );
                        setState(() => store = null);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res["message"] ?? "Gagal menghapus toko"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
      ),
      body: RefreshIndicator(
        onRefresh: () => fetchStore(isRefresh: true),
        color: Colors.blue.shade700,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : store == null
                ? _noStoreView()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                store!["gambar"] ?? "",
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Container(width: 200, height: 200, color: Colors.grey.shade200, child: const Icon(Icons.store, size: 80)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(store!["nama_toko"] ?? "-", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                Text(store!["deskripsi"] ?? "-", style: TextStyle(fontSize: 16, color: Colors.grey.shade700), textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text("Informasi Toko", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          infoCard(Icons.phone, "Kontak", store!["kontak_toko"] ?? "-"),
                          infoCard(Icons.location_on, "Alamat", store!["alamat"] ?? "-"),
                          infoCard(Icons.calendar_today, "Dibuat", store!["tanggal_dibuat"] ?? "-"),
                          const SizedBox(height: 30),
                          Text("Produk Toko", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          products.isEmpty
                              ? Text("Belum ada produk", style: TextStyle(color: Colors.grey.shade600))
                              : Column(children: products.map((p) => productCard(p)).toList()),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
      ),
      floatingActionButton: store == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditTokoScreen(store: store!)),
                );

                if (result == true) {
                  await fetchStore();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Toko berhasil diperbarui"),
                      backgroundColor: Colors.green.shade700,
                    ),
                  );
                }
              },
              backgroundColor: Colors.blue.shade700,
              icon: const Icon(Icons.store),
              label: const Text("Edit Toko"),
            ),
    );
  }
}
