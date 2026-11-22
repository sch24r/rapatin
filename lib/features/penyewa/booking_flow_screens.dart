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

/// 11 · Pilih slot: ruang, tanggal, lalu rentang jam.
class PilihSlotScreen extends StatefulWidget {
  const PilihSlotScreen({super.key, required this.venue});
  final Venue venue;

  @override
  State<PilihSlotScreen> createState() => _PilihSlotScreenState();
}

class _PilihSlotScreenState extends State<PilihSlotScreen> {
  late int _room = widget.venue.rooms.length > 1 ? 1 : 0;
  DateTime _tanggal = tanggalAcara;
  int? _mulai = 19;
  int? _selesai = 21; // eksklusif
  String? _pesan;

  static const _jamBuka = 10;
  static const _jamTutup = 22;
  static const _terisi = {12, 13};
  static const _promo = {14, 15, 16};

  Room get room => widget.venue.rooms[_room];

  void _tapSlot(int h) {
    setState(() {
      _pesan = null;
      if (_mulai == null || _selesai != _mulai! + 1 || h < _mulai!) {
        // Mulai pilihan baru.
        _mulai = h;
        _selesai = h + 1;
        return;
      }
      if (h == _mulai) {
        _mulai = null;
        _selesai = null;
        return;
      }
      // Perluas rentang dari slot pertama ke slot yang diketuk.
      final akhir = h + 1;
      final kena = [for (var j = _mulai!; j < akhir; j++) j]
          .any(_terisi.contains);
      if (kena) {
        _pesan = 'Rentang ini melewati slot yang sudah terisi. Pilih jam lain.';
      } else if (akhir - _mulai! > room.maksJam) {
        _pesan = 'Ruang ${room.nama} maksimal ${room.maksJam} jam per booking.';
      } else {
        _selesai = akhir;
      }
    });
  }

  SlotState _state(int h) {
    if (_terisi.contains(h)) return SlotState.terisi;
    if (_mulai != null && h >= _mulai! && h < _selesai!) {
      return SlotState.dipilih;
    }
    if (_promo.contains(h) && widget.venue.promo != null) {
      return SlotState.promo;
    }
    return SlotState.kosong;
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.venue;
    final adaPilihan = _mulai != null;
    return Scaffold(
      appBar: const TopBar(title: 'Pilih slot'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.x16, 0, Gap.x16, Gap.x24),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: Gap.x8),
            child: Row(
              children: [
                for (var i = 0; i < v.rooms.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: Gap.x8),
                    child: PillChip(
                      label: i == _room
                          ? '${v.rooms[i].nama} · ${v.rooms[i].kapasitasMin}–${v.rooms[i].kapasitasMaks}'
                          : v.rooms[i].nama,
                      selected: i == _room,
                      onTap: () => setState(() {
                        _room = i;
                        _pesan = null;
                      }),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Gap.x12),
          _Kalender(
            selected: _tanggal,
            onSelect: (d) => setState(() => _tanggal = d),
          ),
          const SizedBox(height: Gap.x16),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: const [
              _Legend(AppColors.card, AppColors.border, 'Kosong'),
              _Legend(AppColors.neutralSoft, AppColors.neutralSoft, 'Terisi'),
              _Legend(AppColors.accentSoft, AppColors.accent, 'Promo'),
              _Legend(AppColors.primary, AppColors.primary, 'Dipilih'),
            ],
          ),
          const SizedBox(height: Gap.x16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Jam · ${tanggalPendek(_tanggal)}',
                  style: AppText.h3,
                ),
              ),
              if (adaPilihan)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: Radii.pillAll,
                  ),
                  child: Text(
                    '${jam(_mulai!)}–${jam(_selesai!)} · ${_selesai! - _mulai!} jam',
                    style: AppText.label,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Ketuk jam mulai, lalu jam terakhir untuk memilih rentang.',
            style: AppText.caption,
          ),
          const SizedBox(height: Gap.x12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.45,
            children: [
              for (var h = _jamBuka; h < _jamTutup; h++)
                SlotTile(
                  jamLabel: jam(h),
                  state: _state(h),
                  promoLabel: _promo.contains(h) && v.promo != null
                      ? '−10%'
                      : null,
                  onTap: () => _tapSlot(h),
                ),
            ],
          ),
          if (_pesan != null) ...[
            const SizedBox(height: Gap.x12),
            InfoBanner(tone: BannerTone.danger, message: _pesan!),
          ],
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    adaPilihan
                        ? '${tanggalPendek(_tanggal)} · ${_selesai! - _mulai!} jam'
                        : 'Belum pilih jam',
                    style: AppText.caption.copyWith(fontSize: 13),
                  ),
                  Text(
                    adaPilihan ? '${jam(_mulai!)}–${jam(_selesai!)}' : '–',
                    style: AppText.h2.bold.tint(AppColors.primary),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: !adaPilihan
                    ? null
                    : () {
                        final promoJam = [
                          for (var j = _mulai!; j < _selesai!; j++) j,
                        ].where(_promo.contains).length;
                        final diskon = v.promo == null
                            ? 0
                            : (room.sewaPerJam * promoJam * 0.1).round();
                        final draft = Booking(
                          kode: 'RPT-0427',
                          venue: v,
                          room: room,
                          organisasi: 'BEM Fakultas Teknik',
                          acara: 'Rapat Koordinasi Dies Natalis',
                          tanggal: _tanggal,
                          jamMulai: _mulai!,
                          jamSelesai: _selesai!,
                          orang: 25,
                          status: BookingStatus.menungguKonfirmasi,
                          diskon: diskon,
                        );
                        Navigator.pushNamed(
                          context,
                          Routes.checkout,
                          arguments: draft,
                        );
                      },
                child: const Text('Lanjut ke checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.bg, this.border, this.label);
  final Color bg;
  final Color border;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Text(label, style: AppText.caption.copyWith(fontSize: 13)),
      ],
    );
  }
}

