import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Untuk mendeteksi web
import 'dart:io' show Platform; // Untuk mendeteksi platform (hanya non-web)

class StatistikPage extends StatefulWidget {
  const StatistikPage({super.key});

  @override
  State<StatistikPage> createState() => _StatistikPageState();
}

class _StatistikPageState extends State<StatistikPage> {
  // Data State
  double todayVolume = 0;
  double todayPercentage = 0; // Ini akan dihitung di Flutter
  double targetMl = 0;

  List<dynamic> weeklyData = [];
  List<dynamic> monthlyData = [];
  List<dynamic> historyData = [];
  bool loading = true;

  // Base URL API (Dinamis berdasarkan platform)
  // Ini akan diinisialisasi di initState()
  String _baseUrl = '';

  @override
  void initState() {
    super.initState();
    _setBaseUrl(); // Atur base URL saat inisialisasi
    fetchAllData(); // Mulai ambil data
  }

  // Fungsi untuk mengatur Base URL berdasarkan platform
  void _setBaseUrl() {
    if (kIsWeb) {
      // Jika berjalan di web (browser)
      _baseUrl = 'http://127.0.0.1:8000';
    } else if (Platform.isAndroid) {
      // Jika berjalan di emulator Android (atau perangkat fisik Android)
      _baseUrl =
          'http://10.0.2.2:8000'; // IP khusus emulator untuk host machine
    } else {
      // Untuk platform lain seperti iOS Simulator/Desktop/Perangkat Fisik iOS
      // Anda mungkin perlu menyesuaikan ini dengan IP lokal komputer Anda
      _baseUrl = 'http://127.0.0.1:8000'; // Default ke localhost
    }
    print('Base URL API yang digunakan: $_baseUrl'); // Untuk debugging
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchAllData() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      if (mounted) {
        // PENTING: Cek mounted sebelum setState/navigasi
        Navigator.of(context).pushReplacementNamed(
          '/login',
        ); // Arahkan ke login jika tidak ada token
      }
      return;
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token', // Sertakan token di header
    };

