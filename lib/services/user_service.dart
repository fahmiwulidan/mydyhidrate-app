import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'storage.dart';

class UserService {
  static final String baseUrl =
      'http://127.0.0.1:8000/api/user'; // Untuk Web Biasa 
    //'http://10.0.2.2:8000/api/user'; // Untuk emulator Android

  // Ambil data profil user
  static Future<User?> fetchUserProfile() async {
    final token = await Storage.readToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return User.fromJson(jsonData['data']);
    } else {
      print('Gagal fetch profile: ${response.statusCode}');
      print('Response: ${response.body}');
      return null;
    }
  }

  // Update data profil user
  static Future<bool> updateProfile({
    required String name,
    required String username,
    required String email,
    required String beratBadan,
    required String tinggiBadan,
  }) async {
    final token = await Storage.readToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'username': username,
        'email': email,
        'berat_badan': beratBadan,
        'tinggi_badan': tinggiBadan,
      }),
    );

    if (response.statusCode == 200) {
      print('Profil berhasil diperbarui.');
      return true;
    } else {
      print('Gagal update profile: ${response.statusCode}');
      print('Response: ${response.body}');
      return false;
    }
  }
}
