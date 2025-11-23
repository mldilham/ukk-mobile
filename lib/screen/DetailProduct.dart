import 'package:flutter/material.dart';
import '../services/ProductService.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailProductScreen extends StatefulWidget {
  final String idProduk;
  const DetailProductScreen({super.key, required this.idProduk});

  @override
  State<DetailProductScreen> createState() => _DetailProductScreenState();
}

class _DetailProductScreenState extends State<DetailProductScreen> {
  final ProductService _productService = ProductService();
  bool loading = true;
  Map<String, dynamic>? product;

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  Future<void> loadDetail() async {
    setState(() => loading = true);
    final res = await _productService.getProductDetail(widget.idProduk);
    if (!mounted) return;
    setState(() {
      product = res["success"] == true ? (res["data"] as Map<String, dynamic>?) : null;
      loading = false;
    });
  }

  Future<void> _launchWhatsApp(String phone, String message) async {
    if (phone.isEmpty) return;
    final Uri whatsappUrl = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");
    try {
      if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
        throw 'Tidak dapat membuka WhatsApp';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Detail Produk",
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
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : product == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        "Produk tidak ditemukan",
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: loadDetail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Coba Lagi"),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar Produk
                      Container(
                        width: double.infinity,
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: (product?["images"] != null &&
                                  (product!["images"] as List).isNotEmpty &&
                                  product!["images"][0]?["url"] != null)
                              ? Image.network(
                                  product!["images"][0]["url"],
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 250,
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: Icon(Icons.image, size: 80, color: Colors.grey.shade400),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Info Produk
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
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
                            Text(
                              product?["nama_produk"] ?? "-",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Rp ${product?["harga"] ?? '0'}",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Stok: ${product?["stok"] ?? '0'}",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Divider(color: Colors.grey.shade200),
                            const SizedBox(height: 12),
                            if (product?["kategori"] != null)
                              Row(
                                children: [
                                  Icon(Icons.category, size: 18, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Kategori: ${product?["kategori"] is Map ? product!["kategori"]["nama_kategori"] ?? '-' : product!["kategori"]}",
                                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            if (product?["toko"] != null)
                              Row(
                                children: [
                                  Icon(Icons.store, size: 18, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Toko: ${product!["toko"]["nama_toko"] ?? '-'}",
                                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Deskripsi
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
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
                            Text(
                              "Deskripsi",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              product?["deskripsi"] ?? "Tidak ada deskripsi",
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Tombol WhatsApp
                      if (product?["toko"]?["kontak"] != null &&
                          product!["toko"]["kontak"].toString().isNotEmpty)
                        Container(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final phone = product!["toko"]["kontak"];
                              final message = "Halo, saya tertarik dengan produk ${product!["nama_produk"]}";
                              _launchWhatsApp(phone, message);
                            },
                            icon: const Icon(Icons.chat),
                            label: const Text(
                              "Pesan via WhatsApp",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}
