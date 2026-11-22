import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../data/models.dart';

/// Tombol bulat putih (back, share, favorit) seperti di Figma.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.badge = false,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool badge;
  final double size;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AppColors.card,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.text),
              if (badge)
                const Positioned(
                  top: 10,
                  right: 11,
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: AppColors.danger,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      label: tooltip,
      child: SizedBox.square(dimension: 48, child: Center(child: button)),
    );
  }
}

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.fallbackRoute, this.onPressed});

  final String? fallbackRoute;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => CircleIconButton(
    icon: LucideIcons.chevronLeft,
    tooltip: 'Kembali',
    onPressed: () async {
      if (onPressed != null) {
        onPressed!();
        return;
      }
      final popped = await Navigator.of(context).maybePop();
      if (!popped && context.mounted) {
        Navigator.of(context).pushReplacementNamed(fallbackRoute ?? Routes.penyewa);
      }
    },
  );
}

/// Top app bar: tombol kembali bulat + judul di tengah.
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.fallbackRoute,
    this.onBack,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final String? fallbackRoute;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 72,
      automaticallyImplyLeading: false,
      leadingWidth: 72,
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.only(left: Gap.x12),
              child: AppBackButton(
                fallbackRoute: fallbackRoute,
                onPressed: onBack,
              ),
            )
          : null,
      title: Text(title),
      actions: [
        ...?actions,
        const SizedBox(width: Gap.x12),
      ],
    );
  }
}

/// Kartu putih membulat (radius lg) dengan border tipis.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Gap.x16),
    this.onTap,
    this.color = AppColors.card,
    this.borderColor = AppColors.border,
    this.radius = Radii.lg,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final Color borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.trailing,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppText.h2)),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.text,
              textStyle: AppText.body,
              padding: const EdgeInsets.symmetric(horizontal: Gap.x8),
            ),
            child: Text(action!),
          ),
        if (trailing != null) Text(trailing!, style: AppText.body.muted),
      ],
    );
  }
}

/// Badge status booking (10 varian).
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: status.bg, borderRadius: Radii.pillAll),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 3, backgroundColor: status.fg),
            const SizedBox(width: 6),
            Text(status.label, style: AppText.label.tint(status.fg)),
          ],
        ),
      ),
    );
  }
}

/// Badge promo jam sepi (accent).
class PromoBadge extends StatelessWidget {
  const PromoBadge(this.text, {super.key, this.compact = false});
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: Radii.pillAll,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 3 : 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.tag,
              size: compact ? 12 : 14,
              color: AppColors.text,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: AppText.label.copyWith(fontSize: compact ? 11 : 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip pill untuk filter/pilihan ruang.
class PillChip extends StatelessWidget {
  const PillChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.onPrimary : AppColors.text;
    return Material(
      color: selected ? AppColors.primary : AppColors.card,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: Gap.x16),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(label, style: AppText.bodyMedium.tint(fg)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip fasilitas (latar primary-soft, tidak bisa diklik).
class FacilityChip extends StatelessWidget {
  const FacilityChip(this.fasilitas, {super.key});
  final Fasilitas fasilitas;

  static IconData iconOf(Fasilitas f) => switch (f) {
    Fasilitas.privat => LucideIcons.lock,
    Fasilitas.proyektor => LucideIcons.projector,
    Fasilitas.colokan => LucideIcons.plug,
    Fasilitas.wifi => LucideIcons.wifi,
    Fasilitas.whiteboard => LucideIcons.presentation,
    Fasilitas.ac => LucideIcons.snowflake,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: Radii.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconOf(fasilitas), size: 16, color: AppColors.text),
          const SizedBox(width: 8),
          Text(
            fasilitas.label,
            style: AppText.bodyMedium.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Kotak ikon membulat (dipakai di kartu ringkasan & menu akun).
class IconBox extends StatelessWidget {
  const IconBox(
    this.icon, {
    super.key,
    this.bg = AppColors.primarySoft,
    this.fg = AppColors.primary,
    this.size = 44,
  });
  final IconData icon;
  final Color bg;
  final Color fg;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, size: size * 0.48, color: fg),
    );
  }
}

/// Foto dari aset dengan sudut membulat.
class Photo extends StatelessWidget {
  const Photo(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.radius = Radii.md,
    this.label,
  });
  final String asset;
  final double? width;
  final double? height;
  final double radius;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        asset,
        width: width,
        height: height,
        fit: BoxFit.cover,
        semanticLabel: label,
        cacheWidth: 720,
        errorBuilder: (_, _, _) => Container(
          width: width,
          height: height,
          color: AppColors.primarySoft,
          child: const Icon(LucideIcons.image, color: AppColors.primary),
        ),
      ),
    );
  }
}

