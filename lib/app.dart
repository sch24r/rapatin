import 'dart:ui';

import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/models.dart';
import 'features/auth/auth_screens.dart';
import 'features/auth/splash_screen.dart';
import 'features/bantuan/bantuan_screens.dart';
import 'features/mitra/mitra_booking_screens.dart';
import 'features/mitra/mitra_onboarding_screens.dart';
import 'features/mitra/mitra_shell.dart';
import 'features/mitra/mitra_tempat_screens.dart';
import 'features/mitra/mitra_uang_screens.dart';
import 'features/penyewa/booking_flow_screens.dart';
import 'features/penyewa/edit_profil_screen.dart';
import 'features/penyewa/payment_screens.dart';
import 'features/penyewa/penyewa_shell.dart';
import 'features/penyewa/status_screens.dart';
import 'features/penyewa/venue_screens.dart';

enum Peran { penyewa, mitra }

/// Nama rute aplikasi.
abstract final class Routes {
  static const splash = '/';
  static const peran = '/peran';
  static const login = '/login';
  static const register = '/register';
  static const lupaPassword = '/lupa-password';
  static const profilOrganisasi = '/profil-organisasi';

  static const penyewa = '/penyewa';
  static const detailTempat = '/tempat';
  static const pilihSlot = '/tempat/slot';
  static const checkout = '/checkout';
  static const pembayaran = '/pembayaran';
  static const buktiDitolak = '/pembayaran/ditolak';
  static const detailBooking = '/booking';
  static const notifikasi = '/notifikasi';
  static const rating = '/rating';
  static const editProfil = '/akun/edit';

  /// Argumen: [Peran].
  static const bantuan = '/bantuan';
  static const chatAdmin = '/bantuan/chat';

  static const mitraRegister = '/mitra/daftar';
  static const mitraDataTempat = '/mitra/data-tempat';
  static const mitra = '/mitra';
  static const mitraDetailBooking = '/mitra/booking';
  static const mitraNotifikasi = '/mitra/notifikasi';
  static const mitraEditRuang = '/mitra/ruang';
  static const mitraPromo = '/mitra/promo';
  static const mitraBuatPromo = '/mitra/promo/baru';
  static const mitraPendapatan = '/mitra/pendapatan';
  static const mitraLaporan = '/mitra/laporan';
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return Scrollbar(
      controller: details.controller,
      thumbVisibility: true,
      child: child,
    );
  }
}

class RapatinApp extends StatelessWidget {
  const RapatinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rapatin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      scrollBehavior: const AppScrollBehavior(),
      initialRoute: Routes.splash,
      onGenerateRoute: _route,
    );
  }

  static Route<dynamic> _route(RouteSettings s) {
    final arg = s.arguments;
    final Widget page = switch (s.name) {
      Routes.splash => const SplashScreen(),
      Routes.peran => const PilihPeranScreen(),
      Routes.login => LoginScreen(peran: arg is Peran ? arg : Peran.penyewa),
      Routes.register => const RegisterScreen(),
      Routes.lupaPassword => const LupaPasswordScreen(),
      Routes.profilOrganisasi => const ProfilOrganisasiScreen(),
      Routes.penyewa => PenyewaShell(initialTab: arg is int ? arg : 0),
      Routes.detailTempat => DetailTempatScreen(venue: arg as Venue),
      Routes.pilihSlot => PilihSlotScreen(venue: arg as Venue),
      Routes.checkout => CheckoutScreen(booking: arg as Booking),
      Routes.pembayaran => PembayaranScreen(booking: arg as Booking),
      Routes.buktiDitolak => BuktiDitolakScreen(booking: arg as Booking),
      Routes.detailBooking => DetailBookingScreen(booking: arg as Booking),
      Routes.notifikasi => const NotifikasiScreen(),
      Routes.rating => RatingScreen(booking: arg as Booking),
      Routes.editProfil => const EditProfilScreen(),
      Routes.bantuan => BantuanScreen(
        peran: arg is Peran ? arg : Peran.penyewa,
      ),
      Routes.chatAdmin => ChatAdminScreen(
        peran: arg is Peran ? arg : Peran.penyewa,
      ),
      Routes.mitraRegister => const MitraRegisterScreen(),
      Routes.mitraDataTempat => const MitraDataTempatScreen(),
      Routes.mitra => MitraShell(initialTab: arg is int ? arg : 0),
      Routes.mitraDetailBooking => MitraDetailBookingScreen(
        booking: arg as Booking,
      ),
      Routes.mitraNotifikasi => const MitraNotifikasiScreen(),
      Routes.mitraEditRuang => EditRuangScreen(room: arg as Room?),
      Routes.mitraPromo => const PromoScreen(),
      Routes.mitraBuatPromo => const BuatPromoScreen(),
      Routes.mitraPendapatan => const PendapatanScreen(),
      Routes.mitraLaporan => const LaporanScreen(),
      _ => const PilihPeranScreen(),
    };
    return MaterialPageRoute(builder: (_) => page, settings: s);
  }
}
