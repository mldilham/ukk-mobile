import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreService {
  final String baseUrl = "https://learncode.biz.id/api";

  /// Ambil data toko user
  Future<Map<String, dynamic>?> getStore() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null || token.isEmpty) {
        print("TOKEN TIDAK ADA!");
        return null;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/stores"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && data["data"] != null) {
          return data["data"];
        }
      }

      return null;
    } catch (e) {
      print("Error StoreService: $e");
      return null;
    }
  }

  /// Buat toko baru
  Future<Map<String, dynamic>> createStore({
    required String namaToko,
    required String deskripsi,
    required String kontak,
    required String alamat,
    File? gambar,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null || token.isEmpty) {
        return {"success": false, "message": "Token tidak ditemukan"};
      }

      var uri = Uri.parse("$baseUrl/stores/save");
      var request = http.MultipartRequest('POST', uri);

      request.headers["Authorization"] = "Bearer $token";
      request.fields['nama_toko'] = namaToko;
      request.fields['deskripsi'] = deskripsi;
      request.fields['kontak_toko'] = kontak;
      request.fields['alamat'] = alamat;

      if (gambar != null) {
        final mimeType = lookupMimeType(gambar.path)?.split('/');
        if (mimeType != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'gambar',
              gambar.path,
              contentType: MediaType(mimeType[0], mimeType[1]),
            ),
          );
        }
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(responseBody);
        return {
          "success": true,
          "message": data["message"] ?? "Toko berhasil dibuat",
          "data": data["data"],
        };
      } else {
        return {
          "success": false,
          "message": "Server error (${response.statusCode})",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }

  /// Hapus toko berdasarkan ID
  Future<Map<String, dynamic>> deleteStore(String idStore) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null || token.isEmpty) {
        return {"success": false, "message": "Token tidak ditemukan"};
      }

      final response = await http.post(
        Uri.parse("$baseUrl/stores/$idStore/delete"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {"success": false, "message": "Gagal menghapus toko"};
      }
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }
}
