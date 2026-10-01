import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/medicine.dart';
import '../../services/medicine_service.dart';

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({Key? key}) : super(key: key);

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _timeController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  void _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Format waktu ke H:i
    String formattedTime;
    try {
      final parsedTime = DateFormat('h:mm a').parse(_timeController.text);
      formattedTime = DateFormat('HH:mm').format(parsedTime);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Format waktu tidak valid')));
      setState(() => _isLoading = false);
      return;
    }

    final newMedicine = Medicine(
      id: 0,
      userId: 1, // Ganti dengan user login bila ada
      name: _nameController.text,
      dose: _doseController.text,
      time: formattedTime,
      duration: int.tryParse(_durationController.text) ?? 0,
      taken: false,
      takenAt: null,
      description:
          _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
      reminderTime: null,
      createdAt: null,
      updatedAt: null,
      schedules: null,
    );

    print('Saving medicine with description: ${newMedicine.description}');

    try {
      final result = await MedicineService.addMedicine(newMedicine);
      if (result != null) {
        print('Medicine saved successfully: ${result.description}');
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal menyimpan obat')));
      }
    } catch (e) {
      print('Error menyimpan obat: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType inputType = TextInputType.text,
    Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        validator: validator,
        readOnly: onTap != null,
        onTap: onTap,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.pink),
          labelText: label,
          filled: true,
          fillColor: Colors.pink.shade50,
          labelStyle: const TextStyle(color: Colors.black87),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.pinkAccent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.pink.shade100),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tambah Obat'),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Nama Obat',
                icon: Icons.medication,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Nama obat wajib diisi'
                            : null,
              ),
              _buildTextField(
                controller: _doseController,
                label: 'Dosis Obat',
                icon: Icons.vaccines,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Dosis wajib diisi'
                            : null,
              ),
              _buildTextField(
                controller: _timeController,
                label: 'Waktu Konsumsi',
                icon: Icons.schedule,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Waktu wajib diisi'
                            : null,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    _timeController.text = pickedTime.format(context);
                  }
                },
              ),
              _buildTextField(
                controller: _durationController,
                label: 'Durasi (hari)',
                icon: Icons.calendar_today,
                inputType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Durasi wajib diisi';
                  final val = int.tryParse(value);
                  if (val == null || val <= 0)
                    return 'Durasi harus berupa angka > 0';
                  return null;
                },
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'Deskripsi (opsional)',
                icon: Icons.description,
                validator: (value) => null, // Opsional, tidak perlu validasi
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt),
                  label: const Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // Warna teks putih
                      fontWeight: FontWeight.w600, // Tebal sedikit
                    ),
                  ),
                  onPressed: _isLoading ? null : _saveMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
