import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app.dart';
import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/dummy_data.dart';
import '../../data/models.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/slip.dart';
import 'payment_screens.dart';

/// 15 & 16 · Status booking, slip reservasi, pembatalan, dan booking final.
class DetailBookingScreen extends StatefulWidget {
  const DetailBookingScreen({super.key, required this.booking});
  final Booking booking;

  @override
  State<DetailBookingScreen> createState() => _DetailBookingScreenState();
}

class _DetailBookingScreenState extends State<DetailBookingScreen> {
  late BookingStatus _status = widget.booking.status;
  bool _final = false;

  Booking get b => widget.booking.copyWith(status: _status);

  SlipCap? get _cap => switch (_status) {
    BookingStatus.lunas ||
    BookingStatus.selesai => _final ? SlipCap.terkonfirmasi : SlipCap.lunas,
    BookingStatus.menungguKonfirmasi ||
    BookingStatus.menungguPembayaran ||
    BookingStatus.menungguVerifikasi => SlipCap.menunggu,
    _ => null,
  };

  Future<void> _ajukanBatal() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      builder: (c) => Padding(
        padding: const EdgeInsets.fromLTRB(Gap.x20, 0, Gap.x20, Gap.x24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Batalkan booking ${b.kode}?', style: AppText.h2),
            const SizedBox(height: Gap.x8),
            Text(
              'Slot di ${b.venue.nama} akan dilepas. Dana dikembalikan ke rekening asal dalam 1–3 hari kerja.',
              style: AppText.body.muted,
            ),
            const SizedBox(height: Gap.x16),
            Container(
              padding: const EdgeInsets.all(Gap.x16),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: Radii.mdAll,
              ),
              child: Column(
                children: [
                  PriceRow('Dibayar', rupiah(b.total)),
                  PriceRow(
                    'Biaya layanan (tidak kembali)',
                    '−${rupiah(Booking.biayaLayanan)}',
                    discount: true,
                  ),
                  PriceRow(
                    'Dana kembali',
                    rupiah(b.total - Booking.biayaLayanan),
                    total: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.x20),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Ya, batalkan booking'),
            ),
            const SizedBox(height: Gap.x8),
            OutlinedButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Tetap booking'),
            ),
          ],
        ),
      ),
    );
    if (ok == true) setState(() => _status = BookingStatus.refundDiproses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(title: 'Detail booking'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.x16, 0, Gap.x16, Gap.x32),
        children: [
          KodeHeader(kode: b.kode, status: _status),
          const SizedBox(height: Gap.x16),
          SlipReservasi(booking: b, cap: _cap),
          const SizedBox(height: Gap.x16),
          if (_status == BookingStatus.lunas) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => showSoon(context, 'Bagikan ke WhatsApp'),
                    icon: const Icon(LucideIcons.share2, size: 18),
                    label: const Text('Bagikan ke WA'),
                  ),
                ),
                const SizedBox(width: Gap.x8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => showSoon(context, 'Unduh kuitansi'),
                    icon: const Icon(LucideIcons.download, size: 18),
                    label: const Text('Kuitansi'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gap.x16),
          ],
          ..._statusPanel(),
          const SizedBox(height: Gap.x24),
          Text('Status booking', style: AppText.h2),
          const SizedBox(height: Gap.x16),
          ..._timeline(),
          const SizedBox(height: Gap.x24),
          _DemoPanel(children: _demoActions()),
        ],
      ),
    );
  }

  List<Widget> _statusPanel() {
    switch (_status) {
      case BookingStatus.menungguKonfirmasi:
        return const [
          InfoBanner(
            tone: BannerTone.warning,
            title: 'Menunggu konfirmasi mitra',
            message: 'Mitra biasanya membalas dalam 15 menit. Kamu akan dapat notifikasi saat diterima.',
          ),
        ];
      case BookingStatus.menungguPembayaran:
        return [
          const InfoBanner(
            tone: BannerTone.warning,
            title: 'Mitra menerima booking',
            message: 'Bayar penuh lewat QRIS Rapatin dalam 24 jam agar slot tidak dilepas.',
          ),
          const SizedBox(height: Gap.x12),
          FilledButton(
            onPressed: () =>
                Navigator.pushNamed(context, Routes.pembayaran, arguments: b),
            child: const Text('Bayar sekarang'),
          ),
        ];
      case BookingStatus.menungguVerifikasi:
        return const [
          InfoBanner(
            title: 'Bukti sedang diverifikasi',
            message: 'Admin Rapatin mencocokkan nominal dan kode unik. Paling lama 1×24 jam.',
          ),
        ];
      case BookingStatus.lunas when _final:
        return const [
          InfoBanner(
            tone: BannerTone.success,
            icon: LucideIcons.shieldCheck,
            title: 'Booking final',
            message: 'Masa pembatalan sudah lewat. Tunjukkan slip ini ke kasir saat datang.',
          ),
        ];
      case BookingStatus.lunas:
        return [
          InfoBanner(
            tone: BannerTone.warning,
            title: 'Masa pembatalan',
            message: 'Bisa dibatalkan sampai Sen, 16 Nov · 20.15. Setelah itu booking final.',
            trailing: Countdown(
              start: const Duration(hours: 5, minutes: 42, seconds: 10),
              style: AppText.monoCode.copyWith(fontSize: 15),
            ),
          ),
          const SizedBox(height: Gap.x12),
          OutlinedButton.icon(
            onPressed: _ajukanBatal,
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
            icon: const Icon(LucideIcons.calendarX, size: 18),
            label: const Text('Ajukan pembatalan'),
          ),
        ];
      case BookingStatus.selesai:
        return [
          FilledButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, Routes.rating, arguments: b),
            icon: const Icon(LucideIcons.star, size: 18),
            label: const Text('Beri rating'),
          ),
        ];
      case BookingStatus.refundDiproses:
        return [
          InfoBanner(
            tone: BannerTone.warning,
            title: 'Refund diproses',
            message:
                '${rupiah(b.total - Booking.biayaLayanan)} dikirim ke rekening asal dalam 1–3 hari kerja.',
          ),
        ];
      case BookingStatus.refundSelesai:
        return const [
          InfoBanner(
            tone: BannerTone.success,
            title: 'Refund selesai',
            message: 'Dana sudah dikembalikan ke rekening asal.',
          ),
        ];
      case BookingStatus.ditolak:
        return const [
          InfoBanner(
            tone: BannerTone.danger,
            title: 'Ditolak mitra',
            message: 'Slot ternyata sudah terpakai. Coba jam lain atau tempat serupa.',
          ),
        ];
      case BookingStatus.kedaluwarsa:
        return const [
          InfoBanner(
            tone: BannerTone.danger,
            title: 'Kedaluwarsa',
            message: 'Pembayaran tidak diterima dalam 24 jam, slot dilepas.',
          ),
        ];
      case BookingStatus.dibatalkan:
        return const [
          InfoBanner(
            tone: BannerTone.danger,
            message: 'Booking ini sudah dibatalkan.',
          ),
        ];
    }
  }

  List<Widget> _timeline() {
    final urut = [
      BookingStatus.menungguKonfirmasi,
      BookingStatus.menungguPembayaran,
      BookingStatus.menungguVerifikasi,
      BookingStatus.lunas,
    ];
    final posisi = switch (_status) {
      BookingStatus.selesai ||
      BookingStatus.refundDiproses ||
      BookingStatus.refundSelesai => 4,
      _ => urut.indexOf(_status).clamp(0, 4),
    };
    final langkah = [
      ('Booking dibuat', 'Menunggu konfirmasi mitra', 'Sab, 14 Nov · 19.02'),
      ('Dikonfirmasi mitra', 'King Kong Resto menerima', 'Sab, 14 Nov · 19.10'),
      (
        'Bukti bayar dikirim',
        'QRIS Rapatin · ${b.kode}',
        'Sab, 14 Nov · 19.48',
      ),
      ('Lunas', 'Diverifikasi admin Rapatin', 'Sab, 14 Nov · 20.15'),
      (
        _final ? 'Booking final' : 'Masa pembatalan',
        _final ? 'Dana diteruskan ke mitra' : 'Berakhir Sen, 16 Nov · 20.15',
        null,
      ),
    ];
    // Langkah 0..posisi sudah terjadi; langkah berikutnya sedang ditunggu.
    bool done(int i) => i < 4 ? i <= posisi : (_final || posisi == 4);
    return [
      for (var i = 0; i < langkah.length; i++)
        TimelineStep(
          title: langkah[i].$1,
          subtitle: langkah[i].$2,
          time: done(i) && i < 4 ? langkah[i].$3 : null,
          done: done(i),
          current: !done(i) && i == posisi + 1,
          last: i == langkah.length - 1,
        ),
    ];
  }

  List<Widget> _demoActions() {
    Widget btn(String label, VoidCallback f) => OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 40),
        textStyle: AppText.label,
      ),
      onPressed: f,
      child: Text(label),
    );
    return switch (_status) {
      BookingStatus.menungguKonfirmasi => [
        btn(
          'Mitra menerima',
          () => setState(() => _status = BookingStatus.menungguPembayaran),
        ),
        btn(
          'Mitra menolak',
          () => setState(() => _status = BookingStatus.ditolak),
        ),
      ],
      BookingStatus.menungguPembayaran => [
        btn(
          'Lewat 24 jam',
          () => setState(() => _status = BookingStatus.kedaluwarsa),
        ),
      ],
      BookingStatus.menungguVerifikasi => [
        btn(
          'Admin verifikasi',
          () => setState(() => _status = BookingStatus.lunas),
        ),
        btn(
          'Bukti ditolak',
          () => Navigator.pushNamed(context, Routes.buktiDitolak, arguments: b),
        ),
      ],
      BookingStatus.lunas => [
        btn(
          _final ? 'Masih masa batal' : 'Masa batal lewat',
          () => setState(() => _final = !_final),
        ),
        btn(
          'Acara selesai',
          () => setState(() => _status = BookingStatus.selesai),
        ),
      ],
      BookingStatus.refundDiproses => [
        btn(
          'Refund selesai',
          () => setState(() => _status = BookingStatus.refundSelesai),
        ),
      ],
      _ => [
        btn(
          'Ulang dari awal',
          () => setState(() => _status = BookingStatus.menungguKonfirmasi),
        ),
      ],
    };
  }
}

