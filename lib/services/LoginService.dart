import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  final String baseUrl = "https://learncode.biz.id/api";

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
      },
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // LOGIN GAGAL
      if (jsonData["success"] == false) {
        return {
          "success": false,
          "message": jsonData["message"],
        };
      }

      // LOGIN BERHASIL → simpan token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", jsonData["token"]);

      return {
        "success": true,
        "token": jsonData["token"],
        "data": jsonData["data"],
      };
    } else {
      return {
        "success": false,
        "message": "Terjadi kesalahan server (${response.statusCode})"
      };
    }
  }
}
