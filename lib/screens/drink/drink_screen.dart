import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/wave_painter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../../pages/notifikasi_page.dart';

class DrinkScreen extends StatefulWidget {
  final String token;
  final Function(double, double)? onWaterDataChanged;

  const DrinkScreen({super.key, required this.token, this.onWaterDataChanged});

  @override
  _DrinkScreenState createState() => _DrinkScreenState();
}

class _DrinkScreenState extends State<DrinkScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double totalAirMinum = 0;
  double targetAir = 0;
  double percentage = 0;
  final double takaranMinum = 250;
  String _baseUrl = '';

  @override
  void initState() {
    super.initState();
    _setBaseUrl();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _fetchData();
  }

  void _setBaseUrl() {
    if (kIsWeb) {
      _baseUrl = 'http://127.0.0.1:8000';
    } else if (Platform.isAndroid) {
      _baseUrl = 'http://10.0.2.2:8000';
    } else {
      _baseUrl = 'http://127.0.0.1:8000';
    }
    print('DrinkScreen: Base URL API yang digunakan: $_baseUrl');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;

    try {
      final userResponse = await http.get(
        Uri.parse('$_baseUrl/api/users/target-air'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      final waterIntakeResponse = await http.get(
        Uri.parse('$_baseUrl/api/water-intake/today'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (userResponse.statusCode != 200 ||
          waterIntakeResponse.statusCode != 200) {
        print('DrinkScreen: User Response Body: ${userResponse.body}');
        print(
          'DrinkScreen: Water Intake Response Body: ${waterIntakeResponse.body}',
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
          percentage = targetAir == 0 ? 0 : totalAirMinum / targetAir;
          percentage = percentage.clamp(0.0, 1.0);
          widget.onWaterDataChanged?.call(totalAirMinum, targetAir);
        });
      }
    } catch (e) {
      print("DrinkScreen: Error saat mengambil data awal: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
        setState(() {
          targetAir = 0;
          totalAirMinum = 0;
          percentage = 0;
          widget.onWaterDataChanged?.call(totalAirMinum, targetAir);
        });
      }
    }
  }

  Future<void> postWaterIntake(double volumeMl) async {
    final url = Uri.parse('$_baseUrl/api/water-intake');
    final body = jsonEncode({"volume_ml": volumeMl.toInt()});

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('POST success: ${response.body}');
        await _fetchData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil menambahkan 250 mL air!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('POST gagal: ${response.statusCode} ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambahkan air: ${response.body}')),
          );
        }
      }
    } catch (e) {
      print('Error saat POST data: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error jaringan: $e')));
      }
    }
  }

  void tambahMinum() async {
    await postWaterIntake(takaranMinum);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.white.withOpacity(0.9);
    const primaryColor = Colors.lightBlueAccent;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0288D1), Color(0xFF4FC3F7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context); // Kembali ke HomeScreen
                            },
                            tooltip: 'Back',
                          ),
                          const Text(
                            'MyDyhidrate',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            onPressed: _fetchData,
                            tooltip: 'Segarkan Data',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.notifications,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => NotifikasiPage(
                                        totalAirMinum: totalAirMinum,
                                        targetAir: targetAir,
                                        token: widget.token,
                                      ),
                                ),
                              );
                            },
                            tooltip: 'Lihat Pengingat',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    targetAir == 0
                        ? 'Memuat target...'
                        : 'Target : ${targetAir.toInt()} mL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor.withOpacity(0.8),
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Center(
                    child:
                        targetAir == 0
                            ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text(
                                  'Memuat data...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            )
                            : AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: WavePainter(
                                    percentage,
                                    _animationController.value,
                                  ),
                                  child: Container(
                                    width: 300,
                                    height: 300,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 270,
                                          height: 270,
                                          child: CircularProgressIndicator(
                                            value: percentage,
                                            strokeWidth: 12,
                                            backgroundColor: Colors.white
                                                .withOpacity(0.2),
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(primaryColor),
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.water_drop,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${(percentage * 100).toInt()}%',
                                              style: TextStyle(
                                                fontSize: 48,
                                                fontWeight: FontWeight.bold,
                                                color: textColor,
                                                shadows: [
                                                  Shadow(
                                                    blurRadius: 5.0,
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    offset: Offset(2.0, 2.0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Text(
                    percentage >= 1.0
                        ? 'Anda sudah cukup terhidrasi hari ini!'
                        : 'Tetap minum untuk mencapai target harian!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: tambahMinum,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        elevation: 4,
        tooltip: 'Tambah 250mL',
      ),
    );
  }
}
