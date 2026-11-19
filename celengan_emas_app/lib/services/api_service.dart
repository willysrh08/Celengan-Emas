import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Gunakan 10.0.2.2 untuk Android Emulator, atau IP lokal komputer (misal: 192.168.x.x) jika pakai HP asli
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Fungsi Login untuk mendapatkan Token Sanctum
  static Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Accept': 'application/json'},
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token']; // Mengembalikan token akses
    }
    return null;
  }

  // Fungsi Mengambil Data Portofolio Emas (Sesuai Halaman Home)
  static Future<Map<String, dynamic>> getGoldAssets(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/gold-assets'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat data portofolio emas');
    }
  }
}