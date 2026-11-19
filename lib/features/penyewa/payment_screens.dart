import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app.dart';
import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';
import '../../widgets/slip.dart';
import 'booking_flow_screens.dart';

/// Hitung mundur sederhana (format 23:41:08).
class Countdown extends StatefulWidget {
  const Countdown({super.key, required this.start, this.style});
  final Duration start;
  final TextStyle? style;

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  late Duration _left = widget.start;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_left.inSeconds <= 0) return;
      setState(() => _left -= const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');
    final s =
        '${two(_left.inHours)}:${two(_left.inMinutes % 60)}:${two(_left.inSeconds % 60)}';
    return Text(
      s,
      style: widget.style ?? AppText.monoCode.copyWith(fontSize: 18),
    );
  }
}

/// Header kode booking + badge status.
class KodeHeader extends StatelessWidget {
  const KodeHeader({super.key, required this.kode, required this.status});
  final String kode;
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('Kode $kode', style: AppText.body.muted)),
        StatusBadge(status),
      ],
    );
  }
}

/// 13 · Pembayaran QRIS + unggah bukti.
class PembayaranScreen extends StatefulWidget {
  const PembayaranScreen({
    super.key,
    required this.booking,
    this.ditolak = false,
  });
  final Booking booking;
  final bool ditolak;

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  bool _rincian = false;
  bool _terunggah = false;

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final total = rupiah(b.total);
    final depan = total.substring(0, total.length - 3);
    final belakang = total.substring(total.length - 3);

