class User {
  final String name;
  final String username;
  final String? imageUrl;
  final String? email;
  final double? beratBadan; // Ubah ke double untuk mendukung desimal
  final double? tinggiBadan; // Ubah ke double untuk mendukung desimal
  final int? targetAir; // Dalam mL, sesuai DrinkScreen

  User({
    required this.name,
    required this.username,
    this.imageUrl,
    this.email,
    this.beratBadan,
    this.tinggiBadan,
    this.targetAir,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name']?.toString() ?? 'Nama Tidak Diketahui',
      username: json['username']?.toString() ?? 'user_unknown',
      imageUrl: json['image_url']?.toString(),
      email: json['email']?.toString(),
      beratBadan: _parseDouble(json['berat_badan']),
      tinggiBadan: _parseDouble(json['tinggi_badan']),
      targetAir: _parseInt(json['target_air_harian_ml']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'image_url': imageUrl,
      'email': email,
      'berat_badan': beratBadan,
      'tinggi_badan': tinggiBadan,
      'target_air_harian_ml': targetAir,
    };
  }

  // Helper untuk parsing double dengan aman
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.'));
    }
    return null;
  }

  // Helper untuk parsing int dengan aman
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
