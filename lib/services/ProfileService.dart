import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileService {
  final String baseUrl = "https://learncode.biz.id/api";

  // ==========================
  // GET PROFILE
  // ==========================
  Future<Map<String, dynamic>> getProfile(String token) async {
    final url = Uri.parse("$baseUrl/profile");

    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["success"] == true) {
          return {
            "success": true,
            "data": jsonData["data"],
          };
        }
        return {
          "success": false,
          "message": jsonData["message"] ?? "Gagal mengambil profile",
        };
      } else {
        return {
          "success": false,
          "message": "Server error (${response.statusCode})",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Tidak dapat terhubung ke server",
      };
    }
  }

  // ==========================
  // UPDATE PROFILE
  // ==========================
  Future<Map<String, dynamic>> updateProfile({
    required String nama,
    required String username,
    required String kontak,
    required String token,
  }) async {
    final url = Uri.parse("$baseUrl/profile/update");

    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          "nama": nama,
          "username": username,
          "kontak": kontak,
        },
      );

      final jsonData = json.decode(response.body);
      return jsonData;
    } catch (e) {
      return {
        "success": false,
        "message": "Tidak dapat terhubung ke server",
      };
    }
  }

  // ==========================
  // LOGOUT
  // ==========================
  Future<Map<String, dynamic>> logout(String token) async {
    final url = Uri.parse("$baseUrl/logout");

    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["success"] == true) {
          return {
            "success": true,
            "message": jsonData["message"] ?? "Logout berhasil",
          };
        } else {
          return {
            "success": false,
            "message": jsonData["message"] ?? "Logout gagal",
          };
        }
      } else {
        return {
          "success": false,
          "message": "Server error (${response.statusCode})",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Tidak dapat terhubung ke server",
      };
    }
  }
}