    return Scaffold(
      appBar: TopBar(
        title: widget.ditolak ? 'Unggah ulang bukti' : 'Pembayaran',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.x16, 0, Gap.x16, Gap.x24),
        children: [
          KodeHeader(kode: b.kode, status: BookingStatus.menungguPembayaran),
          const SizedBox(height: Gap.x12),
          if (widget.ditolak) ...[
            const InfoBanner(
              tone: BannerTone.danger,
              title: 'Bukti pembayaran ditolak',
              message: 'Nominal di bukti Rp1.027.000, kurang Rp573. Transfer kekurangannya atau ulangi dengan nominal sampai 3 digit terakhir, lalu unggah bukti baru.',
            ),
            const SizedBox(height: Gap.x12),
          ],
          InfoBanner(
            tone: BannerTone.warning,
            title: 'Sisa waktu bayar',
            message: 'Batas: Min, 15 Nov · 20.15',
            trailing: Countdown(
              start: const Duration(hours: 23, minutes: 41, seconds: 8),
              style: AppText.monoCode.copyWith(fontSize: 17),
            ),
          ),
          const SizedBox(height: Gap.x12),
          AppCard(
            padding: const EdgeInsets.all(Gap.x20),
            child: Column(
              children: [
                Text(
                  'Total transfer (sampai 3 digit terakhir)',
                  style: AppText.caption.copyWith(fontSize: 13),
                ),
                const SizedBox(height: Gap.x8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: depan, style: AppText.display),
                      TextSpan(
                        text: belakang,
                        style: AppText.display.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.accent,
                          decorationThickness: 2.5,
                        ),
                      ),
                    ],
                  ),
                  semanticsLabel: 'Total transfer $total',
                ),
                const SizedBox(height: Gap.x16),
                Row(
                  children: [
                    Expanded(
                      child: _SoftButton(
                        icon: LucideIcons.copy,
                        label: 'Salin nominal',
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: b.total.toString()),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Nominal $total disalin')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: Gap.x8),
                    Expanded(
                      child: _SoftButton(
                        icon: _rincian
                            ? LucideIcons.chevronUp
                            : LucideIcons.chevronDown,
                        label: 'Rincian biaya',
                        onTap: () => setState(() => _rincian = !_rincian),
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: _rincian
                      ? Padding(
                          padding: const EdgeInsets.only(top: Gap.x16),
                          child: RincianBiaya(booking: b, label: b.kode),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.x12),
          AppCard(
            padding: const EdgeInsets.all(Gap.x20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('QRIS Rapatin', style: AppText.h2),
                          Text(
                            'NMID ID1026 0427 1188',
                            style: AppText.monoLabel,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.text,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'QRIS',
                        style: AppText.monoCode
                            .tint(Colors.white)
                            .copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.x16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: Radii.mdAll,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const FakeQr(size: 180),
                  ),
                ),
                const SizedBox(height: Gap.x12),
                Center(
                  child: Text(
                    'Scan pakai m-banking atau e-wallet apa saja',
                    style: AppText.caption.copyWith(fontSize: 13),
                  ),
                ),
                const SizedBox(height: Gap.x12),
                OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QRIS disimpan ke galeri')),
                  ),
                  icon: const Icon(LucideIcons.download, size: 18),
                  label: const Text('Simpan QRIS'),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.x20),
          Text('Bukti pembayaran', style: AppText.h2),
          const SizedBox(height: 4),
          Text(
            'Foto atau screenshot bukti transfer yang menampilkan nominal dan waktu.',
            style: AppText.caption.copyWith(fontSize: 13),
          ),
          const SizedBox(height: Gap.x12),
          _UploadBox(
            uploaded: _terunggah,
            onTap: () => setState(() => _terunggah = true),
            onRemove: () => setState(() => _terunggah = false),
          ),
          const SizedBox(height: Gap.x16),
          const InfoBanner(
            icon: LucideIcons.shieldCheck,
            message: 'Setelah lunas, kamu bisa membatalkan dalam 2×24 jam (paling lambat 24 jam sebelum acara). Dana kembali penuh kecuali biaya layanan Rp3.000.',
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        note: 'Status jadi Menunggu verifikasi setelah dikirim',
        child: FilledButton(
          onPressed: _terunggah
              ? () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.detailBooking,
                  ModalRoute.withName(Routes.penyewa),
                  arguments: b.copyWith(
                    status: BookingStatus.menungguVerifikasi,
                  ),
                )
              : null,
          child: Text(
            widget.ditolak ? 'Kirim ulang bukti' : 'Kirim bukti bayar',
          ),
        ),
      ),
    );
  }
}

/// 14 · Bukti ditolak: layar pembayaran dengan banner galat.
class BuktiDitolakScreen extends StatelessWidget {
  const BuktiDitolakScreen({super.key, required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) =>
      PembayaranScreen(booking: booking, ditolak: true);
}

class _SoftButton extends StatelessWidget {
  const _SoftButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primarySoft,
      borderRadius: Radii.mdAll,
      child: InkWell(
        borderRadius: Radii.mdAll,
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: AppColors.text),
              const SizedBox(width: 6),
              Text(label, style: AppText.label.copyWith(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({
    required this.uploaded,
    required this.onTap,
    required this.onRemove,
  });
  final bool uploaded;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (uploaded) {
      return AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const IconBox(
              LucideIcons.image,
              size: 52,
              bg: AppColors.successSoft,
              fg: AppColors.success,
            ),
            const SizedBox(width: Gap.x12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'bukti_transfer_0427.jpg',
                    style: AppText.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '284 KB · siap dikirim',
                    style: AppText.caption.tint(AppColors.success),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Hapus bukti',
              onPressed: onRemove,
              icon: const Icon(LucideIcons.x, size: 20),
            ),
          ],
        ),
      );
    }
    return Material(
      color: AppColors.card,
      borderRadius: Radii.lgAll,
      child: InkWell(
        borderRadius: Radii.lgAll,
        onTap: onTap,
        child: CustomPaint(
          painter: _DashedBorder(),
          child: SizedBox(
            height: 132,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const IconBox(LucideIcons.upload, size: 44),
                const SizedBox(height: Gap.x8),
                Text('Unggah bukti transfer', style: AppText.bodyMedium.semi),
                Text('JPG atau PNG, maks 5 MB', style: AppText.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(Radii.lg),
    );
    final path = Path()..addRRect(rrect.deflate(0.75));
    final paint = Paint()
      ..color = AppColors.neutral
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 10) {
        canvas.drawPath(m.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
