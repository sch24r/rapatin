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
import '../penyewa/status_screens.dart';
import 'mitra_shell.dart';

/// Terima booking + snackbar Urungkan (M04b).
void terimaBooking(BuildContext context, Booking b) {
  final semula = b.status;
  ubahStatusMitra(b.kode, BookingStatus.menungguPembayaran);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('${b.organisasi} diterima. Menunggu pembayaran.'),
        action: SnackBarAction(
          label: 'Urungkan',
          onPressed: () => ubahStatusMitra(b.kode, semula),
        ),
      ),
    );
}

/// M06 · Sheet alasan tolak, lalu snackbar Urungkan.
Future<bool> tolakBooking(BuildContext context, Booking b) async {
  final alasan = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _TolakSheet(),
  );
  if (alasan == null || !context.mounted) return false;
  final semula = b.status;
  ubahStatusMitra(b.kode, BookingStatus.ditolak);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('Booking ${b.kode} ditolak · $alasan'),
        action: SnackBarAction(
          label: 'Urungkan',
          onPressed: () => ubahStatusMitra(b.kode, semula),
        ),
      ),
    );
  return true;
}

class _TolakSheet extends StatefulWidget {
  const _TolakSheet();

  @override
  State<_TolakSheet> createState() => _TolakSheetState();
}

class _TolakSheetState extends State<_TolakSheet> {
  static const _opsi = [
    'Slot sudah terpakai tamu langsung',
    'Ruang sedang perbaikan',
    'Jumlah orang melebihi kapasitas',
    'Alasan lain',
  ];
  String? _pilih;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Gap.x20,
        0,
        Gap.x20,
        Gap.x20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tolak booking?', style: AppText.h2),
          const SizedBox(height: 4),
          Text(
            'Alasan dikirim ke panitia agar mereka bisa cari jam atau tempat lain.',
            style: AppText.body.muted,
          ),
          const SizedBox(height: Gap.x12),
          RadioGroup<String>(
            groupValue: _pilih,
            onChanged: (v) => setState(() => _pilih = v),
            child: Column(
              children: [
                for (final o in _opsi)
                  RadioListTile<String>(
                    value: o,
                    contentPadding: EdgeInsets.zero,
                    title: Text(o, style: AppText.body),
                  ),
              ],
            ),
          ),
          if (_pilih == 'Alasan lain') ...[
            const LabeledField(
              label: 'Tulis alasan',
              hint: 'Contoh: ada acara internal',
              maxLines: 2,
            ),
            const SizedBox(height: Gap.x12),
          ],
          const SizedBox(height: Gap.x8),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: _pilih == null
                ? null
                : () => Navigator.pop(context, _pilih),
            child: const Text('Tolak booking'),
          ),
        ],
      ),
    );
  }
}

/// M04 · Booking masuk (tab).
class BookingMasukTab extends StatefulWidget {
  const BookingMasukTab({super.key});

  @override
  State<BookingMasukTab> createState() => _BookingMasukTabState();
}

