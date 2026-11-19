import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../data/models.dart';

enum SlipCap {
  terkonfirmasi('TERKONFIRMASI', AppColors.primary),
  lunas('LUNAS', AppColors.success),
  menunggu('MENUNGGU', AppColors.warning);

  const SlipCap(this.label, this.color);
  final String label;
  final Color color;
}

/// Slip reservasi khas Rapatin: kertas, label mono, garis putus-putus, dan cap.
class SlipReservasi extends StatelessWidget {
  const SlipReservasi({
    super.key,
    required this.booking,
    this.cap,
    this.compact = false,
  });

  final Booking booking;
  final SlipCap? cap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final rows = <(String, String)>[
      ('Panitia', b.organisasi.replaceAll(' Teknik', '')),
      ('Jumlah', '${b.orang} orang'),
      (
        'Waktu',
        '${tanggalPendek(b.tanggal)} · ${jam(b.jamMulai)}–${jam(b.jamSelesai)}',
      ),
      ('Ruang', b.room.nama),
      if (!compact) ('Total', rupiah(b.total)),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(Radii.md),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A2B1D14),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('SLIP RESERVASI', style: AppText.monoLabel)),
              Text('#${b.kode}', style: AppText.monoLabel),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            b.venue.nama.toUpperCase(),
            style: AppText.h1.copyWith(letterSpacing: -0.2),
          ),
          const SizedBox(height: 4),
          for (final (k, v) in rows) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: [
                  Text(k, style: AppText.body.muted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      v,
                      textAlign: TextAlign.right,
                      style: AppText.bodyMedium.semi,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFE4DCC6)),
          ],
          const SizedBox(height: 10),
          const _DashedLine(),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Dipesan lewat\naplikasi Rapatin',
                  style: AppText.monoLabel.copyWith(letterSpacing: 0.4),
                ),
              ),
              if (cap != null) Stamp(cap!),
            ],
          ),
        ],
      ),
    );
  }
}

/// Cap miring bergaya stempel.
class Stamp extends StatelessWidget {
  const Stamp(this.cap, {super.key});
  final SlipCap cap;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -6 * math.pi / 180,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: cap.color, width: 2.5),
        ),
        child: Text(
          cap.label,
          style: AppText.monoCode.tint(cap.color).copyWith(fontSize: 15),
        ),
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final count = (c.maxWidth / 9).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(width: 5, height: 1.5, color: AppColors.neutral),
          ),
        );
      },
    );
  }
}

/// QR dekoratif untuk QRIS statis (bukan QR asli; nanti diganti gambar QRIS resmi).
class FakeQr extends StatelessWidget {
  const FakeQr({super.key, this.size = 200, this.seed = 427});
  final double size;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Kode QRIS Rapatin',
      image: true,
      child: CustomPaint(size: Size.square(size), painter: _QrPainter(seed)),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.seed);
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    const n = 25;
    final cell = size.width / n;
    final paint = Paint()..color = AppColors.text;
    final rnd = math.Random(seed);

    bool inFinder(int x, int y) {
      bool box(int ox, int oy) =>
          x >= ox && x < ox + 7 && y >= oy && y < oy + 7;
      return box(0, 0) || box(n - 7, 0) || box(0, n - 7);
    }

    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (inFinder(x, y)) continue;
        if (rnd.nextDouble() < 0.47) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell + 0.4, cell + 0.4),
            paint,
          );
        }
      }
    }

    void finder(int ox, int oy) {
      final o = Offset(ox * cell, oy * cell);
      canvas.drawRect(o & Size(7 * cell, 7 * cell), paint);
      canvas.drawRect(
        (o + Offset(cell, cell)) & Size(5 * cell, 5 * cell),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        (o + Offset(2 * cell, 2 * cell)) & Size(3 * cell, 3 * cell),
        paint,
      );
    }

    finder(0, 0);
    finder(n - 7, 0);
    finder(0, n - 7);
  }

  @override
  bool shouldRepaint(covariant _QrPainter old) => old.seed != seed;
}
