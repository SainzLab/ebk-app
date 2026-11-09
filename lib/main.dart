import 'package:flutter/material.dart';
import 'core/auth_service.dart';
import 'core/pb_client.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'screens/dashboard/login_screen.dart';
import 'screens/dashboard/dashboard_guru_screen.dart';
import 'screens/dashboard/dashboard_ortu_screen.dart';
import 'screens/dashboard/dashboard_kepsek_screen.dart';
import 'screens/features/kelola_pengguna_screen.dart';
import 'screens/features/data_siswa_screen.dart';
import 'screens/features/kelola_kasus_screen.dart';
import 'screens/features/tambah_kasus_screen.dart';
import 'screens/features/jadwal_konseling_screen.dart';
import 'screens/features/catat_konsultasi_screen.dart';
import 'screens/features/detail_kasus_screen.dart';
import 'screens/features/ajukan_konsultasi_screen.dart';
import 'screens/features/detail_analitik_screen.dart';
import 'screens/states/skeleton_loading.dart';
import 'screens/states/overlay_loading.dart';
import 'screens/states/delete_dialog.dart';
import 'screens/states/session_dialog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PbClient.init();
  await AuthService.instance.tryRefreshSession();
  runApp(const EbkApp());
}

class EbkApp extends StatelessWidget {
  const EbkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-BK SMPN 1 Pabuaran',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: AppTextStyles.fontFamily,
        scaffoldBackgroundColor: AppColors.canvasLightGray,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryNavy,
          primary: AppColors.primaryNavy,
          surface: AppColors.pureWhite,
          error: AppColors.errorPrimary,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: AuthService.instance.initialRoute,
      routes: {
        '/login': (_) => const LoginScreen(),
        '/dashboard-guru': (_) => const DashboardGuruScreen(),
        '/dashboard-ortu': (_) => const DashboardOrtuScreen(),
        '/dashboard-kepsek': (_) => const DashboardKepsekScreen(),
        '/data-siswa': (_) => const DataSiswaScreen(),
        '/kelola-kasus': (_) => const KelolaKasusScreen(),
        '/data-kasus': (_) => const KelolaKasusScreen(),
        '/tambah-kasus': (_) => const TambahKasusScreen(),
        '/jadwal-konseling': (_) => const JadwalKonselingScreen(),
        '/catat-konsultasi': (_) => const CatatKonsultasiScreen(),
        '/kelola-pengguna': (_) => const KelolaPenggunaScreen(),
        '/detail-kasus': (_) => const DetailKasusScreen(),
        '/ajukan-konsultasi': (_) => const AjukanKonsultasiScreen(),
        '/detail-analitik': (_) => const DetailAnalitikScreen(),
        '/skeleton-loading': (_) => const SkeletonLoading(),
        '/overlay-loading': (_) => const OverlayLoadingScreen(),
        '/delete-dialog': (_) => const DeleteDialogScreen(),
        '/session-dialog': (_) => const SessionDialogScreen(),
      },
    );
  }
}
