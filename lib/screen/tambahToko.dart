import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/StoreService.dart';

class TambahTokoScreen extends StatefulWidget {
  const TambahTokoScreen({super.key});

  @override
  State<TambahTokoScreen> createState() => _TambahTokoScreenState();
}

class _TambahTokoScreenState extends State<TambahTokoScreen> {
  final _formKey = GlobalKey<FormState>();
  final StoreService _storeService = StoreService();

  TextEditingController namaController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();
  TextEditingController kontakController = TextEditingController();
  TextEditingController alamatController = TextEditingController();

  File? _image;
  bool isLoading = false;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final res = await _storeService.createStore(
      namaToko: namaController.text,
      deskripsi: deskripsiController.text,
      kontak: kontakController.text,
      alamat: alamatController.text,
      gambar: _image,
    );

    setState(() => isLoading = false);

    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Toko berhasil dibuat"), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // kirim true agar TokoScreen refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Gagal membuat toko"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Toko")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: _image == null
                    ? Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_a_photo, size: 50),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!, width: 150, height: 150, fit: BoxFit.cover),
                      ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(labelText: "Nama Toko"),
                validator: (val) => val!.isEmpty ? "Nama toko wajib diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: deskripsiController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
                validator: (val) => val!.isEmpty ? "Deskripsi wajib diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: kontakController,
                decoration: const InputDecoration(labelText: "Kontak"),
                validator: (val) => val!.isEmpty ? "Kontak wajib diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: alamatController,
                decoration: const InputDecoration(labelText: "Alamat"),
                validator: (val) => val!.isEmpty ? "Alamat wajib diisi" : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submit,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Buat Toko"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
