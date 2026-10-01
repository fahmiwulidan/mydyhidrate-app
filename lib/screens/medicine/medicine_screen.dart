import 'package:flutter/material.dart';
import '../../models/medicine.dart';
import '../../services/medicine_service.dart';
import 'add_medicine_page.dart';
import 'edit_medicine_page.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({Key? key}) : super(key: key);

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  late Future<List<Medicine>> _medicinesFuture;

  @override
  void initState() {
    super.initState();
    _medicinesFuture = MedicineService.fetchMedicines();
  }

  void _refreshMedicines() {
    setState(() {
      _medicinesFuture = MedicineService.fetchMedicines();
    });
  }

  void _toggleMedicineStatus(Medicine medicine) async {
    final success = await MedicineService.toggleTaken(medicine.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            medicine.taken
                ? '${medicine.name} ditandai sebagai belum diminum'
                : '${medicine.name} ditandai sebagai sudah diminum',
          ),
          backgroundColor: medicine.taken ? Colors.red : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      _refreshMedicines();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui status obat')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Daftar Obat'),
        backgroundColor: Colors.pinkAccent,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Medicine>>(
        future: _medicinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.pinkAccent),
            );
          } else if (snapshot.hasError) {
            print('Error fetching medicines: ${snapshot.error}');
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada obat',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final medicines = snapshot.data!;
          print(
            'Medicines loaded: ${medicines.map((m) => m.description).toList()}',
          );

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final medicine = medicines[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.pink.shade50,
                    child: const Icon(
                      Icons.medication,
                      color: Colors.pinkAccent,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    medicine.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Dosis : ${medicine.dose}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      Text(
                        'Waktu : ${medicine.time}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      Text(
                        'Durasi : ${medicine.duration} hari',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      if (medicine.description != null &&
                          medicine.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Deskripsi : ${medicine.description}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _toggleMedicineStatus(medicine),
                        child: Row(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                medicine.taken
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                key: ValueKey<bool>(medicine.taken),
                                color:
                                    medicine.taken ? Colors.green : Colors.red,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              medicine.taken
                                  ? 'Sudah diminum'
                                  : 'Belum diminum',
                              style: TextStyle(
                                color:
                                    medicine.taken ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.pinkAccent),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      EditMedicinePage(medicine: medicine),
                            ),
                          ).then((value) {
                            if (value == true) {
                              print(
                                'EditMedicinePage returned true, refreshing medicines',
                              );
                              _refreshMedicines();
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Hapus Obat'),
                                  content: Text(
                                    'Apakah Anda yakin ingin menghapus ${medicine.name}?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text(
                                        'Batal',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                          );

                          if (confirm == true) {
                            final success =
                                await MedicineService.deleteMedicine(
                                  medicine.id,
                                );
                            if (success) {
                              _refreshMedicines();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gagal menghapus obat'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicinePage()),
          ).then((value) {
            if (value == true) {
              print('AddMedicinePage returned true, refreshing medicines');
              _refreshMedicines();
            }
          });
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        elevation: 4,
        tooltip: 'Tambah Obat',
      ),
    );
  }
}