enum BannerTone { info, warning, danger, success }

/// Banner info/peringatan/galat dengan ikon.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.message,
    this.title,
    this.tone = BannerTone.info,
    this.icon,
    this.trailing,
  });

  final String message;
  final String? title;
  final BannerTone tone;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final (fg, bg, defIcon) = switch (tone) {
      BannerTone.info => (
        AppColors.primary,
        AppColors.primarySoft,
        LucideIcons.info,
      ),
      BannerTone.warning => (
        AppColors.warning,
        AppColors.warningSoft,
        LucideIcons.clock,
      ),
      BannerTone.danger => (
        AppColors.danger,
        AppColors.dangerSoft,
        LucideIcons.circleAlert,
      ),
      BannerTone.success => (
        AppColors.success,
        AppColors.successSoft,
        LucideIcons.circleCheck,
      ),
    };
    return Container(
      padding: const EdgeInsets.all(Gap.x16),
      decoration: BoxDecoration(color: bg, borderRadius: Radii.mdAll),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defIcon, size: 22, color: fg),
          const SizedBox(width: Gap.x12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(title!, style: AppText.bodyMedium.semi.tint(fg)),
                Text(
                  message,
                  style: AppText.caption
                      .tint(AppColors.text)
                      .copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: Gap.x8), trailing!],
        ],
      ),
    );
  }
}

/// Bar aksi bawah yang menempel (CTA utama).
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child, this.note});
  final Widget child;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Gap.x16,
            Gap.x12,
            Gap.x16,
            Gap.x12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              if (note != null) ...[
                const SizedBox(height: Gap.x8),
                Text(
                  note!,
                  style: AppText.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Label + field input seperti komponen Input di Figma.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.icon,
    this.suffix,
    this.obscure = false,
    this.keyboardType,
    this.maxLines = 1,
    this.errorText,
    this.controller,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
  });

  final String label;
  final String? hint;
  final String? initialValue;
  final IconData? icon;
  final Widget? suffix;
  final bool obscure;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? errorText;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.bodyMedium),
        const SizedBox(height: Gap.x8),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          style: AppText.body.copyWith(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: icon == null ? null : Icon(icon, size: 20),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

/// Field password dengan tombol lihat/sembunyikan.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    this.label = 'Password',
    this.initialValue,
    this.errorText,
  });
  final String label;
  final String? initialValue;
  final String? errorText;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: widget.label,
      hint: 'Minimal 8 karakter',
      initialValue: widget.initialValue,
      icon: LucideIcons.lock,
      obscure: _hidden,
      errorText: widget.errorText,
      suffix: IconButton(
        tooltip: _hidden ? 'Tampilkan password' : 'Sembunyikan password',
        icon: Icon(_hidden ? LucideIcons.eye : LucideIcons.eyeOff, size: 20),
        onPressed: () => setState(() => _hidden = !_hidden),
      ),
    );
  }
}

/// Stepper angka (− angka +). Angka bisa diketuk lalu diketik langsung.
class QtyStepper extends StatefulWidget {
  const QtyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 100,
    this.suffix = 'orang',
  });
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String suffix;

  @override
  State<QtyStepper> createState() => _QtyStepperState();
}

