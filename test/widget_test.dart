import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ebkapp/main.dart';
import 'package:ebkapp/screens/dashboard/dashboard_guru_screen.dart';
import 'package:ebkapp/screens/dashboard/dashboard_ortu_screen.dart';
import 'package:ebkapp/screens/dashboard/dashboard_kepsek_screen.dart';
import 'package:ebkapp/screens/dashboard/profil_view.dart';
import 'package:ebkapp/screens/features/ajukan_konsultasi_screen.dart';
import 'package:ebkapp/screens/features/catat_konsultasi_screen.dart';
import 'package:ebkapp/screens/features/data_siswa_screen.dart';
import 'package:ebkapp/screens/features/detail_analitik_screen.dart';
import 'package:ebkapp/screens/features/detail_kasus_screen.dart';
import 'package:ebkapp/screens/features/jadwal_konseling_screen.dart';
import 'package:ebkapp/screens/features/kelola_kasus_screen.dart';
import 'package:ebkapp/widgets/custom_bottom_nav.dart';
import 'package:ebkapp/widgets/toast_notification.dart';
import 'package:ebkapp/screens/states/delete_dialog.dart';
import 'package:ebkapp/screens/states/session_dialog.dart';
import 'package:ebkapp/widgets/animated_indexed_stack.dart';
import 'package:ebkapp/widgets/profile_avatar.dart';

