import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/storage.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController beratBadanController;
  late TextEditingController tinggiBadanController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name ?? '');
    usernameController = TextEditingController(
      text: widget.user.username ?? '',
    );
    emailController = TextEditingController(text: widget.user.email ?? '');
    beratBadanController = TextEditingController(
      text: widget.user.beratBadan?.toString() ?? '',
    );
    tinggiBadanController = TextEditingController(
      text: widget.user.tinggiBadan?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    beratBadanController.dispose();
    tinggiBadanController.dispose();
    super.dispose();
  }

  void saveProfile() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama dan Email tidak boleh kosong')),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final String name = nameController.text.trim();
      final String username = usernameController.text.trim();
      final String email = emailController.text.trim();
      final String? beratBadan =
          beratBadanController.text.trim().isNotEmpty
              ? beratBadanController.text.trim()
              : null;
      final String? tinggiBadan =
          tinggiBadanController.text.trim().isNotEmpty
              ? tinggiBadanController.text.trim()
              : null;

      final success = await UserService.updateProfile(
        name: name,
        username: username,
        email: email,
        beratBadan: beratBadanController.text,
        tinggiBadan: tinggiBadanController.text,

      );

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui!')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal memperbarui profil. Silakan coba lagi.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50!, Colors.blue.shade100!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              _buildTextField(
                controller: nameController,
                labelText: 'Nama Lengkap',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: usernameController,
                labelText: 'Username',
                icon: Icons.alternate_email,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: emailController,
                labelText: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                enabled: false,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: beratBadanController,
                labelText: 'Berat Badan (kg)',
                icon: Icons.monitor_weight_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: tinggiBadanController,
                labelText: 'Tinggi Badan (cm)',
                icon: Icons.height,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: saveProfile,
                          icon: const Icon(Icons.save, size: 20),
                          label: const Text('Simpan Perubahan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.cancel,
                            size: 20,
                            color: Colors.grey,
                          ),
                          label: const Text('Batal'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon:
            icon != null ? Icon(icon, color: Colors.blue.shade700) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade800!, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade200!, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
    );
  }
}
