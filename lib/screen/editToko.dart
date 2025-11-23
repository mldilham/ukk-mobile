import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditTokoScreen extends StatefulWidget {
  final Map<String, dynamic> store;
  const EditTokoScreen({super.key, required this.store});

  @override
  State<EditTokoScreen> createState() => _EditTokoScreenState();
}

class _EditTokoScreenState extends State<EditTokoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController namaController;
  late TextEditingController deskripsiController;
  late TextEditingController alamatController;
  late TextEditingController kontakController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.store['nama_toko']);
    deskripsiController = TextEditingController(text: widget.store['deskripsi']);
    alamatController = TextEditingController(text: widget.store['alamat']);
    kontakController = TextEditingController(text: widget.store['kontak_toko']);
  }

  Future<void> submitEdit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.post(
        Uri.parse('https://learncode.biz.id/api/stores/save'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          'id_toko': widget.store['id_toko'].toString(),
          'nama_toko': namaController.text,
          'deskripsi': deskripsiController.text,
          'alamat': alamatController.text,
          'kontak_toko': kontakController.text,
        },
      );

      final res = json.decode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? "Terjadi kesalahan"),
          backgroundColor: res['success'] == true ? Colors.green : Colors.red,
        ),
      );

      if (res['success'] == true && mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    deskripsiController.dispose();
    alamatController.dispose();
    kontakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Edit Toko", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
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
              _buildTextField(controller: namaController, label: "Nama Toko", validator: (v) => v!.isEmpty ? "Nama toko wajib diisi" : null),
              const SizedBox(height: 16),
              _buildTextField(controller: deskripsiController, label: "Deskripsi", maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField(controller: alamatController, label: "Alamat", maxLines: 2),
              const SizedBox(height: 16),
              _buildTextField(controller: kontakController, label: "Kontak Toko", keyboardType: TextInputType.phone),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : submitEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text("Update Toko", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
