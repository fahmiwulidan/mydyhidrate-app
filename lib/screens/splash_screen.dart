import 'package:flutter/material.dart';
import 'package:medihydrateapp/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'landing_page.dart'; // Pastikan path ini benar
import 'login_screen.dart'; // Pastikan path ini benar

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  }); // <<< PERBAIKAN: Tambahkan const constructor dengan super.key

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Cek izin notifikasi
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    _checkLoginStatus();
  }

Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print('--- Cek Status Login di SplashScreen ---');
    print('Token diambil dari SharedPreferences: $token');
    print('------------------------------------');

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      if (token != null && token.isNotEmpty) {
        print(
          'SplashScreen: Token ditemukan, navigasi ke HomeScreen.',
        ); // <<< GANTI KE HOMESCREEN
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ), // <<< GANTI KE HOMESCREEN
        );
      } else {
        print('SplashScreen: Token TIDAK ditemukan, navigasi ke LoginScreen.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // Pastikan 'assets/logo.jpeg' ada di folder 'assets' dan terdaftar di pubspec.yaml
        child: Image.asset('assets/logo.jpg', width: 150, height: 150),
      ),
    );
  }
}
