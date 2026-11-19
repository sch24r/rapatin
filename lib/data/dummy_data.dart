import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import 'models.dart';

/// Data contoh untuk tahap UI. Nanti diganti data dari Supabase.
abstract final class Img {
  static const restoVip = 'assets/images/resto_vip.jpg';
  static const kafeRotan = 'assets/images/kafe_rotan.jpg';
  static const ruangKaca = 'assets/images/ruang_kaca.jpg';
  static const kantinKampus = 'assets/images/kantin_kampus.jpg';
  static const ayamBakar = 'assets/images/menu_ayam_bakar.jpg';
  static const nasiGoreng = 'assets/images/menu_nasi_goreng.jpg';
}

const _menuUmum = [
  MenuPaket(
    'Paket Rapat A',
    'Nasi ayam bakar, sambal, es teh',
    35000,
    Img.ayamBakar,
  ),
  MenuPaket(
    'Paket Rapat B',
    'Nasi goreng, kerupuk, kopi/teh',
    30000,
    Img.nasiGoreng,
  ),
];

const kingKong = Venue(
  id: 'kingkong',
  nama: 'King Kong Resto',
  area: 'Gubeng',
  alamat: 'Jl. Raya Gubeng No. 12, Surabaya',
  foto: Img.restoVip,
  rating: 4.8,
  ulasan: 32,
  jamBuka: 'Buka setiap hari · 10.00–22.00',
  fasilitas: [
    Fasilitas.privat,
    Fasilitas.proyektor,
    Fasilitas.colokan,
    Fasilitas.wifi,
  ],
  promo: '14.00–17.00 −10%',
  rooms: [
    Room(
      nama: 'Reguler',
      kapasitasMin: 10,
      kapasitasMaks: 20,
      sewaPerJam: 0,
      minOrderPerOrang: 30000,
      foto: Img.kafeRotan,
      maksJam: 2,
    ),
    Room(
      nama: 'VIP',
      kapasitasMin: 10,
      kapasitasMaks: 40,
      sewaPerJam: 75000,
      minOrderPerOrang: 35000,
      foto: Img.restoVip,
    ),
    Room(
      nama: 'Privat',
      kapasitasMin: 6,
      kapasitasMaks: 12,
      sewaPerJam: 50000,
      minOrderPerOrang: 40000,
      foto: Img.ruangKaca,
    ),
  ],
  menu: _menuUmum,
);

const kopiRotan = Venue(
  id: 'rotan',
  nama: 'Kopi Rotan Keputih',
  area: 'Keputih',
  alamat: 'Jl. Keputih Tegal No. 8, Surabaya',
  foto: Img.kafeRotan,
  rating: 4.7,
  ulasan: 51,
  jamBuka: 'Buka setiap hari · 08.00–23.00',
  fasilitas: [Fasilitas.colokan, Fasilitas.wifi, Fasilitas.whiteboard],
  promo: '13.00–16.00 −15%',
  rooms: [
    Room(
      nama: 'Area Semi-privat',
      kapasitasMin: 8,
      kapasitasMaks: 24,
      sewaPerJam: 0,
      minOrderPerOrang: 25000,
      foto: Img.kafeRotan,
    ),
  ],
  menu: _menuUmum,
);

const terasKaca = Venue(
  id: 'kaca',
  nama: 'Teras Kaca Coffee',
  area: 'Sukolilo',
  alamat: 'Jl. Arief Rahman Hakim No. 31, Surabaya',
  foto: Img.ruangKaca,
  rating: 4.9,
  ulasan: 18,
  jamBuka: 'Sen–Sab · 09.00–21.00',
  fasilitas: [
    Fasilitas.privat,
    Fasilitas.proyektor,
    Fasilitas.ac,
    Fasilitas.wifi,
  ],
  rooms: [
    Room(
      nama: 'Ruang Kaca',
      kapasitasMin: 6,
      kapasitasMaks: 14,
      sewaPerJam: 60000,
      minOrderPerOrang: 30000,
      foto: Img.ruangKaca,
    ),
  ],
  menu: _menuUmum,
  slotKosong: '3 slot kosong besok',
);

const warungSinar = Venue(
  id: 'sinar',
  nama: 'Warung Sinar Kampus',
  area: 'Mulyosari',
  alamat: 'Jl. Mulyosari No. 140, Surabaya',
  foto: Img.kantinKampus,
  rating: 4.5,
  ulasan: 64,
  jamBuka: 'Buka setiap hari · 07.00–22.00',
  fasilitas: [Fasilitas.whiteboard, Fasilitas.colokan],
  promo: '15.00–18.00 −10%',
  rooms: [
    Room(
      nama: 'Lantai 2',
      kapasitasMin: 15,
      kapasitasMaks: 60,
      sewaPerJam: 0,
      minOrderPerOrang: 20000,
      foto: Img.kantinKampus,
    ),
  ],
  menu: _menuUmum,
);

const semuaVenue = [kingKong, kopiRotan, terasKaca, warungSinar];

final tanggalAcara = DateTime(2026, 11, 21);

/// Booking utama di semua layar: RPT-0427.
final bookingUtama = Booking(
  kode: 'RPT-0427',
  venue: kingKong,
  room: kingKong.rooms[1],
  organisasi: 'BEM Fakultas Teknik',
  acara: 'Rapat Koordinasi Dies Natalis',
  tanggal: tanggalAcara,
  jamMulai: 19,
  jamSelesai: 21,
  orang: 25,
  status: BookingStatus.lunas,
  catatan:
      'Butuh proyektor dan 2 colokan tambahan. Datang 15 menit lebih awal.',
);

