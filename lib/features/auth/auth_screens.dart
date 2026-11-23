import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/dummy_data.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';

/// 02 · Pilih peran.
class PilihPeranScreen extends StatefulWidget {
  const PilihPeranScreen({super.key});

  @override
  State<PilihPeranScreen> createState() => _PilihPeranScreenState();
}

class _PilihPeranScreenState extends State<PilihPeranScreen> {
  Peran _peran = Peran.penyewa;

  @override
  Widget build(BuildContext context) {
    final penyewa = _peran == Peran.penyewa;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.x20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Gap.x16),
              const _HeroSlip(),
              const SizedBox(height: Gap.x24),
              Text('Masuk sebagai siapa?', style: AppText.h1),
              const SizedBox(height: Gap.x4),
              Text(
                'Pilih peranmu. Satu akun hanya untuk satu peran.',
                style: AppText.body.muted,
              ),
              const SizedBox(height: Gap.x20),
              _RoleCard(
                icon: LucideIcons.users,
                title: 'Penyewa',
                desc: 'Mahasiswa atau panitia yang mencari tempat rapat',
                selected: penyewa,
                onTap: () => setState(() => _peran = Peran.penyewa),
              ),
              const SizedBox(height: Gap.x12),
              _RoleCard(
                icon: LucideIcons.store,
                title: 'Mitra',
                desc: 'Pengelola kafe atau resto yang punya ruang rombongan',
                selected: !penyewa,
                onTap: () => setState(() => _peran = Peran.mitra),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  Routes.login,
                  arguments: _peran,
                ),
                child: Text('Masuk sebagai ${penyewa ? 'Penyewa' : 'Mitra'}'),
              ),
              const SizedBox(height: Gap.x8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Belum punya akun?', style: AppText.body.muted),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      penyewa ? Routes.register : Routes.mitraRegister,
                    ),
                    child: const Text('Daftar'),
                  ),
                ],
              ),
              const SizedBox(height: Gap.x8),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSlip extends StatelessWidget {
  const _HeroSlip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: Radii.lgAll,
      ),
      child: Stack(
        children: [
          Positioned(
            left: -60,
            bottom: -90,
            child: Container(
              width: 240,
              height: 200,
              decoration: const BoxDecoration(
                color: AppColors.primaryPressed,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RAPATIN',
                  style: AppText.h2
                      .tint(Colors.white)
                      .copyWith(letterSpacing: 2),
                ),
                const SizedBox(height: 8),
                Text(
                  'Satu slip,\nsemua beres.',
                  style: AppText.body
                      .tint(AppColors.primarySoft)
                      .copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
          Positioned(
            right: -24,
            top: 26,
            child: Transform.rotate(
              angle: -0.07,
              child: Container(
                width: 200,
                height: 210,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'SLIP RESERVASI',
                            style: AppText.monoLabel.copyWith(fontSize: 8),
                          ),
                        ),
                        Text(
                          '#RPT-0427',
                          style: AppText.monoLabel.copyWith(fontSize: 8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'KING KONG RESTO',
                      style: AppText.bodyMedium.bold.copyWith(fontSize: 13),
                    ),
                    for (final (k, v) in const [
                      ('Panitia', 'BEM Fakultas'),
                      ('Jumlah', '25 orang'),
                      ('Waktu', 'Sab, 21 Nov'),
                      ('Ruang', 'VIP'),
                    ]) ...[
                      const Divider(color: Color(0xFFE4DCC6), height: 14),
                      Row(
                        children: [
                          Text(
                            k,
                            style: AppText.caption.copyWith(fontSize: 10),
                          ),
                          const Spacer(),
                          Text(v, style: AppText.label.copyWith(fontSize: 10)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: AppCard(
        onTap: onTap,
        borderColor: selected ? AppColors.primary : AppColors.border,
        padding: const EdgeInsets.all(Gap.x16),
        child: Row(
          children: [
            IconBox(
              icon,
              size: 52,
              bg: selected ? AppColors.primary : AppColors.primarySoft,
              fg: selected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: Gap.x16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.h3),
                  Text(desc, style: AppText.caption.copyWith(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: Gap.x8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Kerangka form auth: back + judul + subjudul + isi + CTA.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.cta,
    this.footer,
  });
  final String title;
  final String subtitle;
  final List<Widget> fields;
  final Widget cta;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(title: ''),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.x20, 0, Gap.x20, Gap.x24),
        children: [
          Text(title, style: AppText.h1),
          const SizedBox(height: Gap.x4),
          Text(subtitle, style: AppText.body.muted),
          const SizedBox(height: Gap.x24),
          ...fields,
          const SizedBox(height: Gap.x24),
          cta,
          if (footer != null) ...[const SizedBox(height: Gap.x8), footer!],
        ],
      ),
    );
  }
}

/// 04 · Login (dengan state galat peran tidak cocok).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.peran});
  final Peran peran;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final _email = TextEditingController(
    text: widget.peran == Peran.penyewa
        ? 'alden@student.its.ac.id'
        : 'mamed@kingkongresto.id',
  );
  bool _salahPeran = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _masuk() {
    final email = _email.text.toLowerCase();
    // Demo: email mitra dipakai di login penyewa (atau sebaliknya) memunculkan galat.
    final akunMitra = email.contains('resto') || email.contains('kafe');
    final cocok = widget.peran == Peran.mitra ? akunMitra : !akunMitra;
    if (!cocok) {
      setState(() => _salahPeran = true);
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      widget.peran == Peran.penyewa ? Routes.penyewa : Routes.mitra,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final penyewa = widget.peran == Peran.penyewa;
    final peranLain = penyewa ? 'Mitra' : 'Penyewa';
    return AuthScaffold(
      title: 'Masuk sebagai ${penyewa ? 'Penyewa' : 'Mitra'}',
      subtitle: penyewa
          ? 'Cari dan booking tempat rapat untuk panitiamu.'
          : 'Kelola booking rombongan di tempatmu.',
      fields: [
        if (_salahPeran) ...[
          InfoBanner(
            tone: BannerTone.danger,
            icon: LucideIcons.userX,
            title: 'Akun ini terdaftar sebagai $peranLain',
            message:
                'Kembali ke pilih peran lalu masuk sebagai $peranLain, atau gunakan email lain.',
          ),
          const SizedBox(height: Gap.x16),
        ],
        LabeledField(
          label: 'Email',
          controller: _email,
          icon: LucideIcons.mail,
          keyboardType: TextInputType.emailAddress,
          errorText: _salahPeran ? 'Peran akun tidak cocok' : null,
          onChanged: (_) =>
              _salahPeran ? setState(() => _salahPeran = false) : null,
        ),
        const SizedBox(height: Gap.x16),
        const PasswordField(initialValue: 'rapatin123'),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.pushNamed(context, Routes.lupaPassword),
            child: const Text('Lupa password?'),
          ),
        ),
      ],
      cta: FilledButton(onPressed: _masuk, child: const Text('Masuk')),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Belum punya akun?', style: AppText.body.muted),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              penyewa ? Routes.register : Routes.mitraRegister,
            ),
            child: const Text('Daftar'),
          ),
        ],
      ),
    );
  }
}

/// 03 · Register Penyewa.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Daftar sebagai Penyewa',
      subtitle: 'Untuk mahasiswa dan panitia kegiatan kampus.',
      fields: const [
        LabeledField(
          label: 'Nama lengkap',
          hint: 'Nama sesuai KTM',
          icon: LucideIcons.user,
        ),
        SizedBox(height: Gap.x16),
        LabeledField(
          label: 'Email',
          hint: 'nama@student.its.ac.id',
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
        LabeledField(
          label: 'Kampus',
          hint: 'Institut Teknologi Sepuluh Nopember',
          icon: LucideIcons.school,
        ),
        SizedBox(height: Gap.x16),
        PasswordField(),
      ],
      cta: FilledButton(
        onPressed: () => Navigator.pushNamed(context, Routes.profilOrganisasi),
        child: const Text('Daftar'),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Sudah punya akun?', style: AppText.body.muted),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              Routes.login,
              arguments: Peran.penyewa,
            ),
            child: const Text('Masuk'),
          ),
        ],
      ),
    );
  }
}