class _QtyStepperState extends State<QtyStepper> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant QtyStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value &&
        int.tryParse(_controller.text) != widget.value) {
      _setText(widget.value);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) _commit(_controller.text);
  }

  void _setText(int v) {
    final text = '$v';
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// Simpan angka ketikan, dijepit ke [min]..[max]. Kosong → nilai semula.
  void _commit(String raw) {
    final next = (int.tryParse(raw.trim()) ?? widget.value)
        .clamp(widget.min, widget.max)
        .toInt();
    _setText(next);
    if (next != widget.value) widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData i, String tip, VoidCallback? f) =>
        IconButton.filledTonal(
          tooltip: tip,
          onPressed: f,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primarySoft,
            foregroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.neutralSoft,
            minimumSize: const Size(44, 44),
            shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
          ),
          icon: Icon(i, size: 20),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(
          LucideIcons.minus,
          'Kurangi',
          widget.value > widget.min
              ? () => widget.onChanged(widget.value - 1)
              : null,
        ),
        SizedBox(
          width: 96,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppText.h3,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              suffixText: widget.suffix.isEmpty ? null : widget.suffix,
              suffixStyle: AppText.h3,
            ),
            onSubmitted: _commit,
            onTapOutside: (_) => _focusNode.unfocus(),
          ),
        ),
        btn(
          LucideIcons.plus,
          'Tambah',
          widget.value < widget.max
              ? () => widget.onChanged(widget.value + 1)
              : null,
        ),
      ],
    );
  }
}

/// Baris rincian biaya.
class PriceRow extends StatelessWidget {
  const PriceRow(
    this.label,
    this.value, {
    super.key,
    this.discount = false,
    this.total = false,
  });
  final String label;
  final String value;
  final bool discount;
  final bool total;

  @override
  Widget build(BuildContext context) {
    final valueStyle = total
        ? AppText.h3.bold
        : discount
        ? AppText.bodyMedium.semi.tint(AppColors.success)
        : AppText.bodyMedium.semi;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: total ? AppText.bodyMedium.semi : AppText.body.muted,
            ),
          ),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

/// State kosong dengan ikon, judul, pesan, dan aksi.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Gap.x32,
        vertical: Gap.x32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconBox(icon, size: 72),
          const SizedBox(height: Gap.x20),
          Text(title, style: AppText.h2, textAlign: TextAlign.center),
          const SizedBox(height: Gap.x8),
          Text(message, style: AppText.body.muted, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: Gap.x24),
            FilledButton(onPressed: onAction, child: Text(action!)),
          ],
        ],
      ),
    );
  }
}

/// Baris menu (akun, pengaturan).
class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.danger = false,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool danger;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final fg = danger ? AppColors.danger : AppColors.primary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Gap.x16,
          vertical: Gap.x12,
        ),
        child: Row(
          children: [
            IconBox(
              icon,
              size: 40,
              fg: fg,
              bg: danger ? AppColors.dangerSoft : AppColors.primarySoft,
            ),
            const SizedBox(width: Gap.x12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.bodyMedium.tint(
                      danger ? AppColors.danger : AppColors.text,
                    ),
                  ),
                  if (subtitle != null) Text(subtitle!, style: AppText.caption),
                ],
              ),
            ),
            trailing ??
                (danger
                    ? const SizedBox()
                    : const Icon(
                        LucideIcons.chevronRight,
                        size: 20,
                        color: AppColors.textMuted,
                      )),
          ],
        ),
      ),
    );
  }
}

/// Baris info ikon + teks (alamat, jam buka, dll).
class IconLine extends StatelessWidget {
  const IconLine(
    this.icon,
    this.text, {
    super.key,
    this.color = AppColors.textMuted,
    this.style,
  });
  final IconData icon;
  final String text;
  final Color color;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: style ?? AppText.caption.copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }
}

void showSoon(BuildContext context, String fitur) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text('$fitur belum tersedia di versi UI ini.')),
    );
}
