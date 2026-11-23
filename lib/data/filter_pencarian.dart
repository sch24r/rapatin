import 'dummy_data.dart';
import 'models.dart';

/// Rentang waktu rapat di sheet Filter. [selesai] eksklusif.
enum WaktuRapat {
  pagi('Pagi', 8, 11),
  siang('Siang', 11, 14),
  sore('Sore · promo', 14, 17),
  malam('Malam', 18, 21);

  const WaktuRapat(this.label, this.mulai, this.selesai);
  final String label;
  final int mulai;
  final int selesai;

  String get rentang =>
      '${mulai.toString().padLeft(2, '0')}.00–${selesai.toString().padLeft(2, '0')}.00';
}

/// Kriteria pencarian tempat rapat milik Penyewa.
class FilterPencarian {
  const FilterPencarian({
    required this.orang,
    required this.tanggal,
    this.waktu,
    this.minOrderMin = batasBawahOrder,
    this.minOrderMaks = batasAtasOrder,
    this.fasilitas = const {},
  });

  static const batasBawahOrder = 10000;
  static const batasAtasOrder = 60000;

  /// Minimal 2 jam rapat harus muat di dalam jam buka tempat.
  static const minimalJam = 2;

  final int orang;
  final DateTime tanggal;

  /// `null` berarti semua jam.
  final WaktuRapat? waktu;
  final int minOrderMin;
  final int minOrderMaks;
  final Set<Fasilitas> fasilitas;

  static final awal = FilterPencarian(
    orang: 25,
    tanggal: tanggalAcara,
    waktu: WaktuRapat.malam,
  );

  bool get budgetDibatasi =>
      minOrderMin > batasBawahOrder || minOrderMaks < batasAtasOrder;

  /// Jumlah filter di luar orang/tanggal/jam, untuk badge tombol Filter.
  int get jumlahTambahan => fasilitas.length + (budgetDibatasi ? 1 : 0);

  FilterPencarian copyWith({
    int? orang,
    DateTime? tanggal,
    WaktuRapat? waktu,
    bool hapusWaktu = false,
    int? minOrderMin,
    int? minOrderMaks,
    Set<Fasilitas>? fasilitas,
  }) => FilterPencarian(
    orang: orang ?? this.orang,
    tanggal: tanggal ?? this.tanggal,
    waktu: hapusWaktu ? null : (waktu ?? this.waktu),
    minOrderMin: minOrderMin ?? this.minOrderMin,
    minOrderMaks: minOrderMaks ?? this.minOrderMaks,
    fasilitas: fasilitas ?? this.fasilitas,
  );

  /// Ruang yang muat untuk [orang] dan min. order-nya masuk budget.
  bool _ruangCocok(Room r) =>
      r.aktif &&
      orang >= r.kapasitasMin &&
      orang <= r.kapasitasMaks &&
      r.minOrderPerOrang >= minOrderMin &&
      r.minOrderPerOrang <= minOrderMaks;

  bool _buka(Venue v) {
    if (v.hariLibur.contains(tanggal.weekday)) return false;
    final w = waktu;
    if (w == null) return true;
    final mulai = w.mulai > v.jamBukaMulai ? w.mulai : v.jamBukaMulai;
    final selesai = w.selesai < v.jamBukaTutup ? w.selesai : v.jamBukaTutup;
    return selesai - mulai >= minimalJam;
  }

  bool cocok(Venue v) =>
      _buka(v) &&
      fasilitas.every(v.fasilitas.contains) &&
      v.rooms.any(_ruangCocok);

  List<Venue> saring(Iterable<Venue> venues) => venues.where(cocok).toList();
}
