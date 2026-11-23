import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app.dart';
import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/dummy_data.dart';
import '../../data/filter_pencarian.dart';
import '../../data/models.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/nav_bar.dart';

/// Kerangka peran Penyewa: Beranda, Cari, Booking, Akun.
class PenyewaShell extends StatefulWidget {
  const PenyewaShell({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<PenyewaShell> createState() => _PenyewaShellState();
}

class _PenyewaShellState extends State<PenyewaShell> {
  late int _tab = widget.initialTab;

  /// Kriteria pencarian yang dipakai bersama oleh Beranda dan Cari.
  final _filter = ValueNotifier<FilterPencarian>(FilterPencarian.awal);

  void _go(int i) => setState(() => _tab = i);

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _tab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _tab != 0) {
          _go(0);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _tab,
          children: [
            BerandaTab(
              filter: _filter,
              onCari: () => _go(1),
              onBooking: () => _go(2),
            ),
            CariTab(filter: _filter, onBack: () => _go(0)),
            BookingSayaTab(onBack: () => _go(0)),
            AkunPenyewaTab(onBack: () => _go(0)),
          ],
        ),
        bottomNavigationBar: AppNavBar(
          index: _tab,
          onChanged: _go,
          items: const [
            NavItem(LucideIcons.house, 'Beranda'),
            NavItem(LucideIcons.search, 'Cari'),
            NavItem(LucideIcons.ticket, 'Booking'),
            NavItem(LucideIcons.user, 'Akun'),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── 07 · Beranda ─────────────────────────

class BerandaTab extends StatelessWidget {
  const BerandaTab({
    super.key,
    required this.filter,
    required this.onCari,
    required this.onBooking,
  });
  final ValueNotifier<FilterPencarian> filter;
  final VoidCallback onCari;
  final VoidCallback onBooking;

  @override
  Widget build(BuildContext context) {
    final b = bookingUtama;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: Gap.x24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.x16, Gap.x16, Gap.x8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, Alden',
                        style: AppText.caption.copyWith(fontSize: 13),
                      ),
                      ValueListenableBuilder<Organisasi>(
                        valueListenable: organisasiAktif,
                        builder: (context, org, _) => InkWell(
                          borderRadius: Radii.smAll,
                          onTap: () => showPilihOrganisasiSheet(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  org.nama,
                                  style: AppText.h2,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(LucideIcons.chevronDown, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CircleIconButton(
                  icon: LucideIcons.bell,
                  tooltip: 'Notifikasi',
                  badge: true,
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.notifikasi),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.x16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.x16),
            child: AppCard(
              color: AppColors.primary,
              borderColor: AppColors.primary,
              onTap: () => Navigator.pushNamed(
                context,
                Routes.detailBooking,
                arguments: b,
              ),
              child: Row(
                children: [
                  const IconBox(
                    LucideIcons.ticket,
                    bg: AppColors.accent,
                    fg: AppColors.text,
                  ),
                  const SizedBox(width: Gap.x12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${b.venue.nama} · ${b.room.nama}',
                          style: AppText.h3.tint(Colors.white),
                        ),
                        Text(
                          'Berikutnya · ${tanggalPendek(b.tanggal)} · ${jam(b.jamMulai)}',
                          style: AppText.caption
                              .tint(AppColors.primarySoft)
                              .copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: Gap.x16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.x16),
            child: _QuickSearchCard(filter: filter, onCari: onCari),
          ),
          const SizedBox(height: Gap.x24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.x16),
            child: SectionHeader(
              title: 'Promo jam sepi',
              action: 'Lihat semua',
              onAction: onCari,
            ),
          ),
          const SizedBox(height: Gap.x8),
          SizedBox(
            height: 272,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(Gap.x16, 0, Gap.x16, Gap.x8),
              itemCount: semuaVenue.where((v) => v.promo != null).length,
              separatorBuilder: (_, _) => const SizedBox(width: Gap.x12),
              itemBuilder: (context, i) {
                final v = semuaVenue.where((v) => v.promo != null).elementAt(i);
                return VenueCard(
                  venue: v,
                  width: 260,
                  photoHeight: 136,
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.detailTempat,
                    arguments: v,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: Gap.x20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: Gap.x16),
            child: SectionHeader(title: 'Cocok untuk 25 orang'),
          ),
          const SizedBox(height: Gap.x8),
          for (final v in [kingKong, warungSinar])
            Padding(
              padding: const EdgeInsets.fromLTRB(Gap.x16, 0, Gap.x16, Gap.x12),
              child: VenueCard(
                venue: v,
                onTap: () => Navigator.pushNamed(
                  context,
                  Routes.detailTempat,
                  arguments: v,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Field ringkas (ikon + label + nilai) yang bisa diketuk.
class _FieldTile extends StatelessWidget {
  const _FieldTile({
    required this.icon,
    required this.value,
    required this.onTap,
    this.label,
  });
  final IconData icon;
  final String? label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: Radii.mdAll,
      child: InkWell(
        borderRadius: Radii.mdAll,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: label == null ? 14 : 10,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (label != null)
                      Text(
                        label!,
                        style: AppText.caption.copyWith(fontSize: 13),
                      ),
                    Text(
                      value,
                      style: AppText.bodyMedium.semi.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<DateTime?> _pilihTanggal(BuildContext context, DateTime awal) {
  final hariIni = DateUtils.dateOnly(DateTime.now());
  final mulai = awal.isBefore(hariIni) ? awal : hariIni;
  return showDatePicker(
    context: context,
    initialDate: awal,
    firstDate: mulai,
    lastDate: DateTime(mulai.year + 1, 12, 31),
    helpText: 'Tanggal rapat',
    cancelText: 'Batal',
    confirmText: 'Pilih',
  );
}

String _labelJam(WaktuRapat? w) => w == null ? 'Semua jam' : w.rentang;

class _QuickSearchCard extends StatelessWidget {
  const _QuickSearchCard({required this.filter, required this.onCari});
  final ValueNotifier<FilterPencarian> filter;
  final VoidCallback onCari;

  /// Pencarian terakhir: (label chip, kriteria).
  static final _terakhir = <(String, FilterPencarian)>[
    (
      '25 orang · Sab 19.00',
      FilterPencarian(
        orang: 25,
        tanggal: DateTime(2026, 11, 21),
        waktu: WaktuRapat.malam,
      ),
    ),
    (
      '12 orang · Min 15.00',
      FilterPencarian(
        orang: 12,
        tanggal: DateTime(2026, 11, 22),
        waktu: WaktuRapat.sore,
      ),
    ),
    (
      '40 orang · Jum 13.00',
      FilterPencarian(
        orang: 40,
        tanggal: DateTime(2026, 11, 27),
        waktu: WaktuRapat.siang,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FilterPencarian>(
      valueListenable: filter,
      builder: (context, f, _) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Cari tempat rapat', style: AppText.h2),
            const SizedBox(height: Gap.x12),
            _FieldTile(
              icon: LucideIcons.users,
              label: 'Jumlah orang',
              value: '${f.orang} orang',
              onTap: () => _showFilterSheet(context, filter),
            ),
            const SizedBox(height: Gap.x8),
            Row(
              children: [
                Expanded(
                  child: _FieldTile(
                    icon: LucideIcons.calendar,
                    label: 'Tanggal',
                    value: tanggalPendek(f.tanggal),
                    onTap: () async {
                      final d = await _pilihTanggal(context, f.tanggal);
                      if (d != null) {
                        filter.value = filter.value.copyWith(tanggal: d);
                      }
                    },
                  ),
                ),
                const SizedBox(width: Gap.x8),
                Expanded(
                  child: _FieldTile(
                    icon: LucideIcons.clock,
                    label: 'Jam',
                    value: _labelJam(f.waktu),
                    onTap: () => _showFilterSheet(context, filter),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gap.x12),
            FilledButton(onPressed: onCari, child: const Text('Cari tempat')),
            const SizedBox(height: Gap.x12),
            Text(
              'Pencarian terakhir',
              style: AppText.caption.copyWith(fontSize: 13),
            ),
            const SizedBox(height: Gap.x8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: Gap.x8),
              child: Row(
                children: [
                  for (final (label, kriteria) in _terakhir)
                    Padding(
                      padding: const EdgeInsets.only(right: Gap.x8),
                      child: ActionChip(
                        onPressed: () {
                          filter.value = kriteria;
                          onCari();
                        },
                        avatar: const Icon(
                          LucideIcons.repeat,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        label: Text(label, style: AppText.label),
                        backgroundColor: AppColors.surfaceMuted,
                        side: BorderSide.none,
                        shape: const StadiumBorder(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── 08 · Cari & hasil ─────────────────────────

class CariTab extends StatefulWidget {
  const CariTab({super.key, required this.filter, this.onBack});
  final ValueNotifier<FilterPencarian> filter;
  final VoidCallback? onBack;

  @override
  State<CariTab> createState() => _CariTabState();
}

class _CariTabState extends State<CariTab> {
  final _q = TextEditingController();
  String _chip = 'Semua';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  List<Venue> _hasil(FilterPencarian f) {
    final q = _q.text.trim().toLowerCase();
    return f.saring(semuaVenue).where((v) {
      final cocokTeks =
          q.isEmpty ||
          v.nama.toLowerCase().contains(q) ||
          v.area.toLowerCase().contains(q);
      final cocokChip = switch (_chip) {
        'Promo' => v.promo != null,
        'Proyektor' => v.fasilitas.contains(Fasilitas.proyektor),
        'Ruang privat' => v.fasilitas.contains(Fasilitas.privat),
        _ => true,
      };
      return cocokTeks && cocokChip;
    }).toList();
  }

  void _hapusSemua() {
    setState(() {
      _q.clear();
      _chip = 'Semua';
    });
    widget.filter.value = FilterPencarian.awal;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FilterPencarian>(
      valueListenable: widget.filter,
      builder: (context, f, _) => _build(context, f),
    );
  }

  Widget _build(BuildContext context, FilterPencarian f) {
    final hasil = _hasil(f);
    final tambahan = f.jumlahTambahan;
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.x16, Gap.x16, Gap.x16, 0),
            child: Row(
              children: [
                if (widget.onBack != null) ...[
                  CircleIconButton(
                    icon: LucideIcons.chevronLeft,
                    tooltip: 'Kembali ke Beranda',
                    onPressed: widget.onBack,
                  ),
                  const SizedBox(width: Gap.x8),
                ],
                Expanded(
                  child: TextField(
                    controller: _q,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari kafe, resto, atau area',
                      prefixIcon: const Icon(LucideIcons.search, size: 20),
                      fillColor: AppColors.surfaceMuted,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: Radii.mdAll,
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _q.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Hapus',
                              icon: const Icon(LucideIcons.x, size: 18),
                              onPressed: () => setState(_q.clear),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: Gap.x8),
                Badge(
                  isLabelVisible: tambahan > 0,
                  label: Text('$tambahan'),
                  backgroundColor: AppColors.accent,
                  textColor: AppColors.text,
                  child: IconButton.filled(
                    tooltip: tambahan > 0
                        ? 'Filter · $tambahan aktif'
                        : 'Filter',
                    onPressed: () => _showFilterSheet(context, widget.filter),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(52, 52),
                      shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
                    ),
                    icon: const Icon(LucideIcons.slidersHorizontal, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.x12),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(Gap.x16, 0, Gap.x16, Gap.x8),
              children: [
                for (final c in const [
                  'Semua',
                  'Promo',
                  'Proyektor',
                  'Ruang privat',
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: Gap.x8),
                    child: PillChip(
                      label: c,
                      selected: _chip == c,
                      onTap: () => setState(() => _chip = c),
                    ),
                  ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showFilterSheet(context, widget.filter),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Gap.x16,
                Gap.x12,
                Gap.x16,
                Gap.x8,
              ),
              child: Text(
                '${hasil.length} tempat · ${f.orang} orang · ${tanggalPendek(f.tanggal)} · ${_labelJam(f.waktu)}',
                style: AppText.caption.copyWith(fontSize: 13),
              ),
            ),
          ),
          Expanded(
            child: hasil.isEmpty
                ? SingleChildScrollView(
                    child: EmptyState(
                      icon: LucideIcons.searchX,
                      title: 'Belum ada tempat yang cocok',
                      message: 'Coba kurangi jumlah orang, geser jamnya, atau hapus beberapa filter.',
                      action: 'Hapus semua filter',
                      onAction: _hapusSemua,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      Gap.x16,
                      0,
                      Gap.x16,
                      Gap.x24,
                    ),
                    itemCount: hasil.length,
                    separatorBuilder: (_, _) => const SizedBox(height: Gap.x12),
                    itemBuilder: (context, i) => VenueCard(
                      venue: hasil[i],
                      onTap: () => Navigator.pushNamed(
                        context,
                        Routes.detailTempat,
                        arguments: hasil[i],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── 09 · Filter sheet ─────────────────────────

/// Buka sheet Filter. Kriteria baru disimpan ke [filter] saat diterapkan.
Future<void> _showFilterSheet(
  BuildContext context,
  ValueNotifier<FilterPencarian> filter,
) async {
  final hasil = await showModalBottomSheet<FilterPencarian>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _FilterSheet(awal: filter.value),
  );
  if (hasil != null) filter.value = hasil;
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.awal});
  final FilterPencarian awal;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late FilterPencarian _f = widget.awal;

  void _ubah(FilterPencarian f) => setState(() => _f = f);

  @override
  Widget build(BuildContext context) {
    final jumlah = _f.saring(semuaVenue).length;
    final w = _f.waktu;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.x20, 0, Gap.x20, Gap.x12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter', style: AppText.h1),
                CircleIconButton(
                  icon: LucideIcons.x,
                  size: 38,
                  tooltip: 'Tutup',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                Gap.x20,
                Gap.x16,
                Gap.x20,
                Gap.x20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Jumlah orang', style: AppText.h3)),
                      QtyStepper(
                        value: _f.orang,
                        suffix: '',
                        onChanged: (v) => _ubah(_f.copyWith(orang: v)),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.x20),
                  Text('Tanggal', style: AppText.h3),
                  const SizedBox(height: Gap.x8),
                  _FieldTile(
                    icon: LucideIcons.calendar,
                    value: tanggalPendek(_f.tanggal),
                    onTap: () async {
                      final d = await _pilihTanggal(context, _f.tanggal);
                      if (d != null && mounted) _ubah(_f.copyWith(tanggal: d));
                    },
                  ),
                  const SizedBox(height: Gap.x20),
                  Text('Jam', style: AppText.h3),
                  const SizedBox(height: Gap.x8),
                  Wrap(
                    spacing: Gap.x8,
                    runSpacing: Gap.x8,
                    children: [
                      PillChip(
                        label: 'Semua jam',
                        selected: w == null,
                        onTap: () => _ubah(_f.copyWith(hapusWaktu: true)),
                      ),
                      for (final j in WaktuRapat.values)
                        PillChip(
                          label: j.label,
                          selected: w == j,
                          onTap: () => _ubah(_f.copyWith(waktu: j)),
                        ),
                    ],
                  ),
                  const SizedBox(height: Gap.x8),
                  Text(
                    w == null
                        ? 'Tampilkan tempat yang buka di jam berapa pun.'
                        : '${w.rentang} · tempat harus buka minimal ${FilterPencarian.minimalJam} jam di rentang ini.',
                    style: AppText.caption,
                  ),
                  const SizedBox(height: Gap.x20),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Min. order per orang', style: AppText.h3),
                      ),
                      Text(
                        '${rupiahShort(_f.minOrderMin)}–${rupiahShort(_f.minOrderMaks)}',
                        style: AppText.bodyMedium.semi.tint(AppColors.primary),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: RangeValues(
                      _f.minOrderMin.toDouble(),
                      _f.minOrderMaks.toDouble(),
                    ),
                    min: FilterPencarian.batasBawahOrder.toDouble(),
                    max: FilterPencarian.batasAtasOrder.toDouble(),
                    divisions: 10,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primarySoft,
                    onChanged: (v) => _ubah(
                      _f.copyWith(
                        minOrderMin: v.start.round(),
                        minOrderMaks: v.end.round(),
                      ),
                    ),
                  ),
                  const SizedBox(height: Gap.x12),
                  Text('Fasilitas', style: AppText.h3),
                  const SizedBox(height: Gap.x8),
                  Wrap(
                    spacing: Gap.x8,
                    runSpacing: Gap.x8,
                    children: [
                      for (final fas in Fasilitas.values)
                        PillChip(
                          label: fas.label,
                          icon: FacilityChip.iconOf(fas),
                          selected: _f.fasilitas.contains(fas),
                          onTap: () => _ubah(
                            _f.copyWith(
                              fasilitas: _f.fasilitas.contains(fas)
                                  ? (_f.fasilitas.toSet()..remove(fas))
                                  : {..._f.fasilitas, fas},
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.bg,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Gap.x20,
                  Gap.x12,
                  Gap.x20,
                  Gap.x16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _ubah(FilterPencarian.awal),
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: Gap.x12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: jumlah == 0
                            ? null
                            : () => Navigator.pop(context, _f),
                        child: Text(
                          jumlah == 0
                              ? 'Tidak ada yang cocok'
                              : 'Tampilkan $jumlah tempat',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── 19 · Booking saya ─────────────────────────

class BookingSayaTab extends StatefulWidget {
  const BookingSayaTab({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  State<BookingSayaTab> createState() => _BookingSayaTabState();
}

class _BookingSayaTabState extends State<BookingSayaTab> {
  int _seg = 0;

  @override
  Widget build(BuildContext context) {
    final list = _seg == 0 ? bookingPenyewa : riwayatPenyewa;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.x16, Gap.x16, Gap.x16, Gap.x24),
        children: [
          Row(
            children: [
              if (widget.onBack != null) ...[
                CircleIconButton(
                  icon: LucideIcons.chevronLeft,
                  tooltip: 'Kembali ke Beranda',
                  onPressed: widget.onBack,
                ),
                const SizedBox(width: Gap.x8),
              ],
              Text('Booking saya', style: AppText.h1),
            ],
          ),
          const SizedBox(height: Gap.x16),
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 0, label: Text('Aktif')),
              ButtonSegment(value: 1, label: Text('Riwayat')),
            ],
            selected: {_seg},
            onSelectionChanged: (s) => setState(() => _seg = s.first),
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primary,
              selectedForegroundColor: Colors.white,
              backgroundColor: AppColors.card,
              side: const BorderSide(color: AppColors.border),
              textStyle: AppText.bodyMedium,
              minimumSize: const Size.fromHeight(44),
            ),
          ),
          const SizedBox(height: Gap.x16),
          if (list.isEmpty)
            EmptyState(
              icon: LucideIcons.ticket,
              title: 'Belum ada booking',
              message: 'Cari tempat rapat untuk panitiamu, slipnya akan muncul di sini.',
              action: 'Cari tempat',
              onAction: () {},
            ),
          for (final b in list) ...[
            BookingCard(
              booking: b,
              onTap: () => Navigator.pushNamed(
                context,
                Routes.detailBooking,
                arguments: b,
              ),
              action: _seg == 1
                  ? Row(
                      children: [
                        if (b.status == BookingStatus.selesai) ...[
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(44),
                              ),
                              onPressed: () => Navigator.pushNamed(
                                context,
                                Routes.rating,
                                arguments: b,
                              ),
                              icon: const Icon(LucideIcons.star, size: 18),
                              label: const Text('Beri rating'),
                            ),
                          ),
                          const SizedBox(width: Gap.x8),
                        ],
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(44),
                            ),
                            onPressed: () => Navigator.pushNamed(
                              context,
                              Routes.pilihSlot,
                              arguments: b.venue,
                            ),
                            icon: const Icon(LucideIcons.repeat, size: 18),
                            label: const Text('Booking lagi'),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            const SizedBox(height: Gap.x12),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────── 20 · Akun ─────────────────────────

class AkunPenyewaTab extends StatelessWidget {
  const AkunPenyewaTab({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.x16, Gap.x16, Gap.x16, Gap.x24),
        children: [
          Row(
            children: [
              if (onBack != null) ...[
                CircleIconButton(
                  icon: LucideIcons.chevronLeft,
                  tooltip: 'Kembali ke Beranda',
                  onPressed: onBack,
                ),
                const SizedBox(width: Gap.x8),
              ],
              Text('Akun', style: AppText.h1),
            ],
          ),
          const SizedBox(height: Gap.x16),
          AppCard(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(
                    'AL',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: Gap.x16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alden Pratama', style: AppText.h3),
                      Text(
                        'alden@student.its.ac.id',
                        style: AppText.caption.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Penyewa · ITS',
                        style: AppText.label.tint(AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.x16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                MenuTile(
                  icon: LucideIcons.pencil,
                  title: 'Edit profil',
                  onTap: () => showSoon(context, 'Edit profil'),
                ),
                ValueListenableBuilder<Organisasi>(
                  valueListenable: organisasiAktif,
                  builder: (context, org, _) => MenuTile(
                    icon: LucideIcons.building2,
                    title: 'Organisasi',
                    subtitle: org.ringkasan,
                    onTap: () => showPilihOrganisasiSheet(context),
                  ),
                ),
                MenuTile(
                  icon: LucideIcons.bell,
                  title: 'Notifikasi',
                  onTap: () => Navigator.pushNamed(context, Routes.notifikasi),
                ),
                MenuTile(
                  icon: LucideIcons.fileText,
                  title: 'Kebijakan pembatalan & refund',
                  onTap: () => _kebijakan(context),
                ),
                MenuTile(
                  icon: LucideIcons.messageCircle,
                  title: 'Bantuan',
                  subtitle: 'Chat admin Rapatin',
                  onTap: () => showSoon(context, 'Bantuan'),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.x16),
          AppCard(
            padding: EdgeInsets.zero,
            child: MenuTile(
              icon: LucideIcons.logOut,
              title: 'Keluar',
              danger: true,
              onTap: () => konfirmasiKeluar(context),
            ),
          ),
        ],
      ),
    );
  }

  void _kebijakan(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(Gap.x20, 0, Gap.x20, Gap.x32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pembatalan & refund', style: AppText.h2),
                CircleIconButton(
                  icon: LucideIcons.x,
                  size: 38,
                  tooltip: 'Tutup',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: Gap.x12),
            for (final t in const [
              'Pembayaran penuh lewat QRIS Rapatin, lalu diverifikasi admin.',
              'Masa pembatalan 2×24 jam sejak lunas, paling lambat 24 jam sebelum acara.',
              'Batal dalam masa itu: dana kembali penuh, kecuali biaya layanan Rp3.000.',
              'Lewat masa itu, booking menjadi final dan dana diteruskan ke mitra.',
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: Gap.x8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Icon(
                        LucideIcons.check,
                        size: 16,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: Gap.x8),
                    Expanded(child: Text(t, style: AppText.body)),
                  ],
                ),
              ),
            const SizedBox(height: Gap.x16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> konfirmasiKeluar(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: AppColors.card,
      title: Text('Keluar dari Rapatin?', style: AppText.h2),
      content: Text(
        'Kamu perlu masuk lagi untuk melihat booking.',
        style: AppText.body.muted,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(c, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          child: const Text('Keluar'),
        ),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    Navigator.pushNamedAndRemoveUntil(context, Routes.peran, (_) => false);
  }
}

// ───────────────────────── Pilih Organisasi Sheet ─────────────────────────

Future<void> showPilihOrganisasiSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _PilihOrganisasiSheet(),
  );
}

class _PilihOrganisasiSheet extends StatelessWidget {
  const _PilihOrganisasiSheet();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Organisasi>>(
      valueListenable: daftarOrganisasiPenyewa,
      builder: (context, list, _) {
        return ValueListenableBuilder<Organisasi>(
          valueListenable: organisasiAktif,
          builder: (context, aktif, _) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Gap.x20, 0, Gap.x20, Gap.x20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pilih organisasi', style: AppText.h2),
                        CircleIconButton(
                          icon: LucideIcons.x,
                          size: 38,
                          tooltip: 'Tutup',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: Gap.x4),
                    Text(
                      'Reservasi tempat dan slip pemesanan akan diatasnamakan organisasi yang kamu pilih.',
                      style: AppText.caption,
                    ),
                    const SizedBox(height: Gap.x16),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: list.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: Gap.x8),
                        itemBuilder: (context, index) {
                          final org = list[index];
                          final isSelected = org == aktif;
                          return InkWell(
                            borderRadius: Radii.mdAll,
                            onTap: () {
                              pilihOrganisasi(org);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Organisasi aktif diubah ke ${org.nama}',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.all(Gap.x12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primarySoft
                                    : AppColors.card,
                                borderRadius: Radii.mdAll,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  IconBox(
                                    LucideIcons.building2,
                                    size: 40,
                                    fg: isSelected
                                        ? AppColors.primary
                                        : AppColors.textMuted,
                                    bg: isSelected
                                        ? AppColors.card
                                        : AppColors.bg,
                                  ),
                                  const SizedBox(width: Gap.x12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          org.nama,
                                          style: AppText.bodyMedium.semi.copyWith(
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.text,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${org.jenis} · ${org.jabatan}',
                                          style: AppText.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: Gap.x8),
                                  Icon(
                                    isSelected
                                        ? LucideIcons.circleCheck
                                        : LucideIcons.circle,
                                    size: 22,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: Gap.x16),
                    OutlinedButton.icon(
                      icon: const Icon(LucideIcons.plus, size: 18),
                      label: const Text('Tambah organisasi baru'),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          Routes.profilOrganisasi,
                          arguments: true,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
