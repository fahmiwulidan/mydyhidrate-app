import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/login',
    ); // Perbaiki URL dan endpoint

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Respons Body: ${response.body}'); // Debugging
        final token = data['token']; // Pastikan key 'token' sesuai respons API
        if (token == null) {
          print('Token tidak ditemukan dalam respons!');
          return false;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        print('Login berhasil! Token: $token');
        return true;
      } else {
        print('Login Gagal. Status Code: ${response.statusCode}');
        print('Respons Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Terjadi error jaringan atau koneksi: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
