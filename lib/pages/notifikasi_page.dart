import 'package:flutter/material.dart';
import '../../services/medicine_service.dart';
import '../../models/medicine.dart';
import '../../screens/drink/drink_screen.dart';

class NotifikasiPage extends StatefulWidget {
  final double totalAirMinum;
  final double targetAir;
  final String token;

  const NotifikasiPage({
    super.key,
    required this.totalAirMinum,
    required this.targetAir,
    required this.token,
  });

  @override
  _NotifikasiPageState createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage>
    with SingleTickerProviderStateMixin {
  late Future<List<Medicine>> _medicinesFuture;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _medicinesFuture = MedicineService.fetchMedicines();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          content: Text('${medicine.name} ditandai sebagai sudah diminum'),
          backgroundColor: Colors.green,
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
          'Notifikasi',
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
    final bool targetAirBelumTercapai = widget.totalAirMinum < widget.targetAir;

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20.0,
                ),
                child: Column(
                  children: [
                    // Pengingat Air
                    if (targetAirBelumTercapai)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DrinkScreen(token: widget.token),
                            ),
                          );
                        },
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Card(
                              elevation: 4,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: Colors.blueAccent.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade50,
                                      Colors.blue.shade100.withOpacity(
                                        _animationController.value * 0.5 + 0.5,
                                      ),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: const Icon(
                                    Icons.water_drop,
                                    color: Colors.blueAccent,
                                    size: 48,
                                  ),
                                  title: const Text(
                                    'Pengingat Minum Air',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Target : ${widget.targetAir.toInt()} mL, Tercapai : ${widget.totalAirMinum.toInt()} mL',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Minum ${(widget.targetAir - widget.totalAirMinum).toInt()} mL lagi!',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Minum airmu sekarang!',
                                        style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.blueAccent,
                                    size: 20,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    // Pengingat Obat
                    FutureBuilder<List<Medicine>>(
                      future: _medicinesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.pinkAccent,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          print('Error fetching medicines: ${snapshot.error}');
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        final medicines =
                            snapshot.data!.where((m) => !m.taken).toList();

                        if (medicines.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Column(
                              children:
                                  medicines.map((medicine) {
                                    return Card(
                                      elevation: 4,
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: Colors.redAccent.withOpacity(
                                            0.3,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.pink.shade50,
                                              Colors.pink.shade100.withOpacity(
                                                _animationController.value *
                                                        0.5 +
                                                    0.5,
                                              ),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.all(
                                            16,
                                          ),
                                          leading: const Icon(
                                            Icons.medical_services,
                                            color: Colors.redAccent,
                                            size: 48,
                                          ),
                                          title: Text(
                                            medicine.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Waktu : ${medicine.time}',
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'Dosis : ${medicine.dose}',
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 14,
                                                ),
                                              ),
                                              if (medicine.description !=
                                                      null &&
                                                  medicine
                                                      .description!
                                                      .isNotEmpty)
                                                Text(
                                                  'Deskripsi : ${medicine.description}',
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                    fontSize: 14,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(
                                              Icons.error_outline,
                                              color: Color.fromARGB(255, 255, 28, 28),
                                              size: 28,
                                            ),
                                            onPressed:
                                                () => _toggleMedicineStatus(
                                                  medicine,
                                                ),
                                            tooltip:
                                                'Tandai sebagai sudah diminum',
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            );
                          },
                        );
                      },
                    ),
                    // Pesan jika tidak ada pengingat
                    if (!targetAirBelumTercapai)
                      FutureBuilder<List<Medicine>>(
                        future: _medicinesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox.shrink();
                          }
                          final medicines =
                              snapshot.data?.where((m) => !m.taken).toList() ??
                              [];
                          if (medicines.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(
                                'Semua target air dan obat hari ini sudah tercapai!',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
