import 'package:flutter/material.dart';
import '../services/ProductService.dart';
import '../services/CategoriesService.dart';

class EditProdukScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const EditProdukScreen({super.key, required this.product});

  @override
  State<EditProdukScreen> createState() => _EditProdukScreenState();
}

class _EditProdukScreenState extends State<EditProdukScreen> with TickerProviderStateMixin {
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
      curve: Curves.easeInOut,
    );
    
    namaController = TextEditingController(text: widget.product['nama_produk']);
    deskripsiController = TextEditingController(text: widget.product['deskripsi']);
    hargaController = TextEditingController(text: widget.product['harga'].toString());
    stokController = TextEditingController(text: widget.product['stok'].toString());
    selectedKategoriId = widget.product['id_kategori'].toString();
    loadKategori().then((_) => _animationController.forward());
  }

  @override
  void dispose() {
    _animationController.dispose();
    namaController.dispose();
    deskripsiController.dispose();
    hargaController.dispose();
    stokController.dispose();
    super.dispose();
  }

  Future<void> loadKategori() async {
    final data = await _categoryService.getCategories();
    if (mounted) {
      setState(() {
        kategoriList = List<Map<String, dynamic>>.from(data);
      });
    }
  }

  Future<void> submitEdit() async {
    if (!_formKey.currentState!.validate() || selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Kategori wajib dipilih"),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        backgroundColor: res['success'] == true ? Colors.green.shade700 : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    if (res['success'] == true && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // HEADER WITH GRADIENT
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.blue.shade700,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton(
                onPressed: _isLoading ? null : submitEdit,
                child: Text(
                  "Simpan",
                  style: TextStyle(
                    color: _isLoading ? Colors.white.withOpacity(0.5) : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade700,
                      Colors.blue.shade500,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Edit Produk",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Perbarui informasi produk Anda",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // FORM CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // INFORMASI PRODUK
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.translate(
                            offset: Offset(0, (1 - _fadeAnimation.value) * 20),
                            child: buildCard(
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
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // HARGA & STOK
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.translate(
                            offset: Offset(0, (1 - _fadeAnimation.value) * 30),
                            child: buildCard(
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
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // DROPDOWN KATEGORI
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.translate(
                            offset: Offset(0, (1 - _fadeAnimation.value) * 40),
                            child: buildCard(
                              title: "Kategori",
                              children: [
                                kategoriList.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: CircularProgressIndicator(color: Colors.blue.shade700),
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
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // TOMBOL UPDATE PRODUK
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.translate(
                            offset: Offset(0, (1 - _fadeAnimation.value) * 50),
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.shade300.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : submitEdit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
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
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // REUSABLE CARD
  Widget buildCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
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
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade700, width: 1),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}