class _BookingMasukTabState extends State<BookingMasukTab> {
  int _filter = 0;
  static const _filters = <(String, Set<BookingStatus>)>[
    ('Perlu konfirmasi', {BookingStatus.menungguKonfirmasi}),
    (
      'Menunggu bayar',
      {BookingStatus.menungguPembayaran, BookingStatus.menungguVerifikasi},
    ),
    ('Lunas', {BookingStatus.lunas}),
    (
      'Selesai',
      {BookingStatus.selesai, BookingStatus.ditolak, BookingStatus.dibatalkan},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder(
        valueListenable: mitraBookings,
        builder: (context, all, _) {
          final list = all
              .where((b) => _filters[_filter].$2.contains(b.status))
              .toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(0, Gap.x16, 0, Gap.x24),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Gap.x16),
                child: Text('Booking masuk', style: AppText.h1),
              ),
              const SizedBox(height: Gap.x16),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Gap.x16),
                  children: [
                    for (var i = 0; i < _filters.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: Gap.x8),
                        child: PillChip(
                          label:
                              '${_filters[i].$1} · ${all.where((b) => _filters[i].$2.contains(b.status)).length}',
                          selected: _filter == i,
                          onTap: () => setState(() => _filter = i),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: Gap.x16),
              if (list.isEmpty)
                const EmptyState(
                  icon: LucideIcons.inbox,
                  title: 'Tidak ada booking di sini',
                  message: 'Booking baru dari panitia akan muncul dan kamu dapat notifikasi.',
                ),
              for (final b in list)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Gap.x16,
                    0,
                    Gap.x16,
                    Gap.x12,
                  ),
                  child: BookingMasukCard(
                    booking: b,
                    onTap: () => Navigator.pushNamed(
                      context,
                      Routes.mitraDetailBooking,
                      arguments: b,
                    ),
                    onTolak: b.status == BookingStatus.menungguKonfirmasi
                        ? () => tolakBooking(context, b)
                        : null,
                    onTerima: b.status == BookingStatus.menungguKonfirmasi
                        ? () => terimaBooking(context, b)
                        : null,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// M05 & M07 · Detail booking untuk mitra (konfirmasi atau lunas).
class MitraDetailBookingScreen extends StatelessWidget {
  const MitraDetailBookingScreen({super.key, required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: mitraBookings,
      builder: (context, all, _) {
        final b = all.firstWhere(
          (x) => x.kode == booking.kode,
          orElse: () => booking,
        );
        final perlu = b.status == BookingStatus.menungguKonfirmasi;
        final lunas = b.status == BookingStatus.lunas;
        return Scaffold(
          appBar: const TopBar(title: 'Detail booking'),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.x16, 0, Gap.x16, Gap.x24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Kode ${b.kode}', style: AppText.body.muted),
                  ),
                  StatusBadge(b.status),
                ],
              ),
              const SizedBox(height: Gap.x16),
              if (perlu) ...[
                const InfoBanner(
                  tone: BannerTone.warning,
                  title: 'Balas dalam 15 menit',
                  message:
                      'Kalau tidak dibalas, panitia bisa mencari tempat lain.',
                ),
                const SizedBox(height: Gap.x16),
              ],
              if (lunas) ...[
                SlipReservasi(booking: b, cap: SlipCap.lunas, compact: true),
                const SizedBox(height: Gap.x16),
              ] else
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.organisasi, style: AppText.h2),
                      Text(
                        b.acara,
                        style: AppText.caption.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: Gap.x12),
                      const Divider(),
                      const SizedBox(height: Gap.x8),
                      _Baris(
                        LucideIcons.armchair,
                        'Ruang',
                        '${b.room.nama} · ${b.room.kapasitas}',
                      ),
                      _Baris(LucideIcons.users, 'Jumlah', '${b.orang} orang'),
                      _Baris(
                        LucideIcons.calendar,
                        'Tanggal',
                        tanggalPendek(b.tanggal),
                      ),
                      _Baris(
                        LucideIcons.clock,
                        'Jam',
                        '${jam(b.jamMulai)}–${jam(b.jamSelesai)} (${b.durasi} jam)',
                      ),
                      _Baris(LucideIcons.user, 'PIC', 'Alden · 0812 •••• 4407'),
                    ],
                  ),
                ),
              if (b.catatan != null) ...[
                const SizedBox(height: Gap.x12),
                AppCard(
                  color: AppColors.surfaceMuted,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        LucideIcons.messageCircle,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: Gap.x12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Catatan panitia',
                              style: AppText.label.tint(AppColors.textMuted),
                            ),
                            const SizedBox(height: 2),
                            Text(b.catatan!, style: AppText.body),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: Gap.x16),
              Container(
                padding: const EdgeInsets.all(Gap.x16),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: Radii.lgAll,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'PENERIMAAN MITRA',
                            style: AppText.monoLabel,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Gap.x8),
                    PriceRow(
                      'Sewa ruang · ${b.durasi} jam',
                      b.sewa == 0 ? 'Gratis' : rupiah(b.sewa),
                    ),
                    PriceRow(
                      'Min. order · ${b.orang} orang',
                      rupiah(b.minOrder),
                    ),
                    if (b.diskon > 0)
                      PriceRow(
                        'Diskon jam sepi',
                        '−${rupiah(b.diskon)}',
                        discount: true,
                      ),
                    PriceRow('Pendapatan kotor', rupiah(b.kotor)),
                    PriceRow(
                      'Fee Rapatin (flat)',
                      '−${rupiah(Booking.feeMitra)}',
                      discount: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(color: Color(0xFFE4DCC6)),
                    ),
                    PriceRow('Kamu terima', rupiah(b.bersih), total: true),
                  ],
                ),
              ),
              if (lunas) ...[
                const SizedBox(height: Gap.x16),
                const InfoBanner(
                  tone: BannerTone.success,
                  icon: LucideIcons.wallet,
                  title: 'Dana cair setelah masa pembatalan',
                  message: 'Paling cepat Sen, 16 Nov · 20.15 ke BCA ••4821. Min. order dibayar penuh di aplikasi, jadi panitia tinggal makan.',
                ),
              ],
            ],
          ),
          bottomNavigationBar: perlu
              ? BottomActionBar(
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                          ),
                          onPressed: () async {
                            if (await tolakBooking(context, b) &&
                                context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Tolak'),
                        ),
                      ),
                      const SizedBox(width: Gap.x12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: () {
                            terimaBooking(context, b);
                            Navigator.pop(context);
                          },
                          child: const Text('Terima booking'),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _Baris extends StatelessWidget {
  const _Baris(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: Gap.x12),
          Text(label, style: AppText.body.muted),
          const SizedBox(width: Gap.x12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppText.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// M16 · Notifikasi Mitra.
class MitraNotifikasiScreen extends StatelessWidget {
  const MitraNotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(title: 'Notifikasi'),
      body: NotifList(
        items: notifMitra,
        onTap: (i) {
          if (i == 2) {
            Navigator.pushNamed(context, Routes.mitraPendapatan);
          } else if (i < 2) {
            Navigator.pushNamed(
              context,
              Routes.mitraDetailBooking,
              arguments: bookingMitra[i == 0 ? 1 : 2],
            );
          }
        },
      ),
    );
  }
}

/// M08 · Jadwal per ruang + M09 blokir slot.
class JadwalTab extends StatefulWidget {
  const JadwalTab({super.key});

  @override
  State<JadwalTab> createState() => _JadwalTabState();
}

class _JadwalTabState extends State<JadwalTab> {
  DateTime _hari = DateTime(2026, 11, 21);
  final _blokir = <String>{'21-Privat-12'};

  static const _tamu = 'Tamu';

  // Slot terisi per tanggal dan ruang (jam mulai → label).
  Map<int, String> _isi(String ruang) => switch ((_hari.day, ruang)) {
    (20, 'Privat') => {18: 'UKM Foto', 19: 'UKM Foto'},
    (20, 'Reguler') => {19: _tamu, 20: _tamu},
    (21, 'VIP') => {19: 'BEM FT', 20: 'BEM FT'},
    (21, 'Reguler') => {12: _tamu, 13: _tamu},
    (22, 'Reguler') => {15: 'HIMA IF', 16: 'HIMA IF'},
    (23, 'VIP') => {10: 'Himatika', 11: 'Himatika'},
    (24, 'Privat') => {13: _tamu},
    _ => {},
  };

  @override
  Widget build(BuildContext context) {
    final hari = List.generate(7, (i) => DateTime(2026, 11, 20 + i));
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, Gap.x16, 0, Gap.x24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.x16),
            child: Row(
              children: [
                Expanded(child: Text('Jadwal', style: AppText.h1)),
                FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                  onPressed: () => _blokirSheet(context),
                  icon: const Icon(LucideIcons.ban, size: 18),
                  label: const Text('Blokir slot'),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.x16),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Gap.x16),
              itemCount: hari.length,
              separatorBuilder: (_, _) => const SizedBox(width: Gap.x8),
              itemBuilder: (_, i) {
                final d = hari[i];
                final sel = DateUtils.isSameDay(d, _hari);
                return Material(
                  color: sel ? AppColors.primary : AppColors.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: Radii.mdAll,
                    side: BorderSide(
                      color: sel ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: Radii.mdAll,
                    onTap: () => setState(() => _hari = d),
                    child: SizedBox(
                      width: 56,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            namaHari[d.weekday - 1],
                            style: AppText.caption.tint(
                              sel ? AppColors.primarySoft : AppColors.textMuted,
                            ),
                          ),
                          Text(
                            '${d.day}',
                            style: AppText.h3.tint(
                              sel ? Colors.white : AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: Gap.x16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.x16),
            child: Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                _dot(AppColors.card, AppColors.border, 'Kosong'),
                _dot(
                  AppColors.primarySoft,
                  AppColors.primary,
                  'Booking Rapatin',
                ),
                _dot(
                  AppColors.neutralSoft,
                  AppColors.neutralSoft,
                  'Diblokir/tamu langsung',
                ),
              ],
            ),
          ),
          for (final r in kingKong.rooms) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Gap.x16,
                Gap.x20,
                Gap.x16,
                Gap.x8,
              ),
              child: Text(
                'Ruang ${r.nama} · ${r.kapasitas}',
                style: AppText.h3,
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: Gap.x16),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisExtent: 56,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (_, i) {
                final h = 10 + i;
                final isi = _isi(r.nama)[h];
                final blok = _blokir.contains('${_hari.day}-${r.nama}-$h');
                final rapatin = isi != null && isi != _tamu;
                final bg = rapatin
                    ? AppColors.primarySoft
                    : (isi != null || blok
                          ? AppColors.neutralSoft
                          : AppColors.card);
                final border = rapatin
                    ? AppColors.primary
                    : (isi != null || blok
                          ? AppColors.neutralSoft
                          : AppColors.border);
                final ket = blok ? 'Diblokir' : isi;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(jam(h), style: AppText.label),
                      if (ket != null)
                        Text(
                          ket,
                          style: AppText.caption.copyWith(
                            fontSize: 11,
                            color: rapatin
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _dot(Color bg, Color border, String t) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: border, width: 1.5),
        ),
      ),
      const SizedBox(width: 6),
      Text(t, style: AppText.caption.copyWith(fontSize: 13)),
    ],
  );

  Future<void> _blokirSheet(BuildContext context) async {
    var ruang = 'Reguler';
    var mulai = 14;
    var sampai = 16;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => Padding(
          padding: const EdgeInsets.fromLTRB(Gap.x20, 0, Gap.x20, Gap.x24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Blokir slot', style: AppText.h2),
              const SizedBox(height: 4),
              Text(
                'Untuk tamu langsung atau acara internal. Panitia tidak bisa memilih slot ini.',
                style: AppText.body.muted,
              ),
              const SizedBox(height: Gap.x16),
              Text('Ruang', style: AppText.bodyMedium),
              const SizedBox(height: Gap.x8),
              Wrap(
                spacing: 8,
                children: [
                  for (final r in kingKong.rooms)
                    PillChip(
                      label: r.nama,
                      selected: ruang == r.nama,
                      onTap: () => set(() => ruang = r.nama),
                    ),
                ],
              ),
              const SizedBox(height: Gap.x16),
              Text(
                '${tanggalPendek(_hari)} · ${jam(mulai)}–${jam(sampai)}',
                style: AppText.h3,
              ),
              RangeSlider(
                values: RangeValues(mulai.toDouble(), sampai.toDouble()),
                min: 10,
                max: 22,
                divisions: 12,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primarySoft,
                onChanged: (v) => set(() {
                  mulai = v.start.round();
                  sampai = v.end.round() == mulai ? mulai + 1 : v.end.round();
                }),
              ),
              const SizedBox(height: Gap.x8),
              const LabeledField(
                label: 'Keterangan (opsional)',
                hint: 'Contoh: arisan keluarga',
              ),
              const SizedBox(height: Gap.x20),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Blokir slot'),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true && mounted) {
      setState(() {
        for (var h = mulai; h < sampai; h++) {
          _blokir.add('${_hari.day}-$ruang-$h');
        }
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ruang $ruang ${jam(mulai)}–${jam(sampai)} diblokir'),
          ),
        );
      }
    }
  }
}
