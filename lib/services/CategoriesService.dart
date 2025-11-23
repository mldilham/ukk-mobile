import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryService {
  final String baseUrl = "https://learncode.biz.id/api";

  Future<List<dynamic>> getCategories() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/categories"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["success"] == true) {
          return data["data"];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
