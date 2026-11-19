import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) Navigator.of(context).pushReplacementNamed(Routes.peran);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  LucideIcons.ticket,
                  size: 38,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: Gap.x20),
              Text(
                'RAPATIN',
                style: AppText.display
                    .tint(Colors.white)
                    .copyWith(letterSpacing: 3),
              ),
              const SizedBox(height: Gap.x4),
              Text(
                'Satu slip, semua beres.',
                style: AppText.body.tint(AppColors.primarySoft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
