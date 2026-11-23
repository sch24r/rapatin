import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/dummy_data.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';

/// 20b · Edit profil Penyewa: nama, email, nomor HP, kampus.
class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  late final ProfilPengguna _awal = profilPenyewa.value;
  late final _nama = TextEditingController(text: _awal.nama);
  late final _email = TextEditingController(text: _awal.email);
  late final _hp = TextEditingController(text: _awal.hp);
  late final _kampus = TextEditingController(text: _awal.kampus);

  /// Galat baru ditampilkan setelah user mencoba menyimpan.
  bool _sudahCoba = false;

  @override
  void dispose() {
    for (final c in [_nama, _email, _hp, _kampus]) {
      c.dispose();
    }
    super.dispose();
  }

  ProfilPengguna get _draf => ProfilPengguna(
    nama: _nama.text.trim().replaceAll(RegExp(r'\s+'), ' '),
    email: _email.text.trim().toLowerCase(),
    hp: _hp.text.replaceAll(RegExp(r'[\s-]'), ''),
    kampus: _kampus.text.trim(),
  );

  bool get _berubah {
    final d = _draf;
    return d.nama != _awal.nama ||
        d.email != _awal.email ||
        d.hp != _awal.hp ||
        d.kampus != _awal.kampus;
  }

  static final _polaEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _polaHp = RegExp(r'^(\+62|62|0)8\d{7,11}$');

  String? get _galatNama {
    final n = _draf.nama;
    if (n.isEmpty) return 'Nama wajib diisi';
    if (n.length < 3) return 'Nama terlalu pendek';
    return null;
  }

  String? get _galatEmail {
    final e = _draf.email;
    if (e.isEmpty) return 'Email wajib diisi';
    if (!_polaEmail.hasMatch(e)) return 'Format email belum benar';
    return null;
  }

  String? get _galatHp {
    final h = _draf.hp;
    if (h.isEmpty) return 'Nomor HP wajib diisi';
    if (!_polaHp.hasMatch(h)) {
      return 'Pakai nomor HP Indonesia, mis. 0812xxxxxxx';
    }
    return null;
  }

  String? get _galatKampus =>
      _draf.kampus.isEmpty ? 'Kampus wajib diisi' : null;

  bool get _valid =>
      _galatNama == null &&
      _galatEmail == null &&
      _galatHp == null &&
      _galatKampus == null;

  void _simpan() {
    FocusScope.of(context).unfocus();
    if (!_valid) {
      setState(() => _sudahCoba = true);
      return;
    }
    profilPenyewa.value = _draf;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Profil disimpan')));
    Navigator.pop(context);
  }

  Future<bool> _bolehKeluar() async {
    if (!_berubah) return true;
    final buang = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Buang perubahan?', style: AppText.h2),
        content: Text(
          'Perubahan profil yang belum disimpan akan hilang.',
          style: AppText.body.muted,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Lanjut edit'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Buang'),
          ),
        ],
      ),
    );
    return buang ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final d = _draf;
    return PopScope(
      canPop: !_berubah,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        if (await _bolehKeluar() && mounted) nav.pop();
      },
      child: Scaffold(
        appBar: const TopBar(title: 'Edit profil'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(Gap.x16, 0, Gap.x16, Gap.x24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primarySoft,
                child: Text(
                  d.nama.isEmpty ? '?' : d.inisial,
                  style: AppText.h1.tint(AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: Gap.x24),
            LabeledField(
              label: 'Nama lengkap',
              hint: 'Nama sesuai KTM',
              icon: LucideIcons.user,
              controller: _nama,
              errorText: _sudahCoba ? _galatNama : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: Gap.x16),
            LabeledField(
              label: 'Email',
              hint: 'nama@student.its.ac.id',
              icon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress,
              controller: _email,
              errorText: _sudahCoba ? _galatEmail : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: Gap.x16),
            LabeledField(
              label: 'Nomor HP (WhatsApp)',
              hint: '08xx xxxx xxxx',
              icon: LucideIcons.phone,
              keyboardType: TextInputType.phone,
              controller: _hp,
              errorText: _sudahCoba ? _galatHp : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: Gap.x16),
            LabeledField(
              label: 'Kampus',
              hint: 'Institut Teknologi Sepuluh Nopember',
              icon: LucideIcons.school,
              controller: _kampus,
              errorText: _sudahCoba ? _galatKampus : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: Gap.x16),
            const InfoBanner(
              message: 'Nomor HP dipakai mitra untuk menghubungi PIC saat hari acara.',
            ),
          ],
        ),
        bottomNavigationBar: BottomActionBar(
          child: FilledButton(
            onPressed: _berubah ? _simpan : null,
            child: const Text('Simpan perubahan'),
          ),
        ),
      ),
    );
  }
}
