import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app.dart';
import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../widgets/common.dart';

// ───────────────────────── Data bantuan ─────────────────────────

typedef _Faq = (String tanya, String jawab);

const _faqPenyewa = <_Faq>[
  (
    'Bagaimana cara membayar booking?',
    'Setelah mitra menerima booking, bayar penuh lewat QRIS Rapatin dalam 24 jam. Transfer nominal sampai 3 digit terakhir, lalu unggah bukti transfer di layar Pembayaran.',
  ),
  (
    'Kenapa nominalnya ada 3 digit unik?',
    'Kode unik membantu admin mencocokkan transfermu dengan booking. Kode ini mengurangi total, jadi kamu tidak membayar lebih.',
  ),
  (
    'Berapa lama verifikasi bukti bayar?',
    'Admin mencocokkan nominal dan kode unik paling lama 1×24 jam. Status berubah jadi Lunas setelah terverifikasi.',
  ),
  (
    'Bukti bayar saya ditolak, harus apa?',
    'Biasanya karena nominal tidak sesuai. Transfer kekurangannya atau ulangi dengan nominal sampai 3 digit terakhir, lalu unggah bukti baru.',
  ),
  (
    'Bisakah saya membatalkan booking?',
    'Bisa, dalam 2×24 jam sejak lunas dan paling lambat 24 jam sebelum acara. Dana kembali penuh kecuali biaya layanan Rp3.000. Lewat masa itu, booking menjadi final.',
  ),
  (
    'Bagaimana mengganti organisasi?',
    'Buka Akun → Organisasi, lalu pilih atau tambah organisasi. Organisasi aktif dipakai untuk booking berikutnya.',
  ),
];

const _faqMitra = <_Faq>[
  (
    'Berapa lama saya harus membalas booking masuk?',
    'Usahakan membalas dalam 15 menit. Penyewa baru bisa membayar setelah kamu menerima booking.',
  ),
  (
    'Kapan dana booking dicairkan?',
    'Setelah masa pembatalan penyewa berakhir dan booking menjadi final, dana diteruskan ke rekening pencairanmu dalam 2×24 jam.',
  ),
  (
    'Berapa potongan dari Rapatin?',
    'Fee flat Rp20.000 per booking, dipotong dari pendapatan kotor (sewa ruang + minimum order).',
  ),
  (
    'Bagaimana menutup jam yang tidak tersedia?',
    'Buka tab Jadwal, lalu pakai Blokir slot agar jam itu tidak bisa dipesan penyewa.',
  ),
  (
    'Bagaimana mengubah rekening pencairan?',
    'Buka Akun → Rekening pencairan, lalu perbarui data bank atau e-wallet.',
  ),
];

const _saranPenyewa = [
  'Bukti bayar belum diverifikasi',
  'Cara membatalkan booking',
  'Mitra belum membalas',
];

const _saranMitra = [
  'Dana belum masuk',
  'Ubah rekening pencairan',
  'Penyewa tidak datang',
];

class _Pesan {
  _Pesan(this.teks, {required this.dariSaya}) : waktu = DateTime.now();
  final String teks;
  final bool dariSaya;
  final DateTime waktu;
}

/// Riwayat chat per peran, bertahan selama aplikasi berjalan.
final _riwayat = {
  for (final p in Peran.values)
    p: ValueNotifier<List<_Pesan>>([
      _Pesan(
        'Halo, ada yang bisa kami bantu? Ceritakan kendalamu, sertakan kode booking bila ada.',
        dariSaya: false,
      ),
    ]),
};

// ───────────────────────── Pusat bantuan ─────────────────────────

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key, required this.peran});
  final Peran peran;

  @override
  Widget build(BuildContext context) {
    final faq = peran == Peran.mitra ? _faqMitra : _faqPenyewa;
    return Scaffold(
      appBar: const TopBar(title: 'Bantuan'),
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
                const IconBox(
                  LucideIcons.messageCircle,
                  bg: AppColors.accent,
                  fg: AppColors.text,
                ),
                const SizedBox(height: Gap.x12),
                Text(
                  'Chat admin Rapatin',
                  style: AppText.h2.tint(Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  peran == Peran.mitra
                      ? 'Tanya soal booking masuk, pencairan dana, atau data tempat.'
                      : 'Tanya soal pembayaran, verifikasi, refund, atau booking.',
                  style: AppText.body.tint(AppColors.primarySoft),
                ),
                const SizedBox(height: Gap.x16),
                FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    Routes.chatAdmin,
                    arguments: peran,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.card,
                    foregroundColor: AppColors.primary,
                  ),
                  icon: const Icon(LucideIcons.send, size: 18),
                  label: const Text('Mulai chat'),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.x24),
          Text('Pertanyaan umum', style: AppText.h2),
          const SizedBox(height: Gap.x12),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < faq.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: AppColors.border),
                  _FaqTile(tanya: faq[i].$1, jawab: faq[i].$2),
                ],
              ],
            ),
          ),
          const SizedBox(height: Gap.x16),
          Text(
            'Jawabanmu belum ada di sini? Chat admin, kami bantu langsung.',
            style: AppText.caption.copyWith(fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.tanya, required this.jawab});
  final String tanya;
  final String jawab;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: Gap.x16),
        childrenPadding: const EdgeInsets.fromLTRB(
          Gap.x16,
          0,
          Gap.x16,
          Gap.x16,
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textMuted,
        title: Text(tanya, style: AppText.bodyMedium.semi),
        children: [Text(jawab, style: AppText.body.muted)],
      ),
    );
  }
}

