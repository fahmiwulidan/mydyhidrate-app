import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        ),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Aksen Gambar Logo atau Ilustrasi
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Image.asset(
                'assets/logo.jpeg', // pastikan gambar tersedia di folder assets dan dicantumkan di pubspec.yaml
                width: 120,
                height: 120,
              ),
            ),

            // Judul
            const Text(
              'MediHydrate',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),

            // Tombol Login
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
                shadowColor: Colors.black54,
              ),
              child: const Text('Login'),
            ),

            const SizedBox(height: 20),

            // Tombol Register
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
                shadowColor: Colors.black26,
              ),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

