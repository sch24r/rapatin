import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app.dart';
import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../widgets/common.dart';
import '../penyewa/penyewa_shell.dart' show konfirmasiKeluar;

/// M14 · Pendapatan & pencairan.
class PendapatanScreen extends StatelessWidget {
  const PendapatanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const riwayat = [
      ('RPT-0427', 'BEM Fakultas Teknik', 'Cair Sen, 16 Nov', 1005000, false),
      ('RPT-0398', 'HIMA Sipil', 'Masuk 12 Nov', 785000, true),
      ('RPT-0390', 'BEM Fakultas Teknik', 'Masuk 10 Nov', 900000, true),
      ('RPT-0371', 'UKM Paduan Suara', 'Masuk 5 Nov', 800000, true),
    ];
    return Scaffold(
      appBar: const TopBar(title: 'Pendapatan'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.x16, 0, Gap.x16, Gap.x24),
        children: [
          AppCard(
            color: AppColors.primary,
            borderColor: AppColors.primary,
            padding: const EdgeInsets.all(Gap.x20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bersih November',
                  style: AppText.body.tint(AppColors.primarySoft),
                ),
                Text(
                  rupiah(3490000),
                  style: AppText.display.tint(Colors.white),
                ),
                const SizedBox(height: Gap.x12),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.landmark,
                      size: 16,
                      color: AppColors.primarySoft,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Ditransfer ke BCA ••4821 · a.n. Mamed',
                      style: AppText.caption.tint(AppColors.primarySoft),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                      child: Text('RINCIAN NOVEMBER', style: AppText.monoLabel),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.x8),
                PriceRow('Pendapatan kotor · 4 booking', rupiah(3570000)),
                PriceRow(
                  'Fee Rapatin · 4 × ${rupiah(20000)}',
                  '−${rupiah(80000)}',
                  discount: true,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Divider(color: Color(0xFFE4DCC6)),
                ),
                PriceRow('Bersih', rupiah(3490000), total: true),
              ],
            ),
          ),
          const SizedBox(height: Gap.x16),
          const InfoBanner(
            icon: LucideIcons.info,
            message: 'Dana tiap booking cair otomatis setelah masa pembatalan 2×24 jam berakhir (paling lambat 24 jam sebelum acara).',
          ),
          const SizedBox(height: Gap.x24),
          Text('Riwayat pencairan', style: AppText.h2),
          const SizedBox(height: Gap.x8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (kode, org, ket, nominal, masuk) in riwayat)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Gap.x16,
                      vertical: 4,
                    ),
                    leading: IconBox(
                      masuk ? LucideIcons.circleCheck : LucideIcons.hourglass,
                      size: 40,
                      bg: masuk ? AppColors.successSoft : AppColors.warningSoft,
                      fg: masuk ? AppColors.success : AppColors.warning,
                    ),
                    title: Text(org, style: AppText.bodyMedium),
                    subtitle: Text('$kode · $ket', style: AppText.caption),
                    trailing: Text(
                      rupiah(nominal),
                      style: AppText.bodyMedium.semi.tint(
                        masuk ? AppColors.text : AppColors.warning,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// M15 · Laporan bulanan.
class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const minggu = [
      ('1–7', 1, 900000),
      ('8–14', 2, 1585000),
      ('15–21', 1, 1005000),
      ('22–30', 0, 0),
    ];
    const maks = 1585000;
    return Scaffold(
      appBar: const TopBar(title: 'Laporan November'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.x16, 0, Gap.x16, Gap.x24),
        children: [
          Row(
            children: [
              Expanded(child: _Stat('Rombongan', '4', '+1 dari Okt')),
              const SizedBox(width: Gap.x12),
              Expanded(child: _Stat('Orang datang', '81', 'rata-rata 20')),
            ],
          ),
          const SizedBox(height: Gap.x12),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  'Omzet kotor',
                  rupiahShort(3570000),
                  'dari Rapatin',
                ),
              ),
              const SizedBox(width: Gap.x12),
              Expanded(child: _Stat('Rating', '4,8', '32 ulasan')),
            ],
          ),
          const SizedBox(height: Gap.x24),
          Text('Pendapatan bersih per minggu', style: AppText.h2),
          const SizedBox(height: Gap.x12),
          AppCard(
            child: Column(
              children: [
                for (final (label, n, nominal) in minggu)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          child: Text(
                            label,
                            style: AppText.caption.copyWith(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (_, c) => Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 22,
                                width: nominal == 0
                                    ? 4
                                    : c.maxWidth * nominal / maks,
                                decoration: BoxDecoration(
                                  color: nominal == 0
                                      ? AppColors.neutralSoft
                                      : AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: Gap.x8),
                        SizedBox(
                          width: 84,
                          child: Text(
                            nominal == 0
                                ? 'Belum ada'
                                : '${rupiahShort(nominal)} · $n',
                            textAlign: TextAlign.right,
                            style: AppText.label,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Gap.x24),
          Text('Organisasi paling sering', style: AppText.h2),
          const SizedBox(height: Gap.x8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (org, kali) in const [
                  ('BEM Fakultas Teknik', 2),
                  ('HIMA Sipil', 1),
                  ('UKM Paduan Suara', 1),
                ])
                  ListTile(
                    leading: const IconBox(LucideIcons.building2, size: 40),
                    title: Text(org, style: AppText.bodyMedium),
                    trailing: Text(
                      '$kali×',
                      style: AppText.bodyMedium.semi.tint(AppColors.primary),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Gap.x16),
          OutlinedButton.icon(
            onPressed: () => showSoon(context, 'Unduh laporan PDF'),
            icon: const Icon(LucideIcons.download, size: 18),
            label: const Text('Unduh laporan (PDF)'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.note);
  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.caption.copyWith(fontSize: 13)),
          Text(value, style: AppText.h1),
          Text(note, style: AppText.label.tint(AppColors.success)),
        ],
      ),
    );
  }
}

/// M17 · Akun Mitra.
class AkunMitraTab extends StatelessWidget {
  const AkunMitraTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.x16, Gap.x16, Gap.x16, Gap.x24),
        children: [
          Text('Akun', style: AppText.h1),
          const SizedBox(height: Gap.x16),
          AppCard(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.accentSoft,
                  child: Icon(LucideIcons.store, color: AppColors.warning),
                ),
                const SizedBox(width: Gap.x16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mamed', style: AppText.h3),
                      Text(
                        'mamed@kingkongresto.id',
                        style: AppText.caption.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mitra · King Kong Resto',
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
                  icon: LucideIcons.wallet,
                  title: 'Pendapatan',
                  subtitle: 'Bersih Nov ${rupiah(3490000)}',
                  onTap: () =>
                      Navigator.pushNamed(context, Routes.mitraPendapatan),
                ),
                MenuTile(
                  icon: LucideIcons.chartColumn,
                  title: 'Laporan bulanan',
                  onTap: () =>
                      Navigator.pushNamed(context, Routes.mitraLaporan),
                ),
                MenuTile(
                  icon: LucideIcons.landmark,
                  title: 'Rekening pencairan',
                  subtitle: 'BCA ••4821',
                  onTap: () =>
                      Navigator.pushNamed(context, Routes.mitraDataTempat),
                ),
                MenuTile(
                  icon: LucideIcons.bell,
                  title: 'Notifikasi',
                  onTap: () =>
                      Navigator.pushNamed(context, Routes.mitraNotifikasi),
                ),
                MenuTile(
                  icon: LucideIcons.messageCircle,
                  title: 'Bantuan',
                  subtitle: 'FAQ dan chat admin Rapatin',
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.bantuan,
                    arguments: Peran.mitra,
                  ),
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
}