final bookingPenyewa = <Booking>[
  bookingUtama,
  Booking(
    kode: 'RPT-0431',
    venue: kopiRotan,
    room: kopiRotan.rooms.first,
    organisasi: 'BEM Fakultas Teknik',
    acara: 'Evaluasi Proker Kominfo',
    tanggal: DateTime(2026, 11, 28),
    jamMulai: 14,
    jamSelesai: 16,
    orang: 12,
    status: BookingStatus.menungguKonfirmasi,
    kodeUnik: 431,
  ),
];

final riwayatPenyewa = <Booking>[
  Booking(
    kode: 'RPT-0388',
    venue: terasKaca,
    room: terasKaca.rooms.first,
    organisasi: 'BEM Fakultas Teknik',
    acara: 'Rapat Pleno Panitia',
    tanggal: DateTime(2026, 11, 7),
    jamMulai: 16,
    jamSelesai: 18,
    orang: 10,
    status: BookingStatus.selesai,
    kodeUnik: 388,
  ),
  Booking(
    kode: 'RPT-0352',
    venue: warungSinar,
    room: warungSinar.rooms.first,
    organisasi: 'BEM Fakultas Teknik',
    acara: 'Open Recruitment Staf',
    tanggal: DateTime(2026, 10, 24),
    jamMulai: 13,
    jamSelesai: 15,
    orang: 30,
    status: BookingStatus.refundSelesai,
    kodeUnik: 352,
  ),
];

/// Booking yang masuk ke King Kong Resto (sisi Mitra).
final bookingMitra = <Booking>[
  bookingUtama.copyWith(status: BookingStatus.menungguKonfirmasi),
  Booking(
    kode: 'RPT-0433',
    venue: kingKong,
    room: kingKong.rooms[0],
    organisasi: 'HIMA Informatika',
    acara: 'Rapat Panitia Schematics',
    tanggal: DateTime(2026, 11, 22),
    jamMulai: 15,
    jamSelesai: 17,
    orang: 14,
    status: BookingStatus.menungguKonfirmasi,
    kodeUnik: 433,
    catatan: 'Mohon meja disusun bentuk U.',
  ),
  Booking(
    kode: 'RPT-0415',
    venue: kingKong,
    room: kingKong.rooms[2],
    organisasi: 'UKM Fotografi',
    acara: 'Kurasi Pameran',
    tanggal: DateTime(2026, 11, 20),
    jamMulai: 18,
    jamSelesai: 20,
    orang: 10,
    status: BookingStatus.lunas,
    kodeUnik: 415,
  ),
  Booking(
    kode: 'RPT-0409',
    venue: kingKong,
    room: kingKong.rooms[1],
    organisasi: 'Himatika ITS',
    acara: 'Rapat Kerja Pengurus',
    tanggal: DateTime(2026, 11, 23),
    jamMulai: 10,
    jamSelesai: 12,
    orang: 20,
    status: BookingStatus.menungguPembayaran,
    kodeUnik: 409,
  ),
  Booking(
    kode: 'RPT-0390',
    venue: kingKong,
    room: kingKong.rooms[1],
    organisasi: 'BEM Fakultas Teknik',
    acara: 'Rapat Pleno',
    tanggal: DateTime(2026, 11, 8),
    jamMulai: 19,
    jamSelesai: 21,
    orang: 22,
    status: BookingStatus.selesai,
    kodeUnik: 390,
  ),
];

const notifPenyewa = [
  Notif(
    LucideIcons.circleCheck,
    'Pembayaran terverifikasi',
    'RPT-0427 di King Kong Resto sudah lunas. Slip reservasi siap dibagikan.',
    '5 mnt',
    baru: true,
    tone: AppColors.success,
  ),
  Notif(
    LucideIcons.clock,
    'Masa pembatalan tinggal 6 jam',
    'Setelah itu booking RPT-0427 menjadi final dan tidak bisa dibatalkan.',
    '1 jam',
    baru: true,
    tone: AppColors.warning,
  ),
  Notif(
    LucideIcons.ticket,
    'Booking dikonfirmasi mitra',
    'King Kong Resto menerima booking kamu. Selesaikan pembayaran dalam 24 jam.',
    'Kemarin',
  ),
  Notif(
    LucideIcons.tag,
    'Promo jam sepi',
    'Kopi Rotan Keputih diskon 15% untuk rapat jam 13.00–16.00.',
    '2 hari',
  ),
  Notif(
    LucideIcons.star,
    'Bagaimana rapatnya?',
    'Beri rating untuk Teras Kaca Coffee agar panitia lain terbantu.',
    '7 Nov',
  ),
];

const notifMitra = [
  Notif(
    LucideIcons.ticket,
    'Booking baru masuk',
    'HIMA Informatika · 14 orang · Min, 22 Nov 15.00–17.00. Balas dalam 15 menit.',
    '2 mnt',
    baru: true,
    tone: AppColors.warning,
  ),
  Notif(
    LucideIcons.circleCheck,
    'Pembayaran diverifikasi',
    'RPT-0415 UKM Fotografi sudah lunas. Siapkan Ruang Privat.',
    '3 jam',
    baru: true,
    tone: AppColors.success,
  ),
  Notif(
    LucideIcons.wallet,
    'Dana siap dicairkan',
    'Rp1.005.000 dari RPT-0398 akan masuk ke BCA ••4821.',
    'Kemarin',
  ),
  Notif(
    LucideIcons.star,
    'Ulasan baru ★5',
    '"Tempatnya nyaman, proyektor siap pakai." — BEM FT',
    '2 hari',
  ),
];