class _Kalender extends StatefulWidget {
  const _Kalender({required this.selected, required this.onSelect});
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  State<_Kalender> createState() => _KalenderState();
}

class _KalenderState extends State<_Kalender> {
  late DateTime _bulan = DateTime(widget.selected.year, widget.selected.month);
  static final _hariIni = DateTime(2026, 11, 20);

  @override
  Widget build(BuildContext context) {
    final offset = _bulan.weekday - 1; // Senin = 0
    final jumlahHari = DateUtils.getDaysInMonth(_bulan.year, _bulan.month);
    final bisaMundur = _bulan.isAfter(DateTime(_hariIni.year, _hariIni.month));
    return AppCard(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Bulan sebelumnya',
                onPressed: bisaMundur
                    ? () => setState(
                        () => _bulan = DateTime(_bulan.year, _bulan.month - 1),
                      )
                    : null,
                icon: const Icon(LucideIcons.chevronLeft, size: 20),
              ),
              Expanded(
                child: Text(
                  '${namaBulan[_bulan.month - 1]} ${_bulan.year}',
                  textAlign: TextAlign.center,
                  style: AppText.h3,
                ),
              ),
              IconButton(
                tooltip: 'Bulan berikutnya',
                onPressed: () => setState(
                  () => _bulan = DateTime(_bulan.year, _bulan.month + 1),
                ),
                icon: const Icon(LucideIcons.chevronRight, size: 20),
              ),
            ],
          ),
          Row(
            children: [
              for (final h in namaHari)
                Expanded(
                  child: Text(
                    h,
                    textAlign: TextAlign.center,
                    style: AppText.caption.copyWith(fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: offset + jumlahHari,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 44,
            ),
            itemBuilder: (context, i) {
              if (i < offset) return const SizedBox();
              final d = DateTime(_bulan.year, _bulan.month, i - offset + 1);
              final lewat = d.isBefore(_hariIni);
              final dipilih = DateUtils.isSameDay(d, widget.selected);
              final hariIni = DateUtils.isSameDay(d, _hariIni);
              return Center(
                child: InkResponse(
                  onTap: lewat ? null : () => widget.onSelect(d),
                  radius: 22,
                  child: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: dipilih ? AppColors.primary : null,
                      shape: BoxShape.circle,
                      border: hariIni && !dipilih
                          ? Border.all(color: AppColors.primary)
                          : null,
                    ),
                    child: Text(
                      '${d.day}',
                      style: AppText.body.copyWith(
                        color: dipilih
                            ? Colors.white
                            : (lewat ? AppColors.neutral : AppColors.text),
                        fontWeight: dipilih ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 12 · Checkout.
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key, required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return Scaffold(
      appBar: const TopBar(title: 'Checkout'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.x16, Gap.x8, Gap.x16, Gap.x24),
        children: [
          Row(
            children: [
              Photo(b.venue.foto, width: 60, height: 60, radius: 12),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.venue.nama, style: AppText.h3),
                    Text(
                      'Ruang ${b.room.nama} · ${b.orang} orang',
                      style: AppText.caption.copyWith(fontSize: 13),
                    ),
                    Text(
                      '${tanggalPendek(b.tanggal)} · ${jam(b.jamMulai)}–${jam(b.jamSelesai)}',
                      style: AppText.label.tint(AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.x20),
          const Divider(),
          const SizedBox(height: Gap.x20),
          Text('Detail acara', style: AppText.h2),
          const SizedBox(height: Gap.x16),
          LabeledField(
            label: 'Organisasi',
            initialValue: b.organisasi,
            icon: LucideIcons.building,
            readOnly: true,
            suffix: const Icon(LucideIcons.chevronDown, size: 20),
            onTap: () => showSoon(context, 'Ganti organisasi'),
          ),
          const SizedBox(height: Gap.x16),
          LabeledField(
            label: 'Nama acara',
            initialValue: b.acara,
            icon: LucideIcons.calendar,
          ),
          const SizedBox(height: Gap.x16),
          LabeledField(
            label: 'Catatan untuk mitra (opsional)',
            initialValue: 'Butuh proyektor dan 2 colokan tambahan. Datang 15 menit lebih awal.',
            maxLines: 3,
          ),
          const SizedBox(height: Gap.x20),
          RincianBiaya(booking: b, label: '${b.kode} · DRAFT'),
          const SizedBox(height: Gap.x16),
          const InfoBanner(
            message: 'Mitra mengonfirmasi dulu ketersediaan slot. Setelah diterima, kamu punya 24 jam untuk membayar lewat QRIS Rapatin.',
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        note: 'Status awal: Menunggu konfirmasi dari mitra',
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total dibayar',
                    style: AppText.caption.copyWith(fontSize: 13),
                  ),
                  Text(
                    rupiah(b.total),
                    style: AppText.h3.bold.tint(AppColors.primary),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.detailBooking,
                  ModalRoute.withName(Routes.penyewa),
                  arguments: b.copyWith(
                    status: BookingStatus.menungguKonfirmasi,
                  ),
                ),
                child: const Text('Booking sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu rincian biaya bergaya slip (dipakai di Checkout & Pembayaran).
class RincianBiaya extends StatelessWidget {
  const RincianBiaya({super.key, required this.booking, required this.label});
  final Booking booking;
  final String label;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return Container(
      padding: const EdgeInsets.all(Gap.x16),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: Radii.lgAll,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text('RINCIAN BIAYA', style: AppText.monoLabel)),
              Text(label, style: AppText.monoLabel.tint(AppColors.text)),
            ],
          ),
          const SizedBox(height: Gap.x12),
          PriceRow(
            'Sewa ruang · ${b.durasi} jam',
            b.sewa == 0 ? 'Gratis' : rupiah(b.sewa),
          ),
          PriceRow('Min. order · ${b.orang} orang', rupiah(b.minOrder)),
          if (b.diskon > 0)
            PriceRow('Diskon jam sepi', '−${rupiah(b.diskon)}', discount: true),
          PriceRow('Biaya layanan', rupiah(Booking.biayaLayanan)),
          PriceRow('Kode unik', '−${rupiah(b.kodeUnik)}', discount: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFFE4DCC6)),
          ),
          PriceRow('Total', rupiah(b.total), total: true),
        ],
      ),
    );
  }
}
