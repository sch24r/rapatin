import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../widgets/common.dart';
import '../auth/auth_screens.dart';

/// M01 · Daftar Mitra.
class MitraRegisterScreen extends StatelessWidget {
  const MitraRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Daftar sebagai Mitra',
      subtitle: 'Untuk kafe dan resto yang punya ruang rombongan.',
      fields: const [
        LabeledField(
          label: 'Nama pemilik/pengelola',
          hint: 'Nama lengkap',
          icon: LucideIcons.user,
        ),
        SizedBox(height: Gap.x16),
        LabeledField(
          label: 'Nama usaha',
          hint: 'Contoh: King Kong Resto',
          icon: LucideIcons.store,
        ),
        SizedBox(height: Gap.x16),
        LabeledField(
          label: 'Email',
          hint: 'nama@usaha.id',
          icon: LucideIcons.mail,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: Gap.x16),
        LabeledField(
          label: 'Nomor HP (WhatsApp)',
          hint: '08xx xxxx xxxx',
          icon: LucideIcons.phone,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: Gap.x16),
        PasswordField(),
      ],
      cta: FilledButton(
        onPressed: () => Navigator.pushNamed(context, Routes.mitraDataTempat),
        child: const Text('Lanjut isi data tempat'),
      ),
    );
  }
}

/// M02 · Data tempat & rekening pencairan.
class MitraDataTempatScreen extends StatelessWidget {
  const MitraDataTempatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(title: 'Data tempat'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.x16, 0, Gap.x16, Gap.x24),
        children: [
          Text('Langkah 2 dari 2', style: AppText.monoLabel),
          const SizedBox(height: Gap.x8),
          ClipRRect(
            borderRadius: Radii.pillAll,
            child: const LinearProgressIndicator(
              value: 1,
              minHeight: 6,
              backgroundColor: AppColors.primarySoft,
            ),
          ),
          const SizedBox(height: Gap.x20),
          const LabeledField(
            label: 'Nama tempat',
            initialValue: 'King Kong Resto',
            icon: LucideIcons.store,
          ),
          const SizedBox(height: Gap.x16),
          const LabeledField(
            label: 'Alamat',
            initialValue: 'Jl. Raya Gubeng No. 12, Surabaya',
            icon: LucideIcons.mapPin,
            maxLines: 2,
          ),
          const SizedBox(height: Gap.x16),
          const Row(
            children: [
              Expanded(
                child: LabeledField(
                  label: 'Jam buka',
                  initialValue: '10.00',
                  icon: LucideIcons.clock,
                ),
              ),
              SizedBox(width: Gap.x12),
              Expanded(
                child: LabeledField(
                  label: 'Jam tutup',
                  initialValue: '22.00',
                  icon: LucideIcons.clock,
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.x20),
          Text('Foto tempat', style: AppText.bodyMedium),
          const SizedBox(height: Gap.x8),
          SizedBox(
            height: 94,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: Gap.x8),
              children: [
                for (final f in const [
                  'assets/images/resto_vip.jpg',
                  'assets/images/ruang_kaca.jpg',
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: Gap.x8),
                    child: Photo(f, width: 84, height: 84, radius: 12),
                  ),
                Material(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => showSoon(context, 'Tambah foto'),
                    child: const SizedBox(
                      width: 84,
                      height: 84,
                      child: Icon(
                        LucideIcons.camera,
                        color: AppColors.primary,
                        semanticLabel: 'Tambah foto',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.x24),
          Text('Rekening pencairan', style: AppText.h2),
          const SizedBox(height: 4),
          Text(
            'Pendapatan bersih ditransfer ke sini setelah masa pembatalan berakhir.',
            style: AppText.caption.copyWith(fontSize: 13),
          ),
          const SizedBox(height: Gap.x16),
          const LabeledField(
            label: 'Bank',
            initialValue: 'BCA',
            icon: LucideIcons.landmark,
            suffix: Icon(LucideIcons.chevronDown, size: 20),
          ),
          const SizedBox(height: Gap.x16),
          const LabeledField(
            label: 'Nomor rekening',
            initialValue: '0881 2948 21',
            icon: LucideIcons.wallet,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: Gap.x16),
          const LabeledField(
            label: 'Nama pemilik rekening',
            initialValue: 'Mamed',
            icon: LucideIcons.user,
          ),
          const SizedBox(height: Gap.x16),
          const InfoBanner(
            message: 'Fee Rapatin flat Rp20.000 per booking lunas, dipotong otomatis saat pencairan.',
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: FilledButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.mitra,
            (_) => false,
          ),
          child: const Text('Simpan dan mulai'),
        ),
      ),
    );
  }
}
