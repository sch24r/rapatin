import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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

/// Bukti transfer yang dipilih dari kamera atau galeri.
class _Bukti {
  const _Bukti(this.file, this.nama, this.ukuran);
  final File file;
  final String nama;
  final int ukuran;
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  static const _maksUkuran = 5 * 1024 * 1024;
  static const _ekstensi = {'jpg', 'jpeg', 'png'};

  final _picker = ImagePicker();
  bool _rincian = false;
  _Bukti? _bukti;
  bool _memuat = false;

  bool get _terunggah => _bukti != null;

  @override
  void initState() {
    super.initState();
    _pulihkanPilihan();
  }

  /// Android bisa menutup aplikasi saat kamera terbuka. Ambil lagi fotonya.
  Future<void> _pulihkanPilihan() async {
    if (!Platform.isAndroid) return;
    try {
      final lost = await _picker.retrieveLostData();
      final f = lost.file;
      if (f != null && mounted) await _terima(f);
    } on PlatformException {
      // Tidak ada pilihan yang tertinggal.
    }
  }

  void _pesan(String teks) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> _pilihSumber() async {
    final sumber = await showModalBottomSheet<ImageSource>(
      context: context,
      useSafeArea: true,
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.x16, 0, Gap.x16, Gap.x16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, Gap.x12),
                child: Text('Unggah bukti transfer', style: AppText.h2),
              ),
              _SumberTile(
                icon: LucideIcons.image,
                title: 'Pilih dari galeri',
                subtitle: 'Screenshot bukti dari m-banking atau e-wallet',
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: Gap.x8),
              _SumberTile(
                icon: LucideIcons.camera,
                title: 'Ambil foto',
                subtitle: 'Foto struk atau layar HP lain',
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
    if (sumber == null || !mounted) return;

    setState(() => _memuat = true);
    try {
      final f = await _picker.pickImage(
        source: sumber,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 85,
      );
      if (f != null && mounted) await _terima(f);
    } on PlatformException catch (e) {
      if (!mounted) return;
      _pesan(
        e.code.contains('access_denied')
            ? 'Izin ${sumber == ImageSource.camera ? 'kamera' : 'galeri'} ditolak. Aktifkan di Pengaturan HP.'
            : 'Gagal membuka ${sumber == ImageSource.camera ? 'kamera' : 'galeri'}. Coba lagi.',
      );
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  Future<void> _terima(XFile f) async {
    final ext = f.name.contains('.')
        ? f.name.split('.').last.toLowerCase()
        : '';
    if (!_ekstensi.contains(ext)) {
      _pesan('Format belum didukung. Pakai JPG atau PNG.');
      return;
    }
    final ukuran = await f.length();
    if (!mounted) return;
    if (ukuran > _maksUkuran) {
      _pesan('Ukuran ${ukuranFile(ukuran)}, maksimal 5 MB. Pilih gambar lain.');
      return;
    }
    // image_picker menamai ulang file hasil kompres (mis. scaled_36.jpg),
    // jadi tampilkan nama yang mudah dikenali.
    final nama = 'bukti_${widget.booking.kode}.${ext == 'jpeg' ? 'jpg' : ext}';
    setState(() => _bukti = _Bukti(File(f.path), nama, ukuran));
  }

  void _lihatBukti() {
    final b = _bukti;
    if (b == null) return;
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.all(Gap.x16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: InteractiveViewer(
                maxScale: 4,
                child: Image.file(b.file, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Gap.x16,
                Gap.x8,
                Gap.x8,
                Gap.x8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      b.nama,
                      style: AppText.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            bukti: _bukti,
            memuat: _memuat,
            onTap: _memuat ? null : _pilihSumber,
            onPreview: _lihatBukti,
            onRemove: () => setState(() => _bukti = null),
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

class _SumberTile extends StatelessWidget {
  const _SumberTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          IconBox(icon, size: 44),
          const SizedBox(width: Gap.x12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.bodyMedium.semi),
                Text(subtitle, style: AppText.caption),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({
    required this.bukti,
    required this.memuat,
    required this.onTap,
    required this.onPreview,
    required this.onRemove,
  });
  final _Bukti? bukti;
  final bool memuat;
  final VoidCallback? onTap;
  final VoidCallback onPreview;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final b = bukti;
    if (b != null) {
      return AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Semantics(
              button: true,
              label: 'Lihat bukti transfer',
              child: GestureDetector(
                onTap: onPreview,
                child: ClipRRect(
                  borderRadius: Radii.smAll,
                  child: Image.file(
                    b.file,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    cacheWidth: 168,
                    errorBuilder: (_, _, _) => const IconBox(
                      LucideIcons.image,
                      size: 56,
                      bg: AppColors.successSoft,
                      fg: AppColors.success,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: Gap.x12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.nama,
                    style: AppText.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${ukuranFile(b.ukuran)} · siap dikirim',
                    style: AppText.caption.tint(AppColors.success),
                  ),
                  const SizedBox(height: 2),
                  InkWell(
                    onTap: onTap,
                    child: Text(
                      'Ganti gambar',
                      style: AppText.label.tint(AppColors.primary),
                    ),
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
                if (memuat)
                  const SizedBox(
                    width: 44,
                    height: 44,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  )
                else
                  const IconBox(LucideIcons.upload, size: 44),
                const SizedBox(height: Gap.x8),
                Text(
                  memuat ? 'Membuka…' : 'Unggah bukti transfer',
                  style: AppText.bodyMedium.semi,
                ),
                Text(
                  'Dari galeri atau kamera · JPG/PNG, maks 5 MB',
                  style: AppText.caption,
                ),
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
