import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/format.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../data/models.dart';
import 'common.dart';

/// Kartu tempat dengan foto besar (promo jam sepi, hasil cari).
class VenueCard extends StatelessWidget {
  const VenueCard({
    super.key,
    required this.venue,
    this.onTap,
    this.width,
    this.photoHeight = 150,
  });
  final Venue venue;
  final VoidCallback? onTap;
  final double? width;
  final double photoHeight;

  @override
  Widget build(BuildContext context) {
    final v = venue;
    return SizedBox(
      width: width,
      child: AppCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Photo(
                  v.foto,
                  height: photoHeight,
                  width: double.infinity,
                  radius: 0,
                  label: 'Foto ${v.nama}',
                ),
                if (v.promo != null)
                  Positioned(
                    left: 12,
                    top: 12,
                    child: PromoBadge(v.promo!, compact: true),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          v.nama,
                          style: AppText.h3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        LucideIcons.star,
                        size: 14,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        v.rating.toStringAsFixed(1).replaceAll('.', ','),
                        style: AppText.label,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    runSpacing: 2,
                    children: [
                      IconLine(LucideIcons.mapPin, v.area),
                      IconLine(LucideIcons.users, 'Maks ${v.kapasitasMaks}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'Min. ', style: AppText.caption),
                              TextSpan(
                                text: '${rupiahShort(v.minOrderTermurah)}/org',
                                style: AppText.label.tint(AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        v.slotKosong,
                        style: AppText.label.tint(AppColors.success),
                      ),
                    ],
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

/// Baris ruang di detail tempat.
class RoomRow extends StatelessWidget {
  const RoomRow({super.key, required this.room, this.onTap});
  final Room room;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final sewa = room.sewaPerJam == 0
        ? 'Gratis sewa'
        : '${rupiahShort(room.sewaPerJam)}/jam';
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Photo(room.foto, width: 64, height: 64, radius: 12),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ruang ${room.nama}', style: AppText.h3),
                Text(
                  'Kapasitas ${room.kapasitas}',
                  style: AppText.caption.copyWith(fontSize: 13),
                ),
                Text(
                  '$sewa · min. ${rupiahShort(room.minOrderPerOrang)}/org',
                  style: AppText.label.tint(AppColors.primary),
                ),
              ],
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            size: 20,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

/// Kartu menu/paket.
class MenuCard extends StatelessWidget {
  const MenuCard({super.key, required this.menu});
  final MenuPaket menu;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Photo(
              menu.foto,
              height: 100,
              width: double.infinity,
              radius: 0,
              label: menu.nama,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(menu.nama, style: AppText.bodyMedium.semi),
                  Text(
                    menu.deskripsi,
                    style: AppText.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rupiah(menu.harga),
                    style: AppText.bodyMedium.semi.tint(AppColors.primary),
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

enum SlotState { kosong, terisi, dipilih, promo }

/// Slot jam di grid Pilih slot.
class SlotTile extends StatelessWidget {
  const SlotTile({
    super.key,
    required this.jamLabel,
    required this.state,
    this.promoLabel,
    this.onTap,
  });
  final String jamLabel;
  final SlotState state;
  final String? promoLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg) = switch (state) {
      SlotState.kosong => (AppColors.card, AppColors.border, AppColors.text),
      SlotState.terisi => (
        AppColors.neutralSoft,
        AppColors.neutralSoft,
        AppColors.neutral,
      ),
      SlotState.dipilih => (
        AppColors.primary,
        AppColors.primary,
        AppColors.onPrimary,
      ),
      SlotState.promo => (
        AppColors.accentSoft,
        AppColors.accent,
        AppColors.text,
      ),
    };
    return Semantics(
      button: true,
      selected: state == SlotState.dipilih,
      enabled: state != SlotState.terisi,
      label: '$jamLabel${state == SlotState.terisi ? ', terisi' : ''}',
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: border,
            width: state == SlotState.promo ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: state == SlotState.terisi ? null : onTap,
          child: SizedBox(
            height: 52,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(jamLabel, style: AppText.bodyMedium.semi.tint(fg)),
                if (promoLabel != null)
                  Text(
                    promoLabel!,
                    style: AppText.label.copyWith(
                      fontSize: 11,
                      color: state == SlotState.dipilih
                          ? AppColors.onPrimary
                          : AppColors.warning,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu booking milik penyewa (tab Booking).
class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.action,
  });
  final Booking booking;
  final VoidCallback? onTap;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(b.kode, style: AppText.monoLabel)),
              StatusBadge(b.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Photo(b.venue.foto, width: 56, height: 56, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${b.venue.nama} · ${b.room.nama}',
                      style: AppText.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      b.acara,
                      style: AppText.caption.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${tanggalPendek(b.tanggal)} · ${jam(b.jamMulai)}–${jam(b.jamSelesai)} · ${b.orang} org',
                      style: AppText.label.tint(AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Kartu booking masuk untuk Mitra, dengan aksi cepat Tolak/Terima opsional.
class BookingMasukCard extends StatelessWidget {
  const BookingMasukCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onTolak,
    this.onTerima,
  });
  final Booking booking;
  final VoidCallback? onTap;
  final VoidCallback? onTolak;
  final VoidCallback? onTerima;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final aksi = onTolak != null && onTerima != null;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(b.status),
              const Spacer(),
              Text(rupiah(b.total), style: AppText.bodyMedium.semi),
            ],
          ),
          const SizedBox(height: 12),
          Text(b.organisasi, style: AppText.h2),
          Text(b.acara, style: AppText.caption.copyWith(fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              IconLine(
                LucideIcons.users,
                '${b.orang} orang',
                color: AppColors.text,
                style: AppText.label,
              ),
              IconLine(
                LucideIcons.calendar,
                tanggalPendek(b.tanggal),
                color: AppColors.text,
                style: AppText.label,
              ),
              IconLine(
                LucideIcons.clock,
                '${jam(b.jamMulai)}–${jam(b.jamSelesai)}',
                color: AppColors.text,
                style: AppText.label,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 10),
          Text(
            'Ruang ${b.room.nama} · ${b.kode}',
            style: AppText.caption.copyWith(fontSize: 13),
          ),
          if (aksi) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTolak,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      minimumSize: const Size.fromHeight(46),
                    ),
                    icon: const Icon(LucideIcons.x, size: 18),
                    label: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onTerima,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                    ),
                    icon: const Icon(LucideIcons.check, size: 18),
                    label: const Text('Terima'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Satu langkah di timeline status booking.
class TimelineStep extends StatelessWidget {
  const TimelineStep({
    super.key,
    required this.title,
    required this.subtitle,
    this.time,
    this.done = true,
    this.current = false,
    this.last = false,
  });
  final String title;
  final String subtitle;
  final String? time;
  final bool done;
  final bool current;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final dotColor = done
        ? AppColors.primary
        : (current ? AppColors.accent : AppColors.neutralSoft);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                  child: done
                      ? const Icon(
                          LucideIcons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : current
                      ? const Icon(
                          LucideIcons.clock,
                          size: 13,
                          color: AppColors.text,
                        )
                      : null,
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: done ? AppColors.primary : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.bodyMedium.semi.tint(
                      done || current ? AppColors.text : AppColors.textMuted,
                    ),
                  ),
                  Text(subtitle, style: AppText.caption.copyWith(fontSize: 13)),
                  if (time != null) Text(time!, style: AppText.monoLabel),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
