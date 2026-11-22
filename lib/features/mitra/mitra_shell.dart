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
import '../../widgets/nav_bar.dart';
import 'mitra_booking_screens.dart';
import 'mitra_tempat_screens.dart';
import 'mitra_uang_screens.dart';

/// Daftar booking mitra yang dibagi antar-tab (sementara, sebelum Supabase).
final mitraBookings = ValueNotifier<List<Booking>>(List.of(bookingMitra));

void ubahStatusMitra(String kode, BookingStatus status) {
  mitraBookings.value = [
    for (final b in mitraBookings.value)
      b.kode == kode ? b.copyWith(status: status) : b,
  ];
}

/// Kerangka peran Mitra: Beranda, Booking, Jadwal, Tempat, Akun.
class MitraShell extends StatefulWidget {
  const MitraShell({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<MitraShell> createState() => _MitraShellState();
}

class _MitraShellState extends State<MitraShell> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _tab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _tab != 0) {
          setState(() => _tab = 0);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _tab,
          children: [
            MitraBerandaTab(onBooking: () => setState(() => _tab = 1)),
            const BookingMasukTab(),
            const JadwalTab(),
            const KelolaTempatTab(),
            const AkunMitraTab(),
          ],
        ),
        bottomNavigationBar: AppNavBar(
          index: _tab,
          onChanged: (i) => setState(() => _tab = i),
          items: const [
            NavItem(LucideIcons.house, 'Beranda'),
            NavItem(LucideIcons.ticket, 'Booking'),
            NavItem(LucideIcons.calendar, 'Jadwal'),
            NavItem(LucideIcons.store, 'Tempat'),
            NavItem(LucideIcons.user, 'Akun'),
          ],
        ),
      ),
    );
  }
}

/// M03 · Beranda Mitra.
class MitraBerandaTab extends StatelessWidget {
  const MitraBerandaTab({super.key, required this.onBooking});
  final VoidCallback onBooking;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder(
        valueListenable: mitraBookings,
        builder: (context, list, _) {
          final perlu = list
              .where((b) => b.status == BookingStatus.menungguKonfirmasi)
              .toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Gap.x16,
              Gap.x16,
              Gap.x16,
              Gap.x24,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat sore, Mas Mamed',
                          style: AppText.caption.copyWith(fontSize: 13),
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'King Kong Resto',
                                style: AppText.h2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'MITRA',
                                style: AppText.monoLabel
                                    .tint(AppColors.text)
                                    .copyWith(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  CircleIconButton(
                    icon: LucideIcons.bell,
                    tooltip: 'Notifikasi',
                    badge: true,
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.mitraNotifikasi),
                  ),
                ],
              ),
              const SizedBox(height: Gap.x16),
              AppCard(
                color: AppColors.primary,
                borderColor: AppColors.primary,
                padding: const EdgeInsets.all(Gap.x20),
                onTap: () => Navigator.pushNamed(context, Routes.mitraLaporan),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Laporan November',
                            style: AppText.body.tint(AppColors.primarySoft),
                          ),
                        ),
                        const Icon(
                          LucideIcons.chevronRight,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '4 rombongan',
                      style: AppText.display.tint(Colors.white),
                    ),
                    Text(
                      '±${rupiahShort(3490000)} bersih dari Rapatin',
                      style: AppText.body.tint(AppColors.primarySoft),
                    ),
                    const SizedBox(height: Gap.x12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: Radii.pillAll,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.trendingUp,
                            size: 14,
                            color: AppColors.text,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '+1 rombongan dari Oktober',
                            style: AppText.label,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Gap.x12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _Ringkas(
                        icon: LucideIcons.ticket,
                        tone: AppColors.warning,
                        bg: AppColors.warningSoft,
                        label: 'Perlu konfirmasi',
                        value: '${perlu.length} booking',
                        note: 'Balas < 15 menit',
                        onTap: onBooking,
                      ),
                    ),
                    const SizedBox(width: Gap.x12),
                    Expanded(
                      child: _Ringkas(
                        icon: LucideIcons.wallet,
                        tone: AppColors.success,
                        bg: AppColors.successSoft,
                        label: 'Siap dicairkan',
                        value: rupiah(1005000),
                        note: '1 booking · BCA ••4821',
                        onTap: () => Navigator.pushNamed(
                          context,
                          Routes.mitraPendapatan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Gap.x24),
              SectionHeader(
                title: 'Booking masuk',
                action: 'Lihat semua',
                onAction: onBooking,
              ),
              const SizedBox(height: Gap.x8),
              if (perlu.isEmpty)
                const AppCard(
                  child: EmptyState(
                    icon: LucideIcons.circleCheck,
                    title: 'Semua sudah dibalas',
                    message: 'Booking baru akan muncul di sini dan kamu dapat notifikasi.',
                  ),
                ),
              for (final b in perlu.take(2)) ...[
                BookingMasukCard(
                  booking: b,
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.mitraDetailBooking,
                    arguments: b,
                  ),
                  onTolak: () => tolakBooking(context, b),
                  onTerima: () => terimaBooking(context, b),
                ),
                const SizedBox(height: Gap.x12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Ringkas extends StatelessWidget {
  const _Ringkas({
    required this.icon,
    required this.tone,
    required this.bg,
    required this.label,
    required this.value,
    required this.note,
    this.onTap,
  });
  final IconData icon;
  final Color tone;
  final Color bg;
  final String label;
  final String value;
  final String note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBox(icon, bg: bg, fg: tone),
          const SizedBox(height: Gap.x12),
          Text(label, style: AppText.caption.copyWith(fontSize: 13)),
          Text(value, style: AppText.h3.bold),
          const SizedBox(height: 2),
          Text(note, style: AppText.label.tint(tone)),
        ],
      ),
    );
  }
}
