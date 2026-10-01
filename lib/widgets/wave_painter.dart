import 'package:flutter/material.dart';
import 'dart:math';

class WavePainter extends CustomPainter {
  final double percentage; // nilai dari 0.0 sampai 1.0, level air
  final double animationValue; // nilai animasi dari 0.0 sampai 1.0

  WavePainter(this.percentage, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint wavePaint =
        Paint()
          ..color = Colors.lightBlueAccent.withOpacity(0.6)
          ..style = PaintingStyle.fill;

    final double waveHeight = 20.0; // tinggi gelombang
    final double waveLength = size.width; // panjang gelombang
    final double baseHeight =
        size.height * (1 - percentage); // tinggi air (posisi dasar gelombang)

    final Path wavePath = Path();

    // Mulai dari kiri bawah
    wavePath.moveTo(0, size.height);

    // Mulai gelombang dari titik kiri di baseHeight
    wavePath.lineTo(0, baseHeight);

    // buat gelombang sinus
    for (double x = 0; x <= size.width; x++) {
      double y =
          waveHeight *
              sin((2 * pi / waveLength) * (x + waveLength * animationValue)) +
          baseHeight;
      wavePath.lineTo(x, y);
    }

    // tutup path ke kanan bawah
    wavePath.lineTo(size.width, size.height);
    wavePath.close();

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.animationValue != animationValue;
  }
}
