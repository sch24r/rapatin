import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app.dart';
import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/models.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';

/// 10 · Detail tempat.
class DetailTempatScreen extends StatefulWidget {
  const DetailTempatScreen({super.key, required this.venue});
  final Venue venue;

  @override
  State<DetailTempatScreen> createState() => _DetailTempatScreenState();
}

class _DetailTempatScreenState extends State<DetailTempatScreen> {
  bool _favorit = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.venue;
    final mulai = v.rooms
        .map((r) => r.sewaPerJam)
        .where((s) => s > 0)
        .fold<int?>(null, (a, b) => a == null || b < a ? b : a);
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.bg,
              leadingWidth: 64,
              leading: const Padding(
                padding: EdgeInsets.only(left: Gap.x8),
                child: AppBackButton(),
              ),
              actions: [
                CircleIconButton(
                  icon: LucideIcons.share2,
                  tooltip: 'Bagikan',
                  onPressed: () => showSoon(context, 'Bagikan'),
                ),
                CircleIconButton(
                  icon: LucideIcons.heart,
                  tooltip: _favorit
                      ? 'Hapus dari favorit'
                      : 'Simpan ke favorit',
                  onPressed: () => setState(() => _favorit = !_favorit),
                ),
                const SizedBox(width: Gap.x8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      v.foto,
                      fit: BoxFit.cover,
                      semanticLabel: 'Foto ${v.nama}',
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [Color(0x66000000), Color(0x00000000)],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xB32B1D14),
                          borderRadius: Radii.pillAll,
                        ),
                        child: Text(
                          '1/8 foto',
                          style: AppText.label.tint(Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Gap.x16,
                Gap.x16,
                Gap.x16,
                Gap.x24,
              ),
              sliver: SliverList.list(
                children: [
                  if (v.promo != null) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: PromoBadge(v.promo!),
                    ),
                    const SizedBox(height: Gap.x12),
                  ],
                  Text(v.nama, style: AppText.h1.copyWith(fontSize: 24)),
                  const SizedBox(height: Gap.x8),
                  IconLine(
                    LucideIcons.star,
                    '${v.rating.toStringAsFixed(1).replaceAll('.', ',')} · ${v.ulasan} ulasan dari panitia',
                    color: AppColors.accent,
                    style: AppText.body,
                  ),
                  const SizedBox(height: 6),
                  IconLine(LucideIcons.mapPin, v.alamat),
                  const SizedBox(height: 6),
                  IconLine(LucideIcons.clock, v.jamBuka),
                  const SizedBox(height: Gap.x24),
                  Text('Fasilitas', style: AppText.h2),
                  const SizedBox(height: Gap.x12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [for (final f in v.fasilitas) FacilityChip(f)],
                  ),
                  const SizedBox(height: Gap.x24),
                  SectionHeader(
                    title: 'Pilih ruang',
                    trailing: '${v.rooms.length} ruang',
                  ),
                  const SizedBox(height: Gap.x12),
                  for (final r in v.rooms) ...[
                    RoomRow(
                      room: r,
                      onTap: () => Navigator.pushNamed(
                        context,
                        Routes.pilihSlot,
                        arguments: v,
                      ),
                    ),
                    const SizedBox(height: Gap.x8),
                  ],
                  const SizedBox(height: Gap.x16),
                  Text('Menu & paket', style: AppText.h2),
                  const SizedBox(height: Gap.x12),
                  SizedBox(
                    height: 224,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, Gap.x8),
                      itemCount: v.menu.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: Gap.x12),
                      itemBuilder: (_, i) => MenuCard(menu: v.menu[i]),
                    ),
                  ),
                  const SizedBox(height: Gap.x20),
                  Text('Ketentuan', style: AppText.h2),
                  const SizedBox(height: Gap.x12),
                  AppCard(
                    child: Column(
                      children: [
                        for (final (i, t) in const [
                          (
                            LucideIcons.utensils,
                            'Minimum order dihitung per orang dan dibayar di muka.',
                          ),
                          (
                            LucideIcons.clock,
                            'Datang paling cepat 15 menit sebelum slot dimulai.',
                          ),
                          (
                            LucideIcons.calendarX,
                            'Batal gratis 2×24 jam setelah lunas, paling lambat 24 jam sebelum acara.',
                          ),
                        ])
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(i, size: 18, color: AppColors.primary),
                                const SizedBox(width: Gap.x12),
                                Expanded(child: Text(t, style: AppText.body)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomActionBar(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Mulai dari',
                      style: AppText.caption.copyWith(fontSize: 13),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: mulai == null
                                ? 'Gratis sewa'
                                : rupiahShort(mulai),
                            style: AppText.h2.bold.tint(AppColors.primary),
                          ),
                          if (mulai != null)
                            TextSpan(text: ' /jam', style: AppText.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    Routes.pilihSlot,
                    arguments: v,
                  ),
                  child: const Text('Pilih slot'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
