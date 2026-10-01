import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart'; // Asumsi ini adalah HomeScreen
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import 'splash_screen.dart'; // Import SplashScreen (untuk navigasi setelah logout jika diperlukan)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // Tambahkan const constructor

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Base URL API (SESUAIKAN DENGAN LINGKUNGAN ANDA!)
  // Ini harus sesuai dengan di StatistikPage dan AuthController.
  // - Emulator Android: 'http://10.0.2.2:8000'
  // - Flutter Web/Desktop: 'http://127.0.0.1:8000'
  // - Perangkat Fisik: 'http://<IP_LOKAL_KOMPUTER_ANDA>:8000'
  static const String _baseUrl =
      'http://127.0.0.1:8000'; // Contoh untuk Flutter Web/Desktop

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final String apiUrl = '$_baseUrl/api/login'; // Menggunakan _baseUrl

    try {
      // DEBUGGING: Print input Flutter sebelum dikirim
      print('--- Input Flutter Sebelum Dikirim ---');
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
      print('------------------------------------');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['token']; // Token yang sudah kita simpan

        // <<< PERBAIKAN DI SINI: Ambil userName dari respons API & simpan ke SharedPreferences >>>
        // Asumsi API Laravel Anda mengembalikan struktur data seperti:
        // {"message": "Login successful", "user": {"id": 1, "name": "Nama User", "email": "user@example.com"}, "token": "..."}
        final String fetchedUserName =
            data['user']['name'] ??
            'Pengguna'; // Ambil 'name' dari objek 'user'
        // Jika struktur API Anda berbeda (misal: 'data['name']'), sesuaikan 'data['user']['name']' ini.
        // >>>

        // DEBUGGING: Print token & userName yang diterima & disimpan
        print('--- Login Sukses ---');
        print('Token diterima dari Laravel: $token');
        print('Username diterima dari Laravel: $fetchedUserName');
        // >>>

        // Save the token & userName securely using shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString(
          'userName',
          fetchedUserName,
        ); // <<< BARIS INI PENTING: SIMPAN USERNAME

        print('Token berhasil disimpan ke SharedPreferences.');
        print('Username berhasil disimpan ke SharedPreferences.');

        // Show a success message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));

        // Navigate to the home screen upon successful login
        if (mounted) {
          // Pastikan widget masih terpasang sebelum navigasi
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ), // Added const HomeScreen()
          );
        }
      } else {
        // Handle login failure and display error message from Laravel
        String errorMessage = 'Login failed. Please check your credentials.';

        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson is Map<String, dynamic>) {
            if (errorJson.containsKey('message')) {
              errorMessage = errorJson['message'];
            } else if (errorJson.containsKey('errors')) {
              Map<String, dynamic> validationErrors = errorJson['errors'];
              if (validationErrors.isNotEmpty) {
                errorMessage = validationErrors.values.first[0];
              }
            }
          }
        } catch (eParse) {
          print('Failed to parse error response from Laravel: $eParse');
          errorMessage =
              'Login failed: Server returned an unexpected response format.';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed: $errorMessage')));
      }
    } catch (eNetwork) {
      // Handle network or other exceptions
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error jaringan: $eNetwork. Periksa koneksi internet atau status server.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.medical_services, size: 80, color: Colors.blue[900]),
              const SizedBox(height: 20),
              Text(
                'MediHydrate',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Login to continue',
                style: TextStyle(fontSize: 16, color: Colors.blueGrey[700]),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: Colors.blue[700]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue[200]!, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.blue[700]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue[200]!, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child:
                    _isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue[800]!,
                            ),
                          ),
                        )
                        : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                style: TextButton.styleFrom(),
                child: Text(
                  "Don't have an account? Register here",
                  style: TextStyle(color: Colors.blue[700], fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
