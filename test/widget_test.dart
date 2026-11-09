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

  testWidgets(
      'DataSiswaScreen read-only mode for Kepala Sekolah (no add, edit, or delete)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: DataSiswaScreen(
          role: ProfilRole.kepalaSekolah,
          isReadOnly: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify title is present without unnecessary notice banners/badges
    expect(find.text('Data Siswa'), findsOneWidget);
    expect(find.text('Hanya Lihat • Kepala Sekolah'), findsNothing);
    expect(
      find.text(
          'Akun Kepala Sekolah memiliki hak akses melihat data siswa tanpa opsi tambah, ubah, atau hapus.'),
      findsNothing,
    );

    // 2. Verify FAB (+) Tambah Siswa is NOT present
    expect(find.byIcon(Icons.add_rounded), findsNothing);

    // 3. Verify student card can be tapped to view details
    expect(find.text('Rizky Pratama'), findsOneWidget);
    await tester.tap(find.text('Rizky Pratama'));
    await tester.pumpAndSettle();

    // 4. Verify detail modal sheet shows details without notice banner and without edit/delete buttons
    expect(find.text('NIS / NISN'), findsOneWidget);
    expect(find.text('242509042 / 0094821034'), findsOneWidget);
    expect(find.text('Bapak Hendra Pratama (Ayah Kandung)'), findsOneWidget);
    expect(
      find.text(
          'Mode Lihat Saja: Role Kepala Sekolah tidak memiliki izin mengubah atau menghapus data siswa.'),
      findsNothing,
    );

    // Edit and Delete buttons MUST NOT exist
    expect(find.text('Edit Data'), findsNothing);
    expect(find.text('Hapus Siswa'), findsNothing);

    // Close button MUST exist
    expect(find.text('Tutup Detail Siswa'), findsOneWidget);
    await tester.tap(find.text('Tutup Detail Siswa'));
    await tester.pumpAndSettle();

    // 5. Verify long-press on student card does NOT open delete dialog
    await tester.longPress(find.text('Rizky Pratama'));
    await tester.pumpAndSettle();
    expect(find.text('Hapus Data Siswa?'), findsNothing);
  });

  testWidgets(
      'DataSiswaScreen full CRUD access for Guru BK (can add, edit, and delete)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: DataSiswaScreen(
          role: ProfilRole.guruBk,
          isReadOnly: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify FAB (+) Tambah Siswa IS present
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    // 2. Verify student card can be tapped to view details
    await tester.tap(find.text('Rizky Pratama'));
    await tester.pumpAndSettle();

    // 3. Verify detail modal sheet shows Edit and Delete buttons for Guru BK
    expect(find.text('Edit Data'), findsOneWidget);
    expect(find.text('Hapus Siswa'), findsOneWidget);
    expect(find.text('Tutup Detail Siswa'), findsNothing);
  });

  testWidgets(
      'DetailKasusScreen read-only mode for Kepala Sekolah (no edit, complete, or delete buttons)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: DetailKasusScreen(
          role: ProfilRole.kepalaSekolah,
          isReadOnly: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Top Bar title is present without read-only notice badge
    expect(find.text('Detail Kasus'), findsOneWidget);
    expect(find.text('Hanya Lihat • Kepala Sekolah'), findsNothing);

    // 2. Verify case information is displayed properly
    expect(find.text('Membolos Sekolah saat Jam Efektif'), findsOneWidget);
    expect(find.text('Catatan Penanganan Guru BK'), findsOneWidget);

    // 3. Verify read-only notice banner is NOT present
    expect(
      find.text(
          'Mode Lihat Saja: Role Kepala Sekolah tidak memiliki akses untuk mengubah status (selesai), mengedit, atau menghapus riwayat kasus.'),
      findsNothing,
    );

    // 4. Verify Edit, Tandai Selesai / Buka Kembali, and Hapus buttons DO NOT exist
    expect(find.text('Edit Kasus'), findsNothing);
    expect(find.text('Tandai Selesai'), findsNothing);
    expect(find.text('Buka Kembali'), findsNothing);
    expect(find.text('Hapus Catatan Kasus'), findsNothing);

    // 5. Verify Kembali button is present
    expect(find.text('Kembali'), findsOneWidget);
  });

  testWidgets(
      'DetailKasusScreen full action mode for Guru BK (has edit, complete, and delete buttons)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: DetailKasusScreen(
          role: ProfilRole.guruBk,
          isReadOnly: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Guru BK can see all 3 action buttons
    expect(find.text('Edit Kasus'), findsOneWidget);
    expect(find.text('Tandai Selesai'), findsOneWidget);
    expect(find.text('Hapus Catatan Kasus'), findsOneWidget);

    // 2. Read-only banner and badge MUST NOT be present
    expect(find.text('Hanya Lihat • Kepala Sekolah'), findsNothing);
    expect(find.text('Kembali'), findsNothing);
  });

  testWidgets(
      'DataSiswaScreen to DetailKasusScreen navigation preserves read-only mode for Kepala Sekolah',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/data-siswa',
        routes: {
          '/data-siswa': (_) => const DataSiswaScreen(
                role: ProfilRole.kepalaSekolah,
                isReadOnly: true,
              ),
          '/detail-kasus': (_) => const DetailKasusScreen(),
        },
      ),
    );
    await tester.pumpAndSettle();

    // Tap on Dimas Aditya Saputra
    await tester.tap(find.text('Dimas Aditya Saputra'));
    await tester.pumpAndSettle();

    // Tap on "Lihat Riwayat Kasus & Catatan BK Siswa"
    await tester.tap(find.text('Lihat Riwayat Kasus & Catatan BK Siswa'));
    await tester.pumpAndSettle();

    // Verify Detail Kasus screen opened in read-only mode (no edit/complete/delete)
    expect(find.text('Detail Kasus'), findsOneWidget);
    expect(find.text('Hanya Lihat • Kepala Sekolah'), findsNothing);
    expect(find.text('Edit Kasus'), findsNothing);
    expect(find.text('Tandai Selesai'), findsNothing);
    expect(find.text('Hapus Catatan Kasus'), findsNothing);
    expect(find.text('Kembali'), findsOneWidget);
  });

  testWidgets(
      'JadwalKonselingScreen calendar card supports changing week, month, date, and year',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: JadwalKonselingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Initial display shows November 2026
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('Lihat Semua Hari'), findsOneWidget);

    // 2. Test week navigation (Minggu Berikutnya)
    final nextWeekButton = find.byTooltip('Minggu Berikutnya');
    expect(nextWeekButton, findsOneWidget);
    await tester.tap(nextWeekButton);
    await tester.pumpAndSettle();

    // 3. Test Month & Year picker bottom sheet
    final monthYearButton = find.byTooltip('Pilih Bulan & Tahun');
    expect(monthYearButton, findsOneWidget);
    await tester.tap(monthYearButton);
    await tester.pumpAndSettle();

    // Verify sheet opened
    expect(find.text('Pilih Bulan & Tahun'), findsOneWidget);
    expect(find.text('Pilih Tanggal Spesifik (Kalender)'), findsOneWidget);
    expect(find.text('Kembali ke Hari Ini'), findsOneWidget);

    // Tap "Des" month
    await tester.tap(find.text('Des'));
    await tester.pumpAndSettle();

    // Verify month updated to Desember 2026
    expect(find.text('Desember 2026'), findsOneWidget);

    // 4. Test "Lihat Semua Hari" toggle
    await tester.tap(find.text('Lihat Semua Hari'));
    await tester.pumpAndSettle();
    expect(find.text('Semua Hari'), findsWidgets);
    expect(find.text('Filter Hari Ini'), findsOneWidget);

    // Toggle back to Filter Hari Ini
    await tester.tap(find.text('Filter Hari Ini'));
    await tester.pumpAndSettle();
    expect(find.text('Lihat Semua Hari'), findsOneWidget);
  });
}
