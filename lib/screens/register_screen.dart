import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    // Ensure the API URL is correct for your backend
    // INGAT: SESUAIKAN DENGAN LINGKUNGAN ANDA!
    // - Emulator Android: 'http://10.0.2.2:8000/api/register'
    // - Perangkat Fisik: 'http://<IP_LOKAL_KOMPUTER_ANDA>:8000/api/register'
    // - Flutter Web/Desktop: 'http://127.0.0.1:8000/api/register'
    final String apiUrl = 'http://127.0.0.1:8000/api/register';
                       // 'http://10.0.2.2:8000/api/register'

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'username': _usernameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'password_confirmation': _confirmPasswordController.text,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 201) {
        // 201 Created for successful registration
        // Opsional: API Anda mungkin mengembalikan token saat register.
        // Jika ya, Anda bisa menyimpannya di sini (seperti di LoginScreen).
        // final data = jsonDecode(response.body);
        // final String token = data['token'];
        // _saveToken(token);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        // Handle registration failure and display error message from Laravel
        String errorMessage =
            'Registrasi gagal. Silakan coba lagi.'; // Default message
        try {
          final errorJson = jsonDecode(response.body); // Coba decode respons
          if (errorJson is Map<String, dynamic>) {
            // Jika ada kunci 'message' (misalnya dari custom error Laravel)
            if (errorJson.containsKey('message')) {
              errorMessage = errorJson['message'];
            }
            // Jika ada kunci 'errors' (misalnya dari 422 Unprocessable Entity - validasi gagal)
            else if (errorJson.containsKey('errors')) {
              Map<String, dynamic> validationErrors = errorJson['errors'];
              if (validationErrors.isNotEmpty) {
                // Ambil pesan error pertama dari field pertama yang ditemukan
                // Misalnya: {'email': ['The email has already been taken.'], 'password': ['The password confirmation does not match.']}
                // Kita ambil pesan error pertama yang ditemukan
                errorMessage = validationErrors.values.first[0];
              }
            }
          }
        } catch (eParse) {
          // Jika gagal memparsing respons (misalnya respons bukan JSON, atau error 500 dari server tanpa JSON)
          print(
            'Failed to parse error response from Laravel (register): $eParse',
          );
          errorMessage =
              'Registrasi gagal: Server mengembalikan respons yang tidak terduga.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal daftar: $errorMessage', // Menampilkan pesan error spesifik
            ),
          ),
        );
      }
    } catch (eNetwork) {
      // Tangani error jaringan (misalnya, server tidak respons, tidak ada internet)
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error jaringan: $eNetwork. Periksa koneksi internet atau status server.', // Pesan spesifik untuk error jaringan
          ),
        ),
      );
    }
  }

  void _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_alt, size: 80, color: Colors.blue[700]),
              SizedBox(height: 16),
              Text(
                "Register",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.alternate_email),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text(
                  'Sudah punya akun? Login',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
