import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisService {
  final String baseUrl = "https://learncode.biz.id/api";

  /// Fungsi register user
  Future<Map<String, dynamic>> register({
    required String nama,
    required String kontak,
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/register");

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "nama": nama,
          "kontak": kontak,
          "username": username,
          "password": password,
        },
      );

      // Tangani response code 200, 201, dan 204
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = response.body.isNotEmpty ? json.decode(response.body) : {};

        // Simpan token jika ada
        if (jsonData["token"] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", jsonData["token"]);
        }

        return {
          "success": jsonData["success"] ?? true,
          "message": jsonData["message"] ?? "Registrasi berhasil",
          "data": jsonData["data"],
          "token": jsonData["token"],
        };
      } else if (response.statusCode == 204) {
        // Tidak ada body, tapi registrasi berhasil
        return {
          "success": true,
          "message": "Registrasi berhasil",
        };
      } else {
        // Semua code selain di atas dianggap gagal
        return {
          "success": false,
          "message": "Server error (${response.statusCode})"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Terjadi kesalahan: $e"
      };
    }
  }
}
