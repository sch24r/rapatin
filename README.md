# Rapatin

Proyek Mobile Technology 2026.

## Mulai berkontribusi

```bash
git clone https://github.com/sch24r/rapatin.git
cd rapatin
```

1. Selalu `git pull` sebelum mulai bekerja.
2. Buat branch baru untuk setiap fitur: `git checkout -b nama-fitur`.
3. Commit, push branch-nya, lalu buka Pull Request ke `main`.

## Menjalankan aplikasi (Flutter)

Butuh Flutter 3.47+, Android SDK, dan NDK `30.0.16248370` (pasang lewat Android Studio → SDK Manager → SDK Tools → NDK).

```bash
flutter pub get
flutter run
```

Struktur kode:

- `lib/core/theme/`: token warna, spasi, radius, dan text style dari Design System Figma.
- `lib/widgets/`: komponen bersama (kartu, chip, badge status, slip reservasi, bottom nav).
- `lib/features/auth/`: splash, pilih peran, login, daftar, lupa password, profil organisasi.
- `lib/features/penyewa/`: beranda, cari, detail tempat, pilih slot, checkout, QRIS, status booking.
- `lib/features/mitra/`: beranda, booking masuk, jadwal, kelola tempat, promo, pendapatan, laporan.
- `lib/data/`: model dan data contoh (nanti diganti Supabase).

Layar Detail booking punya panel **Simulasi demo** untuk memajukan status (mitra menerima, admin verifikasi, dan seterusnya) saat presentasi, karena backend belum tersambung.
