import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class Organisasi {
  const Organisasi({
    required this.nama,
    required this.jenis,
    required this.jabatan,
    this.kampus = 'Institut Teknologi Sepuluh Nopember',
  });

  final String nama;
  final String jenis;
  final String jabatan;
  final String kampus;

  String get ringkasan => '$nama · $jabatan';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Organisasi &&
          runtimeType == other.runtimeType &&
          nama == other.nama &&
          jenis == other.jenis &&
          jabatan == other.jabatan &&
          kampus == other.kampus;

  @override
  int get hashCode => Object.hash(nama, jenis, jabatan, kampus);
}

enum Fasilitas {
  privat('Ruang privat'),
  proyektor('Proyektor'),
  colokan('Colokan'),
  wifi('Wi-Fi'),
  whiteboard('Whiteboard'),
  ac('AC');

  const Fasilitas(this.label);
  final String label;
}

class Room {
  const Room({
    required this.nama,
    required this.kapasitasMin,
    required this.kapasitasMaks,
    required this.sewaPerJam,
    required this.minOrderPerOrang,
    required this.foto,
    this.maksJam = 3,
    this.aktif = true,
  });

  final String nama;
  final int kapasitasMin;
  final int kapasitasMaks;
  final int sewaPerJam;
  final int minOrderPerOrang;
  final String foto;
  final int maksJam;
  final bool aktif;

  String get kapasitas => '$kapasitasMin–$kapasitasMaks orang';
}

class MenuPaket {
  const MenuPaket(this.nama, this.deskripsi, this.harga, this.foto);
  final String nama;
  final String deskripsi;
  final int harga;
  final String foto;
}

class Venue {
  const Venue({
    required this.id,
    required this.nama,
    required this.area,
    required this.alamat,
    required this.foto,
    required this.rating,
    required this.ulasan,
    required this.jamBuka,
    required this.jamBukaMulai,
    required this.jamBukaTutup,
    required this.fasilitas,
    required this.rooms,
    required this.menu,
    this.hariLibur = const {},
    this.promo,
    this.slotKosong = 'Slot kosong hari ini',
  });

  final String id;
  final String nama;
  final String area;
  final String alamat;
  final String foto;
  final double rating;
  final int ulasan;
  final String jamBuka;

  /// Jam buka dan tutup (0–24), dipakai filter pencarian.
  final int jamBukaMulai;
  final int jamBukaTutup;

  /// Hari tutup, pakai [DateTime.weekday] (1 = Senin … 7 = Minggu).
  final Set<int> hariLibur;
  final List<Fasilitas> fasilitas;
  final List<Room> rooms;
  final List<MenuPaket> menu;
  final String? promo;
  final String slotKosong;

  int get kapasitasMaks =>
      rooms.map((r) => r.kapasitasMaks).reduce((a, b) => a > b ? a : b);
  int get minOrderTermurah =>
      rooms.map((r) => r.minOrderPerOrang).reduce((a, b) => a < b ? a : b);
}

/// 10 status booking, sama dengan komponen Status badge di Figma.
enum BookingStatus {
  menungguKonfirmasi(
    'Menunggu konfirmasi',
    AppColors.warning,
    AppColors.warningSoft,
  ),
  menungguPembayaran(
    'Menunggu pembayaran',
    AppColors.warning,
    AppColors.warningSoft,
  ),
  menungguVerifikasi(
    'Menunggu verifikasi',
    AppColors.primary,
    AppColors.primarySoft,
  ),
  lunas('Lunas', AppColors.success, AppColors.successSoft),
  selesai('Selesai', AppColors.textMuted, AppColors.neutralSoft),
  ditolak('Ditolak', AppColors.danger, AppColors.dangerSoft),
  kedaluwarsa('Kedaluwarsa', AppColors.textMuted, AppColors.neutralSoft),
  dibatalkan('Dibatalkan', AppColors.danger, AppColors.dangerSoft),
  refundDiproses('Refund diproses', AppColors.warning, AppColors.warningSoft),
  refundSelesai('Refund selesai', AppColors.success, AppColors.successSoft);

  const BookingStatus(this.label, this.fg, this.bg);
  final String label;
  final Color fg;
  final Color bg;
}

class Booking {
  const Booking({
    required this.kode,
    required this.venue,
    required this.room,
    required this.organisasi,
    required this.acara,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.orang,
    required this.status,
    this.catatan,
    this.diskon = 0,
    this.kodeUnik = 427,
  });

  final String kode;
  final Venue venue;
  final Room room;
  final String organisasi;
  final String acara;
  final DateTime tanggal;
  final int jamMulai;
  final int jamSelesai;
  final int orang;
  final BookingStatus status;
  final String? catatan;
  final int diskon;
  final int kodeUnik;

  static const biayaLayanan = 3000;
  static const feeMitra = 20000;

  int get durasi => jamSelesai - jamMulai;
  int get sewa => room.sewaPerJam * durasi;
  int get minOrder => room.minOrderPerOrang * orang;

  /// Yang dibayar penyewa (kode unik mengurangi total).
  int get total => sewa + minOrder - diskon + biayaLayanan - kodeUnik;

  /// Untuk mitra.
  int get kotor => sewa + minOrder - diskon;
  int get bersih => kotor - feeMitra;

  Booking copyWith({BookingStatus? status, String? organisasi}) => Booking(
    kode: kode,
    venue: venue,
    room: room,
    organisasi: organisasi ?? this.organisasi,
    acara: acara,
    tanggal: tanggal,
    jamMulai: jamMulai,
    jamSelesai: jamSelesai,
    orang: orang,
    status: status ?? this.status,
    catatan: catatan,
    diskon: diskon,
    kodeUnik: kodeUnik,
  );
}

class Notif {
  const Notif(
    this.icon,
    this.judul,
    this.isi,
    this.waktu, {
    this.baru = false,
    this.tone,
  });
  final IconData icon;
  final String judul;
  final String isi;
  final String waktu;
  final bool baru;
  final Color? tone;
}