// ───────────────────────── Chat admin ─────────────────────────

class ChatAdminScreen extends StatefulWidget {
  const ChatAdminScreen({super.key, required this.peran});
  final Peran peran;

  @override
  State<ChatAdminScreen> createState() => _ChatAdminScreenState();
}

class _ChatAdminScreenState extends State<ChatAdminScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  Timer? _balas;
  bool _mengetik = false;

  ValueNotifier<List<_Pesan>> get _pesan => _riwayat[widget.peran]!;

  @override
  void dispose() {
    _balas?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _gulirKeBawah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _kirim([String? teks]) {
    final t = (teks ?? _input.text).trim();
    if (t.isEmpty) return;
    _input.clear();
    _pesan.value = [..._pesan.value, _Pesan(t, dariSaya: true)];
    setState(() => _mengetik = true);
    _gulirKeBawah();

    // Simulasi balasan admin sampai backend chat (Supabase Realtime) tersambung.
    _balas?.cancel();
    _balas = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      _pesan.value = [
        ..._pesan.value,
        _Pesan(
          'Terima kasih, pesanmu sudah kami terima. Admin Rapatin akan membalas di chat ini.',
          dariSaya: false,
        ),
      ];
      setState(() => _mengetik = false);
      _gulirKeBawah();
    });
  }

  @override
  Widget build(BuildContext context) {
    final saran = widget.peran == Peran.mitra ? _saranMitra : _saranPenyewa;
    return Scaffold(
      appBar: const TopBar(title: 'Chat admin'),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<List<_Pesan>>(
              valueListenable: _pesan,
              builder: (context, daftar, _) => ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(
                  Gap.x16,
                  0,
                  Gap.x16,
                  Gap.x16,
                ),
                children: [
                  const InfoBanner(
                    tone: BannerTone.warning,
                    title: 'Simulasi demo',
                    message: 'Balasan admin masih otomatis karena backend chat belum tersambung.',
                  ),
                  const SizedBox(height: Gap.x16),
                  for (final p in daftar) _Gelembung(pesan: p),
                  if (_mengetik)
                    Padding(
                      padding: const EdgeInsets.only(top: Gap.x8),
                      child: Text(
                        'Admin sedang mengetik…',
                        style: AppText.caption,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Scrollbar memakai padding sistem (gesture bar) dari MediaQuery,
          // jadi tanpa removePadding ia naik dan menimpa chip.
          MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(Gap.x16, 0, Gap.x16, Gap.x12),
              child: Row(
                children: [
                  for (final s in saran)
                    Padding(
                      padding: const EdgeInsets.only(right: Gap.x8),
                      child: ActionChip(
                        onPressed: () => _kirim(s),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        label: Text(s, style: AppText.label),
                        backgroundColor: AppColors.surfaceMuted,
                        side: BorderSide.none,
                        shape: const StadiumBorder(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.card,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Gap.x16,
                  Gap.x8,
                  Gap.x8,
                  Gap.x8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _kirim(),
                        decoration: InputDecoration(
                          hintText: 'Tulis pesan…',
                          fillColor: AppColors.surfaceMuted,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: Radii.mdAll,
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Gap.x8),
                    IconButton.filled(
                      tooltip: 'Kirim',
                      onPressed: () => _kirim(),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(48, 48),
                      ),
                      icon: const Icon(LucideIcons.send, size: 20),
                    ),
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

class _Gelembung extends StatelessWidget {
  const _Gelembung({required this.pesan});
  final _Pesan pesan;

  @override
  Widget build(BuildContext context) {
    final saya = pesan.dariSaya;
    final w = pesan.waktu;
    return Align(
      alignment: saya ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: Gap.x8),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          decoration: BoxDecoration(
            color: saya ? AppColors.primary : AppColors.card,
            border: saya ? null : Border.all(color: AppColors.border),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(Radii.md),
              topRight: const Radius.circular(Radii.md),
              bottomLeft: Radius.circular(saya ? Radii.md : 4),
              bottomRight: Radius.circular(saya ? 4 : Radii.md),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  pesan.teks,
                  style: AppText.body.tint(
                    saya ? AppColors.onPrimary : AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                jamMenit(w),
                style: AppText.caption.copyWith(
                  fontSize: 11,
                  color: saya ? AppColors.primarySoft : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
