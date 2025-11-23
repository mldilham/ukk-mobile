import 'package:flutter/material.dart';
import '../services/ProductService.dart';
import '../services/CategoriesService.dart';

class EditProdukScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const EditProdukScreen({super.key, required this.product});

  @override
  State<EditProdukScreen> createState() => _EditProdukScreenState();
}

class _EditProdukScreenState extends State<EditProdukScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  final _categoryService = CategoryService();

  late TextEditingController namaController;
  late TextEditingController deskripsiController;
  late TextEditingController hargaController;
  late TextEditingController stokController;

  bool _isLoading = false;
  List<Map<String, dynamic>> kategoriList = [];
  String? selectedKategoriId;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.product['nama_produk']);
    deskripsiController = TextEditingController(text: widget.product['deskripsi']);
    hargaController = TextEditingController(text: widget.product['harga'].toString());
    stokController = TextEditingController(text: widget.product['stok'].toString());
    selectedKategoriId = widget.product['id_kategori'].toString();
    loadKategori();
  }

  Future<void> loadKategori() async {
    final data = await _categoryService.getCategories();
    setState(() {
      kategoriList = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> submitEdit() async {
    if (!_formKey.currentState!.validate() || selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kategori wajib dipilih"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final res = await _productService.saveProduct(
      id: widget.product['id_produk'].toString(),
      namaProduk: namaController.text,
      deskripsi: deskripsiController.text,
      harga: hargaController.text,
      stok: stokController.text,
      idKategori: selectedKategoriId!,
    );

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message'] ?? "Terjadi kesalahan"),
        backgroundColor: res['success'] == true ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    if (res['success'] == true && mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    namaController.dispose();
    deskripsiController.dispose();
    hargaController.dispose();
    stokController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Edit Produk",
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
        actions: [
          TextButton(
            onPressed: _isLoading ? null : submitEdit,
            child: Text(
              "Simpan",
              style: TextStyle(
                color: _isLoading ? Colors.grey.shade400 : Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // INFORMASI PRODUK
              buildCard(
                title: "Informasi Produk",
                children: [
                  _buildTextField(
                    controller: namaController,
                    label: "Nama Produk",
                    validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: deskripsiController,
                    label: "Deskripsi",
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // HARGA & STOK
              buildCard(
                title: "Harga & Stok",
                children: [
                  _buildTextField(
                    controller: hargaController,
                    label: "Harga",
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Harga wajib diisi" : null,
                    prefixText: "Rp ",
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: stokController,
                    label: "Stok",
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Stok wajib diisi" : null,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // DROPDOWN KATEGORI
              buildCard(
                title: "Kategori",
                children: [
                  kategoriList.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          value: kategoriList.any((e) => e["id_kategori"].toString() == selectedKategoriId)
                              ? selectedKategoriId
                              : null,
                          decoration: InputDecoration(
                            labelText: "Pilih Kategori",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          items: kategoriList.map((kategori) {
                            return DropdownMenuItem(
                              value: kategori["id_kategori"].toString(),
                              child: Text(kategori["nama_kategori"]),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => selectedKategoriId = val),
                          validator: (v) => v == null ? "Kategori wajib dipilih" : null,
                        ),
                ],
              ),

              const SizedBox(height: 32),

              // TOMBOL UPDATE PRODUK
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : submitEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          "Update Produk",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // REUSABLE CARD
  Widget buildCard({required String title, required List<Widget> children}) {
    return Container(
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
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // REUSABLE TEXTFIELD
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: Colors.grey.shade800),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixText: prefixText,
        prefixStyle: TextStyle(color: Colors.grey.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