void main() {
  testWidgets('E-BK Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EbkApp());
    expect(find.text('E-BK SMPN 1 Pabuaran'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Dashboard Guru BK persistent bottom navigation test',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardGuruScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial home screen has bottom navigation
    expect(find.byType(CustomBottomNav), findsOneWidget);

    // Tap Jadwal tab
    await tester.tap(find.text('Jadwal').last);
    await tester.pumpAndSettle();
    expect(find.byType(CustomBottomNav), findsOneWidget);
    expect(find.byType(JadwalKonselingScreen), findsOneWidget);

    // Tap Kasus tab
    await tester.tap(find.text('Kasus').last);
    await tester.pumpAndSettle();
    expect(find.byType(CustomBottomNav), findsOneWidget);
    expect(find.byType(KelolaKasusScreen), findsOneWidget);

    // Tap Profil tab
    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    expect(find.byType(CustomBottomNav), findsOneWidget);
    expect(find.byType(ProfilView), findsOneWidget);

    // Tap Beranda tab
    await tester.tap(find.text('Beranda').last);
    await tester.pumpAndSettle();
    expect(find.byType(CustomBottomNav), findsOneWidget);

    // Tap Data Siswa menu card
    await tester.tap(find.text('Data Siswa').first);
    await tester.pumpAndSettle();
    // Bottom bar MUST still be present!
    expect(find.byType(CustomBottomNav), findsOneWidget);
    expect(find.byType(DataSiswaScreen), findsOneWidget);

    // Tap Konsul Orang Tua menu card directly from bottom bar navigation to return to Beranda
    await tester.tap(find.text('Beranda').last);
    await tester.pumpAndSettle();
    expect(find.byType(CustomBottomNav), findsOneWidget);

    await tester.tap(find.text('Konsul Orang Tua').first);
    await tester.pumpAndSettle();
    expect(find.byType(CustomBottomNav), findsOneWidget);
    expect(find.byType(CatatKonsultasiScreen), findsOneWidget);

    // Tap Kasus tab directly from subview
    await tester.tap(find.text('Kasus').last);
    await tester.pumpAndSettle();
    expect(find.byType(CustomBottomNav), findsOneWidget);
    expect(find.byType(KelolaKasusScreen), findsOneWidget);
  });

  testWidgets('Dashboard Orang Tua persistent bottom navigation test',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardOrtuScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial home screen has bottom navigation
    expect(find.byType(CustomBottomNav), findsOneWidget);

    // Tap Laporan tab
    await tester.tap(find.text('Laporan').last);
    await tester.pumpAndSettle();
    expect(find.byType(CustomBottomNav), findsOneWidget);
    expect(find.byType(DetailKasusScreen), findsOneWidget);

    // Tap Konsultasi tab
    await tester.tap(find.text('Konsultasi').last);
    await tester.pumpAndSettle();
    expect(find.byType(CustomBottomNav), findsOneWidget);
    expect(find.byType(AjukanKonsultasiScreen), findsOneWidget);

    // Tap Profil tab
    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    expect(find.byType(CustomBottomNav), findsOneWidget);
    expect(find.byType(ProfilView), findsOneWidget);

    // Tap Beranda tab
    await tester.tap(find.text('Beranda').last);
    await tester.pumpAndSettle();
    expect(find.byType(CustomBottomNav), findsOneWidget);
  });

  testWidgets('Dashboard Kepala Sekolah persistent bottom navigation test',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardKepsekScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial home screen has bottom navigation
    expect(find.byType(CustomBottomNav), findsOneWidget);

    // Tap Laporan tab
    await tester.tap(find.text('Laporan').last);
    await tester.pumpAndSettle();
    expect(find.byType(CustomBottomNav), findsOneWidget);
    expect(find.byType(DetailAnalitikScreen), findsOneWidget);

    // Tap Siswa tab
    await tester.tap(find.text('Siswa').last);
    await tester.pumpAndSettle();
    expect(find.byType(CustomBottomNav), findsOneWidget);
    expect(find.byType(DataSiswaScreen), findsOneWidget);

    // Tap Profil tab
    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    expect(find.byType(CustomBottomNav), findsOneWidget);
    expect(find.byType(ProfilView), findsOneWidget);

    // Tap Analitik tab
    await tester.tap(find.text('Analitik').last);
    await tester.pumpAndSettle();
    expect(find.byType(CustomBottomNav), findsOneWidget);
  });

  testWidgets('ToastNotification animated entrance and dismiss test',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  ToastNotification.show(
                    context,
                    message: 'Data berhasil disimpan!',
                    type: ToastType.success,
                    duration: const Duration(seconds: 4),
                  );
                },
                child: const Text('Show Toast'),
              );
            },
          ),
        ),
      ),
    );

    // Tap to show toast
    await tester.tap(find.text('Show Toast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Data berhasil disimpan!'), findsOneWidget);
    expect(find.byType(ToastNotification), findsOneWidget);

    // Let entrance animation finish settling
    await tester.pumpAndSettle();

    // Verify close icon can be tapped
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  });

  testWidgets('DeleteDialog animated pop up test',
      (WidgetTester tester) async {
    bool? dialogResult;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  dialogResult = await DeleteDialog.show(
                    context,
                    title: 'Hapus Kasus?',
                    message: 'Kasus ini akan dihapus permanen.',
                  );
                },
                child: const Text('Show Delete Dialog'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Delete Dialog'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    // Verify dialog elements exist in animated state
    expect(find.text('Hapus Kasus?'), findsOneWidget);
    expect(find.text('Kasus ini akan dihapus permanen.'), findsOneWidget);
    expect(find.text('Hapus'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);

    // Settle animation and confirm cancel
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(dialogResult, false);
    expect(find.text('Hapus Kasus?'), findsNothing);
  });

  testWidgets('SessionDialog animated pop up test',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  SessionDialog.show(context);
                },
                child: const Text('Show Session Dialog'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Session Dialog'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Sesi Berakhir'), findsOneWidget);
    expect(find.text('Login Ulang'), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('AnimatedIndexedStack tab switch test',
      (WidgetTester tester) async {
    int activeIndex = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: AnimatedIndexedStack(
                index: activeIndex,
                children: const [
                  Center(child: Text('Tab 1 Konten')),
                  Center(child: Text('Tab 2 Konten')),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  setState(() => activeIndex = 1);
                },
                child: const Icon(Icons.arrow_forward),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Tab 1 Konten'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('Tab 2 Konten'), findsOneWidget);
  });

  testWidgets('ProfileAvatar circular shape and fallback test',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ProfileAvatar(
              size: 50.0,
              fallbackIcon: Icons.school_rounded,
              fallbackInitials: 'NH',
            ),
          ),
        ),
      ),
    );

    expect(find.byType(ProfileAvatar), findsOneWidget);
    expect(find.text('NH'), findsOneWidget);

    // Verify container has circular box shape
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(ProfileAvatar),
        matching: find.byType(Container),
      ).first,
    );
    final boxDecoration = container.decoration as BoxDecoration;
    expect(boxDecoration.shape, BoxShape.circle);
  });

  testWidgets('ProfileAvatar photo edit sheet test in ProfilView',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfilView(role: ProfilRole.guruBk),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify round profile avatar exists with camera badge
    expect(find.byType(ProfileAvatar), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);

    // Tap camera badge to open photo picker sheet
    await tester.tap(find.byIcon(Icons.camera_alt_rounded));
    await tester.pumpAndSettle();

    // Verify bottom sheet appears
    expect(find.text('Ubah Foto Profil'), findsOneWidget);
    expect(find.text('Ambil Foto dari Kamera'), findsOneWidget);
    expect(find.text('Pilih dari Galeri'), findsOneWidget);

    // Choose photo from gallery
    await tester.tap(find.text('Pilih dari Galeri'));
    await tester.pumpAndSettle();

    // Verify toast appears
    expect(find.text('Foto profil berhasil dipilih dari galeri.'), findsOneWidget);
  });
}
