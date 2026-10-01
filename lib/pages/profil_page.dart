import 'package:flutter/material.dart';
import 'package:medihydrateapp/screens/drink/drink_screen.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../screens/login_screen.dart';
import '../services/storage.dart';
import 'edit_profile_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> with TickerProviderStateMixin {
  User? user;
  bool loading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isTargetAirHovered = false;
  bool _isBeratHovered = false;
  bool _isTinggiHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    loadUser();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void loadUser() async {
    try {
      final fetchedUser = await UserService.fetchUserProfile();
      if (!mounted) return;

      if (fetchedUser == null) {
        await Storage.clearToken();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
        return;
      }

      print('ProfilPage: User data loaded: ${fetchedUser.toJson()}');

      setState(() {
        user = fetchedUser;
        loading = false;
      });
      _animationController.forward();
    } catch (e) {
      print("ProfilPage: Error memuat profil: $e");
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat profil: $e"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body:
          loading
              ? _buildLoadingState()
              : (user == null ? _buildErrorState() : _buildProfileContent()),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Container(
              width: 180,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 150,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Memuat Profil...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.red.shade400, Colors.red.shade600],
        ),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade600),
              const SizedBox(height: 16),
              Text(
                'Gagal Memuat Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Terjadi kesalahan saat memuat data profil. Silakan coba lagi.',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    loading = true;
                  });
                  loadUser();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileHeader(),
                _buildProfileStats(),
                _buildProfileInfo(),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 70,
      floating: false,
      pinned: true,
      backgroundColor: Colors.blue.shade600,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          'Profil Saya',
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
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            if (user != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProfilePage(user: user!)),
              ).then((value) {
                if (value == true) {
                  loadUser();
                }
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          Hero(
            tag: 'profile_avatar',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage:
                      user?.imageUrl != null && user!.imageUrl!.isNotEmpty
                          ? NetworkImage(user!.imageUrl!)
                          : const AssetImage('assets/logo.jpg')
                              as ImageProvider,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Nama Pengguna',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${user?.username ?? 'username_anda'}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              'Member Reguler', // Dinamis jika ada field isPremium
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats() {
    final targetAir =
        user?.targetAir != null
            ? (user!.targetAir! / 1000).toStringAsFixed(1)
            : null;
    final estimatedTargetAir =
        user?.beratBadan != null
            ? ((user!.beratBadan! * 35) / 1000).toStringAsFixed(1)
            : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.monitor_weight_outlined,
              label: 'Berat',
              value:
                  user?.beratBadan != null
                      ? '${user!.beratBadan} kg'
                      : 'Belum diisi',
              color: Colors.green.shade400,
              onTap:
                  user?.beratBadan == null
                      ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(user: user!),
                        ),
                      ).then((value) {
                        if (value == true) loadUser();
                      })
                      : null,
              subText: user?.beratBadan == null ? 'Isi di edit profil' : null,
              isHovered: _isBeratHovered,
              onHover: (hovered) {
                setState(() {
                  _isBeratHovered = hovered;
                });
              },
            ),
          ),
          VerticalDivider(color: Colors.grey.shade300, indent: 8, endIndent: 8),
          Expanded(
            child: _buildStatItem(
              icon: Icons.height,
              label: 'Tinggi',
              value:
                  user?.tinggiBadan != null
                      ? '${user!.tinggiBadan} cm'
                      : 'Belum diisi',
              color: Colors.orange.shade400,
              onTap:
                  user?.tinggiBadan == null
                      ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(user: user!),
                        ),
                      ).then((value) {
                        if (value == true) loadUser();
                      })
                      : null,
              subText: user?.tinggiBadan == null ? 'Isi di edit profil' : null,
              isHovered: _isTinggiHovered,
              onHover: (hovered) {
                setState(() {
                  _isTinggiHovered = hovered;
                });
              },
            ),
          ),
          VerticalDivider(color: Colors.grey.shade300, indent: 8, endIndent: 8),
          Expanded(
            child: _buildStatItem(
              icon: Icons.water_drop,
              label: 'Target Air',
              value:
                  targetAir != null
                      ? '$targetAir L'
                      : (estimatedTargetAir != null
                          ? '$estimatedTargetAir L'
                          : 'Belum diisi'),
              color: Colors.blue.shade400,
              onTap: () async {
                try {
                  final token = await Storage.readToken();
                  if (token != null && user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DrinkScreen(token: token),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Sesi telah berakhir. Silakan login kembali.',
                        ),
                        backgroundColor: Colors.red.shade400,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  }
                } catch (e) {
                  print('Error navigating to DrinkScreen: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal membuka halaman minum: $e'),
                      backgroundColor: Colors.red.shade400,
                    ),
                  );
                }
              },
              subText:
                  targetAir == null && user?.beratBadan == null
                      ? 'Isi berat badan untuk perhitungan'
                      : (targetAir == null && estimatedTargetAir != null
                          ? 'Ketuk untuk minum hari ini!'
                          : null),
              isHovered: _isTargetAirHovered,
              onHover: (hovered) {
                setState(() {
                  _isTargetAirHovered = hovered;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
    String? subText,
    required bool isHovered,
    required ValueChanged<bool> onHover,
  }) {
    return InkWell(
      onTap: onTap,
      onHover: onHover,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isHovered ? color.withOpacity(0.1) : Colors.transparent,
          border: isHovered ? Border.all(color: color, width: 1) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    value == 'Belum diisi'
                        ? Colors.red.shade400
                        : Colors.grey[800],
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(
              height: 14, // Tinggi tetap untuk subText
              child:
                  subText != null
                      ? Text(
                        subText,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Informasi Personal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          _buildInfoTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user?.email ?? 'Email Tidak Tersedia',
            color: Colors.red.shade400,
          ),
          _buildInfoTile(
            icon: Icons.person_outline,
            label: 'Username',
            value: user?.username ?? 'Username Tidak Tersedia',
            color: Colors.purple.shade400,
          ),
          _buildInfoTile(
            icon: Icons.monitor_weight_outlined,
            label: 'Berat Badan',
            value:
                user?.beratBadan != null
                    ? '${user!.beratBadan} kg'
                    : 'Belum diisi',
            color: Colors.green.shade400,
          ),
          _buildInfoTile(
            icon: Icons.height,
            label: 'Tinggi Badan',
            value:
                user?.tinggiBadan != null
                    ? '${user!.tinggiBadan} cm'
                    : 'Belum diisi',
            color: Colors.orange.shade400,
            isLastItem: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isLastItem = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border:
            isLastItem
                ? null
                : Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        value == 'Belum diisi'
                            ? Colors.red.shade400
                            : Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfilePage(user: user!),
                    ),
                  ).then((value) {
                    if (value == true) {
                      loadUser();
                    }
                  });
                }
              },
              icon: const Icon(Icons.edit, size: 20, color: Colors.white),
              label: const Text(
                'Edit Profil',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        'Konfirmasi Logout',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: const Text(
                        'Apakah Anda yakin ingin keluar dari aplikasi?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Batal',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await Storage.clearToken();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.logout, size: 20, color: Colors.red.shade600),
              label: Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.red.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