/// 05 · Lupa password.
class LupaPasswordScreen extends StatefulWidget {
  const LupaPasswordScreen({super.key});

  @override
  State<LupaPasswordScreen> createState() => _LupaPasswordScreenState();
}

class _LupaPasswordScreenState extends State<LupaPasswordScreen> {
  bool _terkirim = false;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Lupa password',
      subtitle: 'Masukkan email akunmu. Kami kirim tautan untuk membuat password baru.',
      fields: [
        const LabeledField(
          label: 'Email',
          initialValue: 'alden@student.its.ac.id',
          icon: LucideIcons.mail,
        ),
        if (_terkirim) ...[
          const SizedBox(height: Gap.x16),
          const InfoBanner(
            tone: BannerTone.success,
            title: 'Tautan terkirim',
            message:
                'Cek kotak masuk atau folder spam. Tautan berlaku 30 menit.',
          ),
        ],
      ],
      cta: FilledButton(
        onPressed: _terkirim
            ? () => Navigator.pop(context)
            : () => setState(() => _terkirim = true),
        child: Text(_terkirim ? 'Kembali ke Masuk' : 'Kirim tautan reset'),
      ),
    );
  }
}

/// 06 · Buat profil organisasi / Tambah organisasi.
class ProfilOrganisasiScreen extends StatefulWidget {
  const ProfilOrganisasiScreen({super.key});

