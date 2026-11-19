import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app.dart';
import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/dummy_data.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';

/// M10 · Kelola tempat.
class KelolaTempatTab extends StatefulWidget {
  const KelolaTempatTab({super.key});

  @override
  State<KelolaTempatTab> createState() => _KelolaTempatTabState();
}

class _KelolaTempatTabState extends State<KelolaTempatTab> {
  final _aktif = {for (final r in kingKong.rooms) r.nama: true};

  @override
  Widget build(BuildContext context) {
    final v = kingKong;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.x16, Gap.x16, Gap.x16, Gap.x24),
        children: [
          Text('Tempat saya', style: AppText.h1),
          const SizedBox(height: Gap.x16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Photo(v.foto, height: 140, width: double.infinity, radius: 0),
                Padding(
                  padding: const EdgeInsets.all(Gap.x16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(v.nama, style: AppText.h2)),
                          TextButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              Routes.mitraDataTempat,
                            ),
                            icon: const Icon(LucideIcons.pencil, size: 16),
                            label: const Text('Ubah'),
                          ),
                        ],
                      ),
                      IconLine(LucideIcons.mapPin, v.alamat),
                      const SizedBox(height: 4),
                      IconLine(LucideIcons.clock, v.jamBuka),
                      const SizedBox(height: 4),
                      IconLine(
                        LucideIcons.star,
                        '${v.rating.toStringAsFixed(1).replaceAll('.', ',')} · ${v.ulasan} ulasan',
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.x24),
          SectionHeader(
            title: 'Ruang',
            action: '+ Tambah',
            onAction: () => Navigator.pushNamed(context, Routes.mitraEditRuang),
          ),
          const SizedBox(height: Gap.x8),
          for (final r in v.rooms) ...[
            AppCard(
              onTap: () => Navigator.pushNamed(
                context,
                Routes.mitraEditRuang,
                arguments: r,
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Opacity(
                    opacity: _aktif[r.nama]! ? 1 : 0.45,
                    child: Photo(r.foto, width: 56, height: 56, radius: 12),
                  ),
                  const SizedBox(width: Gap.x12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ruang ${r.nama}', style: AppText.h3),
                        Text(
                          r.kapasitas,
                          style: AppText.caption.copyWith(fontSize: 13),
                        ),
                        Text(
                          '${r.sewaPerJam == 0 ? 'Gratis sewa' : '${rupiahShort(r.sewaPerJam)}/jam'} · min. ${rupiahShort(r.minOrderPerOrang)}/org',
                          style: AppText.label.tint(AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _aktif[r.nama]!,
                    onChanged: (x) => setState(() => _aktif[r.nama] = x),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.x8),
          ],
          const SizedBox(height: Gap.x16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                MenuTile(
                  icon: LucideIcons.tag,
                  title: 'Promo jam sepi',
                  subtitle: '1 promo aktif · 14.00–17.00 −10%',
                  onTap: () => Navigator.pushNamed(context, Routes.mitraPromo),
                ),
                MenuTile(
                  icon: LucideIcons.utensils,
                  title: 'Menu & paket',
                  subtitle: '${v.menu.length} paket',
                  onTap: () => showSoon(context, 'Kelola menu'),
                ),
                MenuTile(
                  icon: LucideIcons.image,
                  title: 'Foto tempat',
                  subtitle: '8 foto',
                  onTap: () => showSoon(context, 'Kelola foto'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// M11 · Edit (atau tambah) ruang.
class EditRuangScreen extends StatefulWidget {
  const EditRuangScreen({super.key, this.room});
  final Room? room;

  @override
  State<EditRuangScreen> createState() => _EditRuangScreenState();
}

class _EditRuangScreenState extends State<EditRuangScreen> {
  late int _min = widget.room?.kapasitasMin ?? 10;
  late int _maks = widget.room?.kapasitasMaks ?? 20;
  late int _maksJam = widget.room?.maksJam ?? 2;
  late final _fas = <Fasilitas>{
    Fasilitas.privat,
    Fasilitas.proyektor,
    Fasilitas.colokan,
  };
  bool _aktif = true;

  @override
  Widget build(BuildContext context) {
    final r = widget.room;
    return Scaffold(
      appBar: TopBar(title: r == null ? 'Tambah ruang' : 'Ubah ruang'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.x16, 0, Gap.x16, Gap.x24),
        children: [
          LabeledField(
            label: 'Nama ruang',
            initialValue: r?.nama,
            hint: 'Contoh: VIP Lantai 2',
            icon: LucideIcons.armchair,
          ),
          const SizedBox(height: Gap.x20),
          Text('Kapasitas', style: AppText.bodyMedium),
          const SizedBox(height: Gap.x8),
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Minimal', style: AppText.body)),
                    QtyStepper(
                      value: _min,
                      max: _maks,
                      onChanged: (v) => setState(() => _min = v),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.x12),
                Row(
                  children: [
                    Expanded(child: Text('Maksimal', style: AppText.body)),
                    QtyStepper(
                      value: _maks,
                      min: _min,
                      onChanged: (v) => setState(() => _maks = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.x20),
          Row(
            children: [
              Expanded(
                child: LabeledField(
                  label: 'Sewa per jam',
                  initialValue: r == null
                      ? ''
                      : rupiah(r.sewaPerJam, withPrefix: false),
                  hint: '0 = gratis',
                  icon: LucideIcons.wallet,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: Gap.x12),
              Expanded(
                child: LabeledField(
                  label: 'Min. order/orang',
                  initialValue: r == null
                      ? ''
                      : rupiah(r.minOrderPerOrang, withPrefix: false),
                  icon: LucideIcons.utensils,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.x20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Maks durasi per booking',
                  style: AppText.bodyMedium,
                ),
              ),
              QtyStepper(
                value: _maksJam,
                max: 6,
                suffix: 'jam',
                onChanged: (v) => setState(() => _maksJam = v),
              ),
            ],
          ),
          const SizedBox(height: Gap.x20),
          Text('Fasilitas', style: AppText.bodyMedium),
          const SizedBox(height: Gap.x8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in Fasilitas.values)
                PillChip(
                  label: f.label,
                  icon: FacilityChip.iconOf(f),
                  selected: _fas.contains(f),
                  onTap: () => setState(
                    () => _fas.contains(f) ? _fas.remove(f) : _fas.add(f),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Gap.x20),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.x16,
              vertical: Gap.x8,
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _aktif,
              onChanged: (v) => setState(() => _aktif = v),
              title: Text('Tampilkan ke panitia', style: AppText.bodyMedium),
              subtitle: Text(
                'Matikan kalau ruang sedang tidak bisa dipesan.',
                style: AppText.caption,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: FilledButton(
          onPressed: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Ruang disimpan')));
            Navigator.pop(context);
          },
          child: const Text('Simpan ruang'),
        ),
      ),
    );
  }
}

/// M12 · Daftar promo jam sepi.
class PromoScreen extends StatefulWidget {
  const PromoScreen({super.key});

  @override
  State<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen> {
  final _promo = [
    ('14.00–17.00 −10%', 'Sen–Jum · Semua ruang', true, '6 booking bulan ini'),
    (
      '10.00–12.00 −15%',
      'Sab–Min · Ruang Reguler',
      false,
      'Belum pernah dipakai',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(title: 'Promo jam sepi'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.x16, 0, Gap.x16, Gap.x24),
        children: [
          const InfoBanner(
            icon: LucideIcons.sparkles,
            message: 'Promo tampil di Beranda panitia dan slotnya ditandai kuning. Cocok untuk mengisi jam siang yang sepi.',
          ),
          const SizedBox(height: Gap.x16),
          for (var i = 0; i < _promo.length; i++) ...[
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PromoBadge(_promo[i].$1),
                        const SizedBox(height: Gap.x8),
                        Text(_promo[i].$2, style: AppText.bodyMedium),
                        Text(_promo[i].$4, style: AppText.caption),
                      ],
                    ),
                  ),
                  Switch(
                    value: _promo[i].$3,
                    onChanged: (v) => setState(
                      () => _promo[i] = (
                        _promo[i].$1,
                        _promo[i].$2,
                        v,
                        _promo[i].$4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.x8),
          ],
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: FilledButton.icon(
          onPressed: () => Navigator.pushNamed(context, Routes.mitraBuatPromo),
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text('Buat promo'),
        ),
      ),
    );
  }
}

/// M13 · Buat promo.
class BuatPromoScreen extends StatefulWidget {
  const BuatPromoScreen({super.key});

  @override
  State<BuatPromoScreen> createState() => _BuatPromoScreenState();
}

class _BuatPromoScreenState extends State<BuatPromoScreen> {
  RangeValues _jam = const RangeValues(14, 17);
  double _diskon = 10;
  final _hari = <String>{'Sen', 'Sel', 'Rab', 'Kam', 'Jum'};
  final _ruang = <String>{'Reguler', 'VIP', 'Privat'};

  @override
  Widget build(BuildContext context) {
    final label =
        '${jam(_jam.start.round())}–${jam(_jam.end.round())} −${_diskon.round()}%';
    return Scaffold(
      appBar: const TopBar(title: 'Buat promo'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.x16, 0, Gap.x16, Gap.x24),
        children: [
          Text('Pratinjau', style: AppText.caption.copyWith(fontSize: 13)),
          const SizedBox(height: Gap.x8),
          Align(alignment: Alignment.centerLeft, child: PromoBadge(label)),
          const SizedBox(height: Gap.x24),
          Text('Jam promo', style: AppText.h3),
          RangeSlider(
            values: _jam,
            min: 10,
            max: 22,
            divisions: 12,
            labels: RangeLabels(jam(_jam.start.round()), jam(_jam.end.round())),
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primarySoft,
            onChanged: (v) => setState(
              () => _jam = v.end - v.start < 1
                  ? RangeValues(v.start, v.start + 1)
                  : v,
            ),
          ),
          const SizedBox(height: Gap.x12),
          Row(
            children: [
              Expanded(child: Text('Diskon sewa ruang', style: AppText.h3)),
              Text(
                '${_diskon.round()}%',
                style: AppText.h3.tint(AppColors.primary),
              ),
            ],
          ),
          Slider(
            value: _diskon,
            min: 5,
            max: 50,
            divisions: 9,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primarySoft,
            onChanged: (v) => setState(() => _diskon = v),
          ),
          const SizedBox(height: Gap.x12),
          Text('Hari', style: AppText.h3),
          const SizedBox(height: Gap.x8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final h in namaHari)
                PillChip(
                  label: h,
                  selected: _hari.contains(h),
                  onTap: () => setState(
                    () => _hari.contains(h) ? _hari.remove(h) : _hari.add(h),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Gap.x20),
          Text('Berlaku di ruang', style: AppText.h3),
          const SizedBox(height: Gap.x8),
          Wrap(
            spacing: 8,
            children: [
              for (final r in kingKong.rooms)
                PillChip(
                  label: r.nama,
                  selected: _ruang.contains(r.nama),
                  onTap: () => setState(
                    () => _ruang.contains(r.nama)
                        ? _ruang.remove(r.nama)
                        : _ruang.add(r.nama),
                  ),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: FilledButton(
          onPressed: _hari.isEmpty || _ruang.isEmpty
              ? null
              : () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Promo $label aktif')));
                  Navigator.pop(context);
                },
          child: const Text('Aktifkan promo'),
        ),
      ),
    );
  }
}