/// Panel kecil untuk presentasi: mensimulasikan kejadian dari mitra/admin.
class _DemoPanel extends StatelessWidget {
  const _DemoPanel({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Gap.x12),
      decoration: BoxDecoration(
        borderRadius: Radii.mdAll,
        border: Border.all(color: AppColors.border),
        color: AppColors.surfaceMuted,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SIMULASI DEMO', style: AppText.monoLabel),
          const SizedBox(height: Gap.x8),
          Wrap(spacing: Gap.x8, runSpacing: Gap.x8, children: children),
        ],
      ),
    );
  }
}

/// 17 · Notifikasi Penyewa.
class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(title: 'Notifikasi'),
      body: NotifList(
        items: notifPenyewa,
        onTap: (i) => Navigator.pushNamed(
          context,
          i == 4 ? Routes.rating : Routes.detailBooking,
          arguments: i == 4 ? riwayatPenyewa.first : bookingUtama,
        ),
      ),
    );
  }
}

/// Daftar notifikasi (dipakai Penyewa dan Mitra).
class NotifList extends StatelessWidget {
  const NotifList({super.key, required this.items, this.onTap});
  final List<Notif> items;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(Gap.x16, 0, Gap.x16, Gap.x24),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: Gap.x8),
      itemBuilder: (context, i) {
        final n = items[i];
        final tone = n.tone ?? AppColors.primary;
        return AppCard(
          onTap: onTap == null ? null : () => onTap!(i),
          color: n.baru ? AppColors.card : AppColors.bg,
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBox(
                n.icon,
                size: 40,
                fg: tone,
                bg: tone.withValues(alpha: 0.12),
              ),
              const SizedBox(width: Gap.x12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(n.judul, style: AppText.bodyMedium.semi),
                        ),
                        Text(n.waktu, style: AppText.caption),
                        if (n.baru) ...[
                          const SizedBox(width: 6),
                          const CircleAvatar(
                            radius: 4,
                            backgroundColor: AppColors.danger,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(n.isi, style: AppText.caption.copyWith(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 18 · Rating setelah acara.
class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key, required this.booking});
  final Booking booking;

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _bintang = 0;
  final _tag = <String>{};
  static const _label = [
    '',
    'Kurang',
    'Cukup',
    'Baik',
    'Bagus',
    'Sangat bagus',
  ];

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    return Scaffold(
      appBar: const TopBar(title: 'Beri rating'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.x16, 0, Gap.x16, Gap.x24),
        children: [
          AppCard(
            child: Row(
              children: [
                Photo(b.venue.foto, width: 56, height: 56, radius: 12),
                const SizedBox(width: Gap.x12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.venue.nama, style: AppText.h3),
                      Text(
                        b.acara,
                        style: AppText.caption.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.x24),
          Text(
            'Bagaimana tempatnya untuk rapat?',
            style: AppText.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Gap.x12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  tooltip: '$i bintang',
                  iconSize: 36,
                  onPressed: () => setState(() => _bintang = i),
                  icon: Icon(
                    LucideIcons.star,
                    color: i <= _bintang ? AppColors.accent : AppColors.neutral,
                    fill: i <= _bintang ? 1 : 0,
                  ),
                ),
            ],
          ),
          Text(
            _label[_bintang],
            textAlign: TextAlign.center,
            style: AppText.bodyMedium.tint(AppColors.primary),
          ),
          const SizedBox(height: Gap.x20),
          Text('Yang paling terasa', style: AppText.h3),
          const SizedBox(height: Gap.x8),
          Wrap(
            spacing: Gap.x8,
            runSpacing: Gap.x8,
            children: [
              for (final t in const [
                'Ruang nyaman',
                'Proyektor siap',
                'Makanan enak',
                'Pelayanan ramah',
                'Tepat waktu',
                'Wi-Fi kencang',
              ])
                PillChip(
                  label: t,
                  selected: _tag.contains(t),
                  onTap: () => setState(
                    () => _tag.contains(t) ? _tag.remove(t) : _tag.add(t),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Gap.x20),
          const LabeledField(
            label: 'Ulasan (opsional)',
            hint: 'Ceritakan pengalaman panitiamu',
            maxLines: 4,
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: FilledButton(
          onPressed: _bintang == 0
              ? null
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Terima kasih! Ulasanmu membantu panitia lain.',
                      ),
                    ),
                  );
                  Navigator.pop(context);
                },
          child: const Text('Kirim rating'),
        ),
      ),
    );
  }
}
