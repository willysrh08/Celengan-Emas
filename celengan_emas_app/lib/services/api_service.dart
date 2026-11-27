import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Hasil autentikasi yang dikembalikan setelah login berhasil.
class AuthResult {
  const AuthResult({required this.token, required this.message});

  final String token;
  final String message;
}

/// Kesalahan API yang sudah diterjemahkan menjadi pesan pengguna.
class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();

  // Gunakan 10.0.2.2 untuk Android Emulator, atau IP lokal komputer (misal: 192.168.x.x) jika pakai HP asli
  static const String baseUrl = 'http://localhost:8000/api';
  static const String tokenKey = 'sanctum_token';
  static const Duration _timeout = Duration(seconds: 15);
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Jembatan sementara antara PIN 4 digit pada UI dan password di backend.
  /// Backend belum menerima PIN, jadi PIN + email diubah menjadi password
  /// deterministik yang memenuhi syarat minimal 8 karakter dan `confirmed`.
  static String passwordFromPin(String pin, String email) {
    return 'CE-$pin-${email.trim().toLowerCase()}';
  }

  /// Backend saat ini hanya mengenali email, sehingga nomor WhatsApp dipetakan
  /// ke alias email yang stabil agar alur login WhatsApp tetap dapat dikirim.
  static String emailFromPhone(String phone) {
    return 'wa${normalizePhone(phone)}@celengan.local';
  }

  static String normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('62')) {
      return digits;
    }
    if (digits.startsWith('0')) {
      return '62${digits.substring(1)}';
    }
    if (digits.startsWith('8')) {
      return '62$digits';
    }
    return digits;
  }

  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final payload = await _post('/login', <String, String>{
      'email': email,
      'password': password,
    });

    final data = payload['data'];
    final token = data is Map ? data['token'] : payload['token'];
    if (token is! String || token.isEmpty) {
      throw const ApiException('Server tidak mengembalikan token autentikasi.');
    }
    await saveToken(token);

    return AuthResult(
      token: token,
      message: payload['message'] is String
          ? payload['message'] as String
          : 'Login berhasil.',
    );
  }

  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _post('/register', <String, String>{
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });
  }

  static Future<void> sendOtp({
    required String target,
    required String type,
  }) async {
    await _post('/send-otp', <String, String>{
      'target': target,
      'type': type,
    });
  }

  static Future<void> verifyOtp({
    required String target,
    required String type,
    required String code,
  }) async {
    await _post('/verify-otp', <String, String>{
      'target': target,
      'type': type,
      'code': code,
    });
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
  }

  static Future<String?> readToken() async {
    return _storage.read(key: tokenKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: tokenKey);
  }

  /// Data akun yang sedang login (GET /api/user). Dipakai di halaman Profil.
  static Future<Map<String, dynamic>> getUser() async {
    final token = await readToken();
    if (token == null) {
      throw const ApiException('Kamu belum login.');
    }
    final http.Response response;
    try {
      response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      ).timeout(_timeout);
    } catch (_) {
      throw const ApiException('Tidak dapat terhubung ke server.');
    }
    if (response.statusCode != 200) {
      throw const ApiException('Sesi login berakhir. Silakan masuk lagi.');
    }
    final decoded = json.decode(response.body);
    final data = decoded is Map && decoded['data'] is Map ? decoded['data'] : decoded;
    final user = data is Map && data['user'] is Map ? data['user'] : data;
    return Map<String, dynamic>.from(user as Map);
  }

  /// Keluar dari akun (POST /api/logout) lalu hapus token yang tersimpan.
  /// Token tetap dihapus walaupun server tidak bisa dihubungi.
  static Future<void> logout() async {
    final token = await readToken();
    if (token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
        ).timeout(_timeout);
      } catch (_) {
        // Abaikan: yang penting token di perangkat terhapus.
      }
    }
    await clearToken();
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

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, String> body,
  ) async {
    final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: const <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: body,
          )
          .timeout(_timeout);
    } catch (_) {
      throw const ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const ApiException('Respon server tidak dapat dibaca.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('Format respon server tidak dikenali.');
    }

    final isSuccess = response.statusCode >= 200 &&
        response.statusCode < 300 &&
        decoded['success'] != false;
    if (isSuccess) {
      return decoded;
    }

    throw ApiException(_errorMessage(decoded, response.statusCode));
  }

  static String _errorMessage(Map<String, dynamic> payload, int statusCode) {
    final errors = payload['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final messages = <String>[];
      errors.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          messages.add('$key: ${value.first}');
        } else if (value is String) {
          messages.add('$key: $value');
        }
      });
      if (messages.isNotEmpty) {
        return messages.join('\n');
      }
    }

    final message = payload['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
    if (statusCode == 401) {
      return 'Sesi berakhir. Silakan masuk kembali.';
    }
    if (statusCode >= 500) {
      return 'Server sedang bermasalah. Silakan coba lagi nanti.';
    }
    return 'Permintaan gagal (kode $statusCode).';
  }
}
