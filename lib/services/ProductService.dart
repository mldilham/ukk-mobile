import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductService {
  final String baseUrl = "https://learncode.biz.id/api";

  /// =============================
  /// AMBIL SEMUA PRODUK (PUBLIC)
  /// =============================
  Future<List<dynamic>> getProducts() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/products"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["success"] == true ? data["data"] ?? [] : [];
      }
      return [];
    } catch (e) {
      print("Error getProducts: $e");
      return [];
    }
  }

  /// =============================
  /// AMBIL PRODUK TOKO USER
  /// =============================
  Future<List<dynamic>> getStoreProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";
      if (token.isEmpty) return [];

      final res = await http.get(
        Uri.parse("$baseUrl/stores/products"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["success"] == true &&
            data["data"] != null &&
            data["data"]["produk"] != null) {
          return List<dynamic>.from(data["data"]["produk"]);
        }
      }
      return [];
    } catch (e) {
      print("Error getStoreProducts: $e");
      return [];
    }
  }

  /// =============================
  /// AMBIL DETAIL PRODUK BERDASARKAN ID
  /// =============================
  Future<Map<String, dynamic>> getProductDetail(String id) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/products/$id/show"));
      return jsonDecode(res.body);
    } catch (e) {
      print("Error getProductDetail: $e");
      return {"success": false, "message": "Gagal mengambil detail produk"};
    }
  }

  /// =============================
  /// SIMPAN / UPDATE PRODUK
  /// =============================
  Future<Map<String, dynamic>> saveProduct({
    String? id,
    required String namaProduk,
    required String deskripsi,
    required String harga,
    required String stok,
    required String idKategori,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final res = await http.post(
        Uri.parse("$baseUrl/products/save"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          if (id != null) "id_produk": id,
          "nama_produk": namaProduk,
          "deskripsi": deskripsi,
          "harga": harga,
          "stok": stok,
          "id_kategori": idKategori,
        },
      );

      return jsonDecode(res.body);
    } catch (e) {
      print("Error saveProduct: $e");
      return {"success": false, "message": "Gagal menyimpan produk: $e"};
    }
  }

  /// =============================
  /// HAPUS PRODUK
  /// =============================
  Future<Map<String, dynamic>> deleteProduct(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";
      if (token.isEmpty)
        return {"success": false, "message": "Token tidak ditemukan"};

      final uri = Uri.parse("$baseUrl/products/$id/delete");

      // Ubah menjadi request POST
      final res = await http.post(
        uri,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("DELETE STATUS: ${res.statusCode}");
      print("DELETE BODY: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {
          "success": data["success"] == true,
          "message":
              data["message"] ??
              (data["success"] == true
                  ? "Produk berhasil dihapus"
                  : "Gagal menghapus produk"),
        };
      } else {
        return {
          "success": false,
          "message": "Server error: ${res.statusCode} - ${res.body}",
        };
      }
    } catch (e) {
      print("Error deleteProduct: $e");
      return {"success": false, "message": "Gagal menghapus produk: $e"};
    }
  }

  /// =============================
  /// AMBIL PRODUK BERDASARKAN KATEGORI
  /// =============================
  Future<List<dynamic>> getProductsByCategory(int categoryId) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/products/category/$categoryId"),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["success"] == true ? data["data"] ?? [] : [];
      }
      return [];
    } catch (e) {
      print("Error getProductsByCategory: $e");
      return [];
    }
  }
}
