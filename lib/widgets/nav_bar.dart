import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';

class NavItem {
  const NavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// Bottom nav sesuai Figma: indikator pill primary-soft, label di bawah ikon.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
  });
  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.card,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.primarySoft,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          height: 72,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (s) => AppText.label.copyWith(
              color: s.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.textMuted,
              fontWeight: s.contains(WidgetState.selected)
                  ? FontWeight.w600
                  : FontWeight.w500,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (s) => IconThemeData(
              size: 22,
              color: s.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.textMuted,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: onChanged,
          destinations: [
            for (final i in items)
              NavigationDestination(icon: Icon(i.icon), label: i.label),
          ],
        ),
      ),
    );
  }
}
