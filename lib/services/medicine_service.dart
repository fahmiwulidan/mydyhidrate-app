import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medicine.dart';
import 'storage.dart';

class MedicineService {
  static const String baseUrl =
      'http://127.0.0.1:8000/api/medicines'; // Untuk Web
  // static const String baseUrl = 'http://10.0.2.2:8000/api/medicines'; // Untuk emulator Android

  // Ambil token dari storage
  static Future<String?> _getToken() async {
    final token = await Storage.readToken();
    if (token == null) {
      print('Token tidak ditemukan, user mungkin belum login');
      return null;
    }
    return token;
  }

  // Ambil semua data medicine user
  static Future<List<Medicine>> fetchMedicines() async {
    final token = await _getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Fetch medicines - Status: ${response.statusCode}');
      print('Fetch medicines - Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> medicinesJson = json.decode(response.body);
        final medicines =
            medicinesJson.map((json) => Medicine.fromJson(json)).toList();
        print(
          'Fetch medicines - Parsed descriptions: ${medicines.map((m) => m.description).toList()}',
        );
        return medicines;
      } else {
        print('Gagal fetch medicines: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error saat fetchMedicines: $e');
      return [];
    }
  }

  // Tambah medicine
  static Future<Medicine?> addMedicine(Medicine medicine) async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      final encoded = json.encode(medicine.toJson(includeId: false));
      print('Add medicine - Request JSON: $encoded');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: encoded,
      );

      print('Add medicine - Status: ${response.statusCode}');
      print('Add medicine - Body: ${response.body}');
      try {
        print('Add medicine - JSON: ${json.decode(response.body)}');
      } catch (e) {
        print('Add medicine - Gagal mengurai JSON: $e');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['data'] != null) {
          return Medicine.fromJson(jsonData['data']);
        } else {
          return Medicine.fromJson(jsonData);
        }
      } else {
        print('Gagal tambah medicine: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error saat addMedicine: $e');
      return null;
    }
  }

  // Update medicine
  static Future<Medicine?> updateMedicine(Medicine medicine) async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      final url = '$baseUrl/${medicine.id}';
      final encoded = json.encode(medicine.toJson());
      print('Update medicine - Request JSON: $encoded');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: encoded,
      );

      print('Update medicine - Status: ${response.statusCode}');
      print('Update medicine - Body: ${response.body}');
      try {
        print('Update medicine - JSON: ${json.decode(response.body)}');
      } catch (e) {
        print('Update medicine - Gagal mengurai JSON: $e');
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['data'] != null) {
          return Medicine.fromJson(jsonData['data']);
        } else {
          return Medicine.fromJson(jsonData);
        }
      } else {
        print('Gagal update medicine: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error saat updateMedicine: $e');
      return null;
    }
  }

  // Toggle taken status obat
  static Future<bool> toggleTaken(int id) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final url = '$baseUrl/$id/toggle-taken';

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Toggle taken - Status: ${response.statusCode}');
      print('Toggle taken - Body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error saat toggleTaken: $e');
      return false;
    }
  }

  // Delete medicine
  static Future<bool> deleteMedicine(int id) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final url = '$baseUrl/$id';

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Delete medicine - Status: ${response.statusCode}');
      print('Delete medicine - Body: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error saat deleteMedicine: $e');
      return false;
    }
  }
}
