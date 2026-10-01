import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../pages/home_page.dart';
import '../pages/statistik_page.dart';
import '../pages/notifikasi_page.dart';
import '../pages/profil_page.dart';
import '../screens/drink/drink_screen.dart';
import '../screens/medicine/medicine_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _popupValue = 'Air Minum';
  String _token = '';
  String _userName = 'Pengguna';
  double totalAirMinum = 0;
  double targetAir = 0;

  @override
  void initState() {
    super.initState();
    _loadPrefsAndFetchData();
  }

  Future<void> _loadPrefsAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _token = prefs.getString('token') ?? '';
        _userName = prefs.getString('userName') ?? 'Pengguna';
      });
      if (_token.isNotEmpty) {
        await _fetchWaterData();
      }
    }
  }

  Future<void> _fetchWaterData() async {
    const String baseUrl = 'http://127.0.0.1:8000';
    try {
      final userResponse = await http.get(
        Uri.parse('$baseUrl/api/users/target-air'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final waterIntakeResponse = await http.get(
        Uri.parse('$baseUrl/api/water-intake/today'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (userResponse.statusCode != 200 ||
          waterIntakeResponse.statusCode != 200) {
        print('HomeScreen: User Response Body: ${userResponse.body}');
        print(
          'HomeScreen: Water Intake Response Body: ${waterIntakeResponse.body}',
        );
        throw Exception(
          'Gagal ambil data. User: ${userResponse.statusCode}, Air: ${waterIntakeResponse.statusCode}',
        );
      }

      final userData = jsonDecode(userResponse.body)['data'];
      final waterData = jsonDecode(waterIntakeResponse.body)['data'];

      if (mounted) {
        setState(() {
          targetAir =
              double.tryParse(
                userData['target_air_harian_ml']?.toString() ?? '0',
              ) ??
              0;
          totalAirMinum =
              double.tryParse(
                waterData['total_volume_ml']?.toString() ?? '0',
              ) ??
              0;
        });
      }
    } catch (e) {
      print("HomeScreen: Error saat mengambil data air: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data air: $e')));
      }
    }
  }

  void _updateWaterData(double newTotalAirMinum, double newTargetAir) {
    setState(() {
      totalAirMinum = newTotalAirMinum;
      targetAir = newTargetAir;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onPopupSelected(String value) {
    setState(() {
      _popupValue = value;
      _selectedIndex = 2;
    });

    if (value == 'Air Minum') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DrinkScreen(
            token: _token,
            onWaterDataChanged: _updateWaterData,
          ),
        ),
      ).then((_) {
        setState(() {
          _selectedIndex = 0; // Kembali ke HomePage
        });
      });
    } else if (value == 'Obat') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MedicineScreen()),
      ).then((_) {
        setState(() {
          _selectedIndex = 0; // Kembali ke HomePage
        });
      });
    }
  }

  IconData _getFabIcon() {
    if (_popupValue == 'Air Minum') return Icons.local_drink;
    if (_popupValue == 'Obat') return Icons.medical_services;
    return Icons.add;
  }

  Future<void> _showPopupMenu() async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          Offset(
            MediaQuery.of(context).size.width / 2,
            MediaQuery.of(context).size.height -
                kBottomNavigationBarHeight -
                56,
          ),
          Offset(
            MediaQuery.of(context).size.width / 2,
            MediaQuery.of(context).size.height -
                kBottomNavigationBarHeight -
                56,
          ),
        ),
        Offset.zero & MediaQuery.of(context).size,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'Air Minum',
          child: Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.local_drink, color: Colors.blue, size: 28),
                SizedBox(width: 12),
                Text(
                  'Air Minum',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Obat',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.medical_services, color: Colors.pink, size: 28),
                SizedBox(width: 12),
                Text(
                  'Obat',
                  style: TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      elevation: 8.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
    );

    if (result != null) {
      _onPopupSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomePage(userName: _userName),
      const StatistikPage(),
      // TengahPage(pilihan: _popupValue), // Uncomment and import if TengahPage exists
      Container(), // Placeholder: Replace with the correct widget if needed
      NotifikasiPage(
        totalAirMinum: totalAirMinum,
        targetAir: targetAir,
        token: _token,
      ),
      ProfilPage(),
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.blue[800],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              color:
                  _selectedIndex == 0
                      ? Colors.white
                      : Colors.white.withOpacity(0.6),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              color:
                  _selectedIndex == 1
                      ? Colors.white
                      : Colors.white.withOpacity(0.6),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 48.0),
            IconButton(
              icon: const Icon(Icons.notifications),
              color:
                  _selectedIndex == 3
                      ? Colors.white
                      : Colors.white.withOpacity(0.6),
              onPressed: () => _onItemTapped(3),
            ),
            IconButton(
              icon: const Icon(Icons.person),
              color:
                  _selectedIndex == 4
                      ? Colors.white
                      : Colors.white.withOpacity(0.6),
              onPressed: () => _onItemTapped(4),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _showPopupMenu,
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        child: Icon(
          _getFabIcon(),
          color: _popupValue == 'Obat' ? Colors.pink : Colors.blue[800],
        ),
      ),
    );
  }
}