    try {
      final responses = await Future.wait([
        http.get(
          Uri.parse('$_baseUrl/api/water-intake/today'),
          headers: headers,
        ),
        http.get(
          Uri.parse('$_baseUrl/api/water-intake/weekly'),
          headers: headers,
        ),
        http.get(
          Uri.parse('$_baseUrl/api/water-intake/monthly'),
          headers: headers,
        ),
        http.get(
          Uri.parse('$_baseUrl/api/water-intake/history'),
          headers: headers,
        ),
        http.get(Uri.parse('$_baseUrl/api/users/target-air'), headers: headers),
      ]);

      // Periksa status code setiap respons dan cetak body untuk debugging
      for (var i = 0; i < responses.length; i++) {
        print(
          'Response from ${responses[i].request?.url.path}: Status ${responses[i].statusCode}, Body: ${responses[i].body}',
        ); // DEBUGGING: CETAK RESPONS API LENGKAP
        if (responses[i].statusCode != 200) {
          throw Exception(
            "API call failed for ${responses[i].request?.url.path} with status ${responses[i].statusCode}",
          );
        }
      }

      final todayData = jsonDecode(responses[0].body);
      final weeklyRawData = jsonDecode(responses[1].body);
      final monthlyRawData = jsonDecode(responses[2].body);
      final historyRawData = jsonDecode(responses[3].body);
      final targetData = jsonDecode(responses[4].body);

      if (mounted) {
        // PENTING: Cek mounted sebelum setState
        setState(() {
          // Parsing data hari ini (menggunakan .toString() dan double.tryParse untuk keamanan)
          // Perhatikan 'data' key di respons API Laravel Anda
          todayVolume =
              double.tryParse(
                todayData['data']['total_volume_ml']?.toString() ?? '0',
              ) ??
              0;

          // Parsing target air harian (sesuaikan key API response: target_ml atau target_air_harian_ml)
          // Perhatikan 'data' key di respons API Laravel Anda
          targetMl =
              double.tryParse(
                targetData['data']['target_air_harian_ml']?.toString() ?? '0',
              ) ??
              double.tryParse(
                targetData['data']['target_ml']?.toString() ?? '0',
              ) ??
              0;

          // --- PERBAIKAN: Hitung todayPercentage di sini ---
          todayPercentage = targetMl == 0 ? 0 : (todayVolume / targetMl) * 100;
          todayPercentage = todayPercentage.clamp(
            0.0,
            100.0,
          ); // Batasi persentase antara 0% dan 100%
          // --- AKHIR PERBAIKAN ---

          // Pastikan data adalah List, jika tidak, set ke List kosong
          weeklyData =
              (weeklyRawData['data'] is List) ? weeklyRawData['data'] : [];
          monthlyData =
              (monthlyRawData['data'] is List) ? monthlyRawData['data'] : [];
          historyData =
              (historyRawData['data'] is List) ? historyRawData['data'] : [];

          loading = false; // Set loading menjadi false setelah data didapatkan
        });
      }
    } catch (e) {
      print(
        "Error fetching data in StatistikPage: $e",
      ); // Cetak error untuk debugging
      if (mounted) {
        setState(() {
          loading = false;
          // Anda mungkin ingin menampilkan pesan error di UI di sini jika data gagal dimuat
        });
      }
    }
  }

  Widget buildStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget buildTodayVolumeCard() {
    return buildStatCard(
      "Hari Ini",
      "${todayVolume.toInt()} ml", // Pastikan ditampilkan sebagai int untuk ml
      Colors.indigo,
      Icons.water,
    );
  }

  Widget buildTodayTargetCard() {
    return buildStatCard(
      "Target",
      "${todayPercentage.toStringAsFixed(1)}%", // Asumsi persentase sudah dari API
      Colors.teal,
      Icons.percent,
    );
  }

  Widget buildWeeklyChart() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (weeklyData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Tidak ada data mingguan untuk ditampilkan."),
        ),
      );
    }
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < 0 || index >= weeklyData.length) {
                    return const SizedBox.shrink();
                  }
                  String tanggal = weeklyData[index]['tanggal'] ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      tanggal.length >= 10 ? tanggal.substring(5, 10) : tanggal,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
                interval: 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              spots: [
                for (int i = 0; i < weeklyData.length; i++)
                  FlSpot(
                    i.toDouble(),
                    double.tryParse(
                          weeklyData[i]['total_ml']?.toString() ?? '0',
                        ) ??
                        0,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMonthlySummary() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (monthlyData.isEmpty)
      return const Center(child: Text("Tidak ada data bulanan."));
    return Column(
      children:
          monthlyData.map((item) {
            String bulan = item['bulan'] ?? 'Tidak diketahui';
            String total = (item['total_ml']?.toString() ?? '0');
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(blurRadius: 4, color: Colors.black12),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bulan,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${double.tryParse(total) ?? 0} ml',
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget buildHistoryList() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (historyData.isEmpty)
      return const Center(child: Text("Tidak ada riwayat minum."));
    return Column(
      children:
          historyData.map((item) {
            String tanggal = item['tanggal'] ?? '-';
            String volume = (item['volume_ml']?.toString() ?? '0');
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(blurRadius: 4, color: Colors.black12),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tanggal),
                  Text(
                    '${double.tryParse(volume) ?? 0} ml',
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 70,
      floating: false,
      pinned: true,
      backgroundColor: Colors.blue.shade600,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white), 
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          'Statistik',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade400, Colors.blue.shade600],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child:
                loading
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hallo 👋",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Ini ringkasan konsumsi air kamu",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildTodayVolumeCard(),
                              const SizedBox(width: 16),
                              buildTodayTargetCard(),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Aktivitas Mingguan",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          buildWeeklyChart(),
                          const SizedBox(height: 20),
                          const Text(
                            "Ringkasan Bulanan",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          buildMonthlySummary(),
                          const SizedBox(height: 20),
                          const Text(
                            "Riwayat Minum",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          buildHistoryList(),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