  @override
  State<ProfilOrganisasiScreen> createState() => _ProfilOrganisasiScreenState();
}

class _ProfilOrganisasiScreenState extends State<ProfilOrganisasiScreen> {
  String _jenis = 'BEM';
  late final TextEditingController _namaController;
  late final TextEditingController _jabatanController;
  late final TextEditingController _kampusController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _jabatanController = TextEditingController();
    _kampusController = TextEditingController(
      text: 'Institut Teknologi Sepuluh Nopember',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final isTambah = ModalRoute.of(context)?.settings.arguments == true;
      if (!isTambah) {
        _namaController.text = 'BEM Fakultas Teknik';
        _jabatanController.text = 'Sekretaris';
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jabatanController.dispose();
    _kampusController.dispose();
    super.dispose();
  }

  void _simpan(bool isTambah) {
    final nama = _namaController.text.trim();
    final jabatan = _jabatanController.text.trim();
    final kampus = _kampusController.text.trim();

    if (nama.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Nama organisasi wajib diisi')),
        );
      return;
    }

    final newOrg = Organisasi(
      nama: nama,
      jenis: _jenis,
      jabatan: jabatan.isEmpty ? 'Anggota' : jabatan,
      kampus: kampus.isEmpty ? 'Institut Teknologi Sepuluh Nopember' : kampus,
    );

    tambahOrganisasi(newOrg);

    if (isTambah) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Organisasi "${newOrg.nama}" berhasil ditambahkan.'),
            duration: const Duration(seconds: 2),
          ),
        );
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.penyewa,
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTambah = ModalRoute.of(context)?.settings.arguments == true;
    return AuthScaffold(
      title: isTambah ? 'Tambah organisasi' : 'Profil organisasi',
      subtitle: isTambah
          ? 'Organisasi baru akan otomatis menjadi organisasi aktifmu.'
          : 'Nama organisasi muncul di slip reservasi dan dilihat mitra.',
      fields: [
        LabeledField(
          label: 'Nama organisasi',
          hint: 'Misal: HMD Sistem Informasi, Panitia Wisuda',
          controller: _namaController,
          icon: LucideIcons.building2,
        ),
        const SizedBox(height: Gap.x16),
        Text('Jenis organisasi', style: AppText.bodyMedium),
        const SizedBox(height: Gap.x8),
        Wrap(
          spacing: Gap.x8,
          runSpacing: Gap.x8,
          children: [
            for (final j in const [
              'BEM',
              'HIMA',
              'UKM',
              'Kepanitiaan',
              'Lainnya',
            ])
              PillChip(
                label: j,
                selected: _jenis == j,
                onTap: () => setState(() => _jenis = j),
              ),
          ],
        ),
        const SizedBox(height: Gap.x16),
        LabeledField(
          label: 'Jabatanmu',
          hint: 'Misal: Ketua, Koordinator, Sekretaris',
          controller: _jabatanController,
          icon: LucideIcons.user,
        ),
        const SizedBox(height: Gap.x16),
        LabeledField(
          label: 'Kampus',
          hint: 'Nama kampus / perguruan tinggi',
          controller: _kampusController,
          icon: LucideIcons.school,
        ),
      ],
      cta: FilledButton(
        onPressed: () => _simpan(isTambah),
        child: Text(isTambah ? 'Simpan organisasi' : 'Simpan dan mulai'),
      ),
    );
  }
}
