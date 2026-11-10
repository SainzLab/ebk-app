# Laporan Audit Keamanan & Bug Project: E-BK SMPN 1 Pabuaran

**Auditor:** Senior DevSecOps & Flutter QA Engineer  
**Tanggal Audit:** 10 November 2026  
**Target Aplikasi:** E-BK Mobile Application (Flutter 3.x / Dart SDK ^3.8.1)  
**Backend:** PocketBase v0.23.0  
**Tipe Audit:** Static Application Security Testing (SAST), Code Review, Bug Hunting & Architecture Risk Assessment  

---

## 1. Ringkasan Eksekutif

Aplikasi **E-BK SMPN 1 Pabuaran** dirancang sebagai platform bimbingan konseling terpadu yang memfasilitasi tiga peran utama: **Guru BK**, **Kepala Sekolah**, dan **Orang Tua / Wali Murid**. Aplikasi ini mengelola data pendidikan yang sangat sensitif (Personally Identifiable Information / PII siswa dan orang tua, catatan pelanggaran kedisiplinan, tindak lanjut kasus tawuran/membolos, dan riwayat konseling psikologis).

Secara umum, struktur kode telah menerapkan pemisahan layer yang cukup rapi antara *models*, *repositories*, *screens*, dan *widgets*, serta menggunakan Material 3. Namun, dari perspektif **DevSecOps** dan **QA Reliability**, audit ini menemukan beberapa kerentanan berisiko tinggi (*High/Critical Severity*), kelemahan manajemen memori (*Memory Leaks*), dan *bad coding practices* yang memerlukan tindakan mitigasi segera sebelum dirilis ke lingkungan produksi:

1. **Keamanan Data & Auth (Kritis):** Token autentikasi dan data sesi disimpan dalam bentuk plain-text di `SharedPreferences`. Terdapat logika *fallback* peran di `AuthService` yang secara otomatis memberikan hak akses tertinggi (**Guru BK**) apabila field `role` tidak dikenali (*Fail-Open*). Ditemukan pula kata sandi default lemah yang di-hardcode (`password123`) serta konfigurasi Android yang mengizinkan lalu lintas HTTP tidak terenkripsi (`usesCleartextTraffic="true"`).
2. **State Management & Memory (Medium - High):** Terjadi kebocoran memori sistematis (*systemic memory leaks*) akibat instansiasi `TextEditingController` di dalam fungsi pembuka *modal bottom sheet* dan dialog tanpa pemanggilan `dispose()`.
3. **Validasi Input & Filter Injection (High):** Query filter PocketBase disusun dengan interpolasi string langsung tanpa parameter sanitasi, membuka celah *Filter Expression Injection*. Selain itu, input form belum mengadopsi `TextFormField` validator bawaan.
4. **Error Handling (High):** Ditemukan lebih dari **50 blok `catch (_) {}`** yang menelan error secara diam-diam (*error swallowing*), disertai pembaruan UI optimis palsu yang memberi kesan bahwa operasi berhasil padahal server menolak request (*false success confirmation*).
5. **Kebocoran Data Dummy (Data Leakage / Privacy Issue):** Fallback *mock data* di repository konsultasi menyebabkan wali murid dapat melihat riwayat konseling milik anak orang tua lain ketika data di database kosong atau gagal dimuat.

---

## 2. Temuan Kritis / High Severity

---

### SEC-01: Bypass Role Otorisasi Akibat Default Fallback Hak Akses Tertinggi (Fail-Open)
- **Kategori:** Broken Access Control / Inadequate Role Authorization (CWE-276 / OWASP A01:2021)
- **Lokasi Berkas:** [`lib/core/auth_service.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/core/auth_service.dart#L137-L148) (Baris 137–148)
- **Deskripsi & Dampak:**
  Dalam getter `currentRole`, aplikasi membaca string role dari record PocketBase. Jika role bukan `orang_tua` atau `kepala_sekolah`, blok switch masuk ke `default: return ProfilRole.guruBk;`.
  Jika akun pengguna baru dibuat tanpa field role, field korup, bernilai kosong, atau role lain yang belum terdaftar, aplikasi **secara otomatis memberikan hak akses penuh sebagai Guru BK**. Peran Guru BK memiliki hak istimewa untuk mengelola seluruh data siswa, menambah/menghapus kasus, mencatat konsultasi, dan membuat akun pengguna. Prinsip keamanan *Least Privilege* dan *Fail-Safe Defaults* terlanggar secara fatal.
- **Rekomendasi Perbaikan Kode:**
  Ubah perilaku default menjadi *Fail-Closed* dengan melempar exception atau memberikan role paling terbatas (*guest/unauthorized*):
  ```dart
  ProfilRole get currentRole {
    final roleStr = currentUser?.getStringValue('role') ?? '';
    return switch (roleStr) {
      'orang_tua' => ProfilRole.orangTua,
      'kepala_sekolah' => ProfilRole.kepalaSekolah,
      'guru_bk' => ProfilRole.guruBk,
      _ => throw const AppException(
          message: 'Hak akses tidak valid atau belum ditetapkan.',
          statusCode: 403,
        ),
    };
  }
  ```

---

### SEC-02: Penyimpanan Kredensial & Token Sesi dalam Plain-Text (Insecure Data Storage)
- **Kategori:** Insecure Data Storage (CWE-312 / OWASP MASVS-STORAGE-1)
- **Lokasi Berkas:** [`lib/core/pb_client.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/core/pb_client.dart#L21-L28) (Baris 21–28), [`pubspec.yaml`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/pubspec.yaml#L38)
- **Deskripsi & Dampak:**
  Token JWT dan record pengguna dari PocketBase disimpan melalui `AsyncAuthStore` ke dalam `SharedPreferences` dengan key `ebk_pb_auth`. Pada Android, `SharedPreferences` menyimpan data ke file XML tidak terenkripsi di `/data/data/com.example.ebkapp/shared_prefs/ebk_pb_auth.xml`. Pada perangkat Android yang di-root, melalui backup ADB (`adb backup`), atau perangkat iOS yang di-jailbreak, token JWT dapat diekstrak oleh penyerang untuk melakukan pembajakan sesi (*Session Hijacking*) tanpa batas waktu.
- **Rekomendasi Perbaikan Kode:**
  Ganti `shared_preferences` dengan `flutter_secure_storage` yang memanfaatkan Android Keystore (AES-GCM) dan iOS Keychain:
  ```dart
  import 'package:flutter_secure_storage/flutter_secure_storage.dart';

  static Future<PocketBase> init() async {
    await initializeDateFormatting('id_ID', null);
    const secureStorage = FlutterSecureStorage();
    final initialToken = await secureStorage.read(key: _authStoreKey);
    
    final store = AsyncAuthStore(
      save: (String data) async =>
          secureStorage.write(key: _authStoreKey, value: data),
      initial: initialToken,
      clear: () async => secureStorage.delete(key: _authStoreKey),
    );
    _instance = PocketBase(AppConfig.pbUrl, authStore: store);
    return _instance!;
  }
  ```

---

### SEC-03: Komunikasi Lalu Lintas Jaringan Tidak Terenkripsi (Cleartext HTTP Traffic)
- **Kategori:** Insecure Communication (CWE-319 / OWASP MASVS-NETWORK-1)
- **Lokasi Berkas:** 
  - [`android/app/src/main/AndroidManifest.xml`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/android/app/src/main/AndroidManifest.xml#L7) (Baris 7)
  - [`lib/core/app_config.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/core/app_config.dart#L13-L21) (Baris 13–21)
- **Deskripsi & Dampak:**
  Pada file `AndroidManifest.xml`, atribut `android:usesCleartextTraffic="true"` diaktifkan. Konfigurasi `AppConfig.pbUrl` mengarah ke URL `http://10.0.2.2:8090` atau `http://127.0.0.1:8090`. Apabila build production dirilis menggunakan protokol HTTP tanpa enkripsi TLS/SSL, seluruh transmisi kredensial login (email, username, password), data kasus siswa, dan token JWT rentan disadap atau dimanipulasi melalui serangan *Man-in-the-Middle* (MitM) di jaringan Wi-Fi sekolah atau publik.
- **Rekomendasi Perbaikan Kode:**
  1. Matikan `usesCleartextTraffic` pada konfigurasi Android Manifest untuk build release atau gunakan Network Security Config:
     ```xml
     <!-- android/app/src/main/AndroidManifest.xml -->
     <application
         android:label="ebkapp"
         android:name="${applicationName}"
         android:icon="@mipmap/ic_launcher"
         android:usesCleartextTraffic="false">
     ```
  2. Wajibkan protokol HTTPS (`https://`) pada `AppConfig.pbUrl` untuk domain production:
     ```dart
     static String get pbUrl {
       if (_envPbUrl.isNotEmpty) {
         if (kReleaseMode && !_envPbUrl.startsWith('https://')) {
           throw StateError('Production PB_URL wajib menggunakan protokol HTTPS.');
         }
         return _envPbUrl;
       }
       if (kReleaseMode) {
         return 'https://ebk.smpn1pabuaran.sch.id';
       }
       // Development fallback
       return (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
           ? 'http://10.0.2.2:8090'
           : 'http://127.0.0.1:8090';
     }
     ```

---

### SEC-04: Kata Sandi Default Lemah & Hardcoded Credentials
- **Kategori:** Use of Hard-coded Credentials / Weak Password Policy (CWE-798 / CWE-521)
- **Lokasi Berkas:** [`lib/repositories/user_repository.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/repositories/user_repository.dart#L42-L53) (Baris 42, 51–53)
- **Deskripsi & Dampak:**
  Pada fungsi `createParentAccount`, kata sandi akun wali murid di-set secara default menjadi string statis `'password123'`:
  ```dart
  Future<UserAccountModel> createParentAccount({
    required UserAccountModel account,
    String password = 'password123',
    ...
  }) async {
    final effectivePassword =
        password.trim().length >= 8 ? password.trim() : 'password123';
  ```
  Hal ini menyebabkan semua akun orang tua yang didaftarkan oleh pihak sekolah memiliki kata sandi awal yang identik dan mudah ditebak. Akun orang tua rentan terhadap *credential stuffing* dan pengambilalihan akun secara massal oleh pihak tidak berwenang.
- **Rekomendasi Perbaikan Kode:**
  Gunakan generator kata sandi acak berbasis kriptografi (*CSPRNG*) atau gunakan alur kirim tautan reset kata sandi via email/WhatsApp resmi sekolah:
  ```dart
  import 'dart:math';

  String generateSecureTempPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%*';
    final rnd = Random.secure();
    return List.generate(10, (_) => chars[rnd.nextInt(chars.length)]).join();
  }
  ```

---

### SEC-05: Filter Expression Injection pada Query PocketBase SDK
- **Kategori:** Injection / Improper Neutralization of Special Elements (CWE-943 / OWASP A03:2021)
- **Lokasi Berkas:**
  - [`lib/repositories/student_repository.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/repositories/student_repository.dart#L57) (Baris 57)
  - [`lib/repositories/case_repository.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/repositories/case_repository.dart#L38-L51) (Baris 38, 51)
  - [`lib/repositories/user_repository.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/repositories/user_repository.dart#L85) (Baris 85)
- **Deskripsi & Dampak:**
  Pencarian siswa dan kasus menyusun filter query PocketBase menggunakan string interpolation mentah:
  ```dart
  filter: "nisn = '$cleanNisn'"
  filter: "student.guardian = '$uid'"
  ```
  Meskipun pada beberapa tempat dilakukan sanitasi sederhana `replaceAll("'", "\\'")`, sanitasi manual tersebut tidak konsisten dan tidak menangani karakter escape atau operator logika PocketBase filter (`||`, `&&`, `~`, `?`). Jika input pengguna mengandung karakter khusus atau manipulasi sintaks filter, penyerang berpotensi memanipulasi logika filter untuk melihat data siswa atau kasus yang seharusnya berada di luar hak aksesnya.
- **Rekomendasi Perbaikan Kode:**
  Gunakan parameterisasi token yang disediakan oleh PocketBase SDK:
  ```dart
  final found = await _pb.collection('students').getList(
    page: 1,
    perPage: 1,
    filter: 'nisn = {:nisn}',
    query: {'nisn': cleanNisn},
  );
  ```

---

### SEC-06: Ketiadaan Route Guards & Validasi Otorisasi Lemah pada Halaman Sensitif
- **Kategori:** Broken Access Control / Insecure Direct Route Navigation (CWE-285)
- **Lokasi Berkas:** 
  - [`lib/main.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/main.dart#L58-L77) (Baris 58–77)
  - [`lib/screens/features/data_siswa_screen.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/screens/features/data_siswa_screen.dart#L57-L74) (Baris 57–74)
- **Deskripsi & Dampak:**
  1. Seluruh rute aplikasi dideklarasikan di `MaterialApp.routes` tanpa adanya verifikasi sesi (*Route Guard*). Pengguna yang belum login atau memiliki role `orang_tua` dapat memicu navigasi langsung ke rute admin seperti `/kelola-pengguna`, `/tambah-kasus`, atau `/data-siswa` melalui deep linking atau modifikasi memori.
  2. Pada `DataSiswaScreen`, logika pembatasan `_isReadOnly` hanya memeriksa apakah peran pengguna adalah `kepalaSekolah`. Jika akun orang tua mengakses rute `/data-siswa`, evaluasi `_isReadOnly` menghasilkan nilai `false`, sehingga tombol Tambah, Edit, dan Hapus Siswa menjadi aktif bagi akun orang tua.
- **Rekomendasi Perbaikan Kode:**
  Implementasikan `onGenerateRoute` yang memeriksa token aktif dan hak akses peran sebelum merender widget:
  ```dart
  Route<dynamic>? onGenerateAppRoute(RouteSettings settings) {
    final auth = AuthService.instance;
    if (!auth.isLoggedIn && settings.name != '/login') {
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    }

    final role = auth.currentRole;
    return switch (settings.name) {
      '/kelola-pengguna' || '/tambah-kasus' => (role == ProfilRole.guruBk)
          ? MaterialPageRoute(builder: (_) => const KelolaPenggunaScreen())
          : MaterialPageRoute(builder: (_) => const AccessDeniedScreen()),
      '/data-siswa' => MaterialPageRoute(
          builder: (_) => DataSiswaScreen(
            role: role,
            isReadOnly: role != ProfilRole.guruBk,
          ),
        ),
      _ => null,
    };
  }
  ```

---

### SEC-07: Sesi Tetap Berjalan pada Akun yang Telah Dinonaktifkan (Bypass Account Suspension)
- **Kategori:** Improper Session Invalidation (CWE-613)
- **Lokasi Berkas:** [`lib/core/auth_service.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/core/auth_service.dart#L186-L193) (Baris 186–193, 204–221)
- **Deskripsi & Dampak:**
  Pengecekan flag `is_active` hanya dilakukan saat proses login awal dan hanya berlaku untuk peran `orang_tua`. Jika pengguna dengan peran Guru BK atau Kepala Sekolah dinonaktifkan statusnya di database, mereka tetap dapat login. Terlebih lagi, pada method `tryRefreshSession()` yang dieksekusi setiap kali aplikasi dibuka, token di-refresh tanpa memeriksa flag `is_active`. Sesi akun yang telah disuspend akan tetap aktif dan dapat terus digunakan.
- **Rekomendasi Perbaikan Kode:**
  Verifikasi flag `is_active` untuk **semua peran** baik saat login maupun refresh token:
  ```dart
  Future<bool> tryRefreshSession() async {
    if (!isLoggedIn) return false;
    try {
      final authData = await _pb.collection('users').authRefresh();
      final isActive = authData.record.getBoolValue('is_active');
      if (!isActive) {
        await logout();
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      final appErr = AppException.from(e);
      if (appErr.isUnauthorized || appErr.isForbidden) {
        await logout();
        return false;
      }
      return isLoggedIn;
    }
  }
  ```

---

### SEC-08: Kebocoran Data Sensitif melalui Fallback Mock Data pada Sesi Orang Tua
- **Kategori:** Information Exposure Through Persistent Mock / IDOR (CWE-200)
- **Lokasi Berkas:**
  - [`lib/repositories/parent_consultation_repository.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/repositories/parent_consultation_repository.dart#L54-L61) (Baris 54–61)
  - [`lib/screens/dashboard/dashboard_ortu_screen.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/screens/dashboard/dashboard_ortu_screen.dart#L224-L228) (Baris 224–228)
  - [`lib/models/parent_consultation_model.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/models/parent_consultation_model.dart#L253-L330) (Baris 253–330)
- **Deskripsi & Dampak:**
  Jika koleksi `consultation_requests` dan `parent_consultations` di PocketBase kosong atau gagal dimuat, method `getConsultations()` mengembalikan daftar statis dari `ParentConsultationModel.getInitialConsultations()`. Di dalam `DashboardOrtuScreen`, record pertama dari hasil tersebut diambil dan ditampilkan pada widget *Kartu Konsultasi Terakhir*:
  ```dart
  if (consultations.isNotEmpty) {
    latestCons = consultations.first; // Mengambil mock data Bapak Hendra Pratama
  }
  ```
  Akibatnya, wali murid yang baru mendaftar dan belum memiliki riwayat konsultasi akan disajikan data konsultasi berisi nama siswa lain, NISN, nomor telepon, dan catatan pembinaan keluarga siswa lain. Ini merupakan pelanggaran kerahasiaan data siswa.
- **Rekomendasi Perbaikan Kode:**
  Hapus mock data fallback. Kembalikan list kosong `[]` jika tidak ada data dan tampilkan UI *Empty State*:
  ```dart
  if (results.isEmpty) {
    return const [];
  }
  return results;
  ```

---

## 3. Temuan Medium / Low Severity

---

### MED-01: Kebocoran Memori Sistematis akibat Un-disposed TextEditingController pada Bottom Sheet & Dialog
- **Kategori:** Memory Leak / Resource Exhaustion (CWE-401)
- **Lokasi Berkas:**
  - [`lib/screens/features/data_siswa_screen.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/screens/features/data_siswa_screen.dart#L884-L904) (Baris 884–904: 7 controller: `nameController`, `nisController`, `nisnController`, `guardianNameController`, `guardianRelationController`, `guardianPhoneController`, `addressController`).
  - [`lib/screens/features/kelola_pengguna_screen.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/screens/features/kelola_pengguna_screen.dart#L438-L446) (Baris 438–446: 5 controller: `nameCtrl`, `usernameCtrl`, `emailCtrl`, `phoneCtrl`, `passwordCtrl`).
  - [`lib/screens/features/jadwal_konseling_screen.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/screens/features/jadwal_konseling_screen.dart#L1146-L1148) (Baris 1146–1148, 1446–1451, 1727–1733: `topicCtrl`, `resultsCtrl`, `followUpCtrl`, `tanggalCtrl`, `timeCtrl`).
  - [`lib/screens/features/catat_konsultasi_screen.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/screens/features/catat_konsultasi_screen.dart#L554-L563) (Baris 554–563: `nameCtrl`, `dateCtrl`, `topicCtrl`, `discussionCtrl`, `followUpCtrl`, `noteCtrl`).
- **Deskripsi & Dampak:**
  Controller diinstansiasi di dalam body method pembuka modal bottom sheet atau dialog. Ketika pengguna menutup sheet (menekan tombol Batal, tombol Back Android, atau melakukan tap di area luar dialog), modal ditutup tetapi instance `TextEditingController` tidak pernah di-dispose. Setiap kali form dibuka dan ditutup, controller baru tertahan di memori beserta listener-nya. Hal ini menyebabkan penumpukan memori (*memory bloat*), pemborosan CPU untuk garbage collection, dan potensi crash *Out-of-Memory* (OOM).
- **Rekomendasi Perbaikan:**
  Ekstrak modal sheet menjadi widget mandiri (`StatefulWidget`) dan dispose controller pada lifecycle `dispose()`:
  ```dart
  class StudentFormSheet extends StatefulWidget {
    final StudentDataModel? student;
    const StudentFormSheet({super.key, this.student});

    @override
    State<StudentFormSheet> createState() => _StudentFormSheetState();
  }

  class _StudentFormSheetState extends State<StudentFormSheet> {
    late final TextEditingController _nameCtrl;
    late final TextEditingController _nisnCtrl;

    @override
    void initState() {
      super.initState();
      _nameCtrl = TextEditingController(text: widget.student?.name ?? '');
      _nisnCtrl = TextEditingController(text: widget.student?.nisn ?? '');
    }

    @override
    void dispose() {
      _nameCtrl.dispose();
      _nisnCtrl.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) { ... }
  }
  ```

---

### MED-02: Silent Failure & False Success Feedback melalui Empty Catch Blocks (`catch (_) {}`)
- **Kategori:** Improper Error Handling (CWE-390 / CWE-754)
- **Lokasi Berkas:** Ditemukan pada **54 lokasi**, antara lain:
  - [`lib/screens/features/kelola_kasus_screen.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/screens/features/kelola_kasus_screen.dart#L681-L688) (Baris 681–688)
  - [`lib/screens/features/kelola_pengguna_screen.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/screens/features/kelola_pengguna_screen.dart#L405-L415) (Baris 405–415, 830–845, 863–875)
  - [`lib/screens/features/jadwal_konseling_screen.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/screens/features/jadwal_konseling_screen.dart#L351-L364) (Baris 351–364, 377–385)
  - [`lib/screens/features/detail_kasus_screen.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/screens/features/detail_kasus_screen.dart#L142-L156) (Baris 142–156)
- **Deskripsi & Dampak:**
  Perhatikan cuplikan pada penghapusan kasus di `KelolaKasusScreen`:
  ```dart
  if (confirmed == true && mounted) {
    try {
      await CaseRepository.instance.deleteCase(caseItem);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _cases.removeWhere((c) => c.id == caseItem.id);
    });
    ToastNotification.show(context, message: 'Berhasil dihapus.');
  }
  ```
  Jika permintaan HTTP ke server gagal (misalnya karena sesi expired 401, hak akses ditolak 403, atau jaringan mati), blok `catch (_) {}` menelan error tanpa logging. Aplikasi kemudian **tetap menghapus item dari tampilan lokal dan menampilkan notifikasi "Berhasil dihapus"**. Pengguna mengira data telah dihapus, padahal di database server data tersebut masih ada.
- **Rekomendasi Perbaikan:**
  Hanya perbarui state lokal jika request backend berhasil, dan berikan feedback error jika gagal:
  ```dart
  if (confirmed == true && mounted) {
    try {
      await CaseRepository.instance.deleteCase(caseItem);
      if (!mounted) return;
      setState(() {
        _cases.removeWhere((c) => c.id == caseItem.id);
      });
      ToastNotification.show(
        context,
        message: 'Data kasus ${caseItem.id} berhasil dihapus.',
        type: ToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      ToastNotification.show(
        context,
        message: 'Gagal menghapus kasus: ${AppException.from(e).message}',
        type: ToastType.error,
      );
    }
  }
  ```

---

### MED-03: Potensi RenderFlex Overflow pada Skala Teks Aksesibilitas (UI Overflow)
- **Kategori:** UI/UX Defect / Accessibility Violation (WCAG 1.4.4 Resize Text)
- **Lokasi Berkas:**
  - [`lib/widgets/student_card.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/widgets/student_card.dart#L30-L33) (Baris 30–33: `height: showAvatar ? 70.0 : 57.0`)
  - [`lib/widgets/custom_text_field.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/widgets/custom_text_field.dart#L113-L115) (Baris 113–115: `resolvedHeight = 50.0`)
  - [`lib/widgets/case_card.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/widgets/case_card.dart#L117-L198) (Baris 117–198: Baris Header tanpa pembatasan fleksibel)
- **Deskripsi & Dampak:**
  Widget menggunakan container dengan tinggi kaku (`height: 70.0` atau `height: 50.0`) yang membungkus teks dan padding vertikal. Ketika pengguna mengaktifkan fitur pembesaran font pada perangkat (*Accessibility Text Scaling* 1.3x–1.5x) atau menggunakan layar beresolusi kecil (misal: 320x640 dp), ruang vertikal tidak mencukupi sehingga Flutter memunculkan pesan error garis kuning-hitam: `A RenderFlex overflowed by X pixels on the bottom`.
- **Rekomendasi Perbaikan:**
  Gunakan `constraints: BoxConstraints(minHeight: ...)` tanpa membatasi tinggi maksimal secara statis:
  ```dart
  // lib/widgets/student_card.dart
  return Container(
    width: double.infinity,
    constraints: BoxConstraints(
      minHeight: showAvatar ? 70.0 : 57.0,
    ),
    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 14.0),
    ...
  );
  ```

---

### MED-04: Beban Memori & Jaringan Tinggi Akibat Fetch Seluruh Baris Database (Client-Side Aggregation)
- **Kategori:** Performance Bottleneck / Denial of Service Risk (CWE-400)
- **Lokasi Berkas:** [`lib/repositories/analytics_repository.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/repositories/analytics_repository.dart#L152,L262) (Baris 152, 262)
- **Deskripsi & Dampak:**
  Pada method `getSummary()` dan `getKepsekAnalytics()`, repository melakukan pemanggilan:
  ```dart
  final casesRecords = await _pb.collection('cases').getFullList();
  ```
  Method `getFullList()` mengunduh seluruh record kasus dari database tanpa batas (*unpaginated*). Setiap kali Kepala Sekolah atau Guru BK membuka dashboard, seluruh tabel kasus di-download lalu dihitung secara agregat di memori handphone. Seiring berjalannya tahun ajaran dan ribuan kasus terdata, query ini akan menyebabkan konsumsi kuota boros, aplikasi freeze saat parsing JSON besar, dan *lag* pada frame UI.
- **Rekomendasi Perbaikan:**
  Gunakan PocketBase View Collections (`v_cases_by_grade`) atau terapkan parameter date range query pada backend PocketBase:
  ```dart
  final periodCases = await _pb.collection('cases').getList(
    page: 1,
    perPage: 50,
    filter: "incident_time >= '$startIso' && incident_time <= '$endIso'",
  );
  ```

---

### LOW-01: Ketiadaan `didUpdateWidget` pada `CustomTextField`
- **Kategori:** Flutter Lifecycle Misuse
- **Lokasi Berkas:** [`lib/widgets/custom_text_field.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/widgets/custom_text_field.dart#L65-L108) (Baris 65–108)
- **Deskripsi:**
  Jika widget parent melakukan rebuild dan meneruskan instance `controller` atau `initialValue` yang baru, `_CustomTextFieldState` tidak mengimplementasikan `didUpdateWidget`. Akibatnya, `CustomTextField` tetap mempertahankan listener pada controller lama atau tidak memperbarui teks yang ditampilkan.
- **Rekomendasi Perbaikan:**
  Implementasikan `didUpdateWidget` untuk melepas listener dari controller lama dan menautkannya ke controller baru.

---

### LOW-02: Hardcoded Tanggal Statis pada Inisialisasi Filter Kepala Sekolah
- **Kategori:** Functional Bug / QA Defect
- **Lokasi Berkas:** [`lib/screens/dashboard/dashboard_kepsek_screen.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/screens/dashboard/dashboard_kepsek_screen.dart#L30-L32) (Baris 30–32)
- **Deskripsi:**
  Tanggal filter analitik di-hardcode ke `DateTime(2026, 11, 1)` hingga `DateTime(2026, 11, 10)` dan tahun 2026. Di luar tanggal tersebut, dashboard tidak otomatis menampilkan data terkini.
- **Rekomendasi Perbaikan:**
  Inisialisasi secara dinamis berbasis tanggal hari ini:
  ```dart
  final now = DateTime.now();
  late DateTime _startDate = DateTime(now.year, now.month, 1);
  late DateTime _endDate = now;
  late int _selectedYear = now.year;
  ```

---

### LOW-03: Ketiadaan Validasi Ekstensi & Ukuran File pada Unggah Foto Profil
- **Kategori:** Unrestricted File Upload / Input Validation (CWE-434)
- **Lokasi Berkas:** [`lib/screens/dashboard/profil_view.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/screens/dashboard/profil_view.dart#L313-L318) (Baris 313–318), [`lib/core/auth_service.dart`](file:///Users/muhammadfazlimukhtar/Documents/Visual%20Studio/ebkapp/lib/core/auth_service.dart#L92-L107) (Baris 92–107)
- **Deskripsi:**
  File foto dibaca seluruh bytes-nya menggunakan `readAsBytes()` tanpa pemeriksaan ukuran maksimal (misalnya batas 2 MB) dan tanpa validasi magic bytes / ekstensi MIME (`image/jpeg`, `image/png`).
- **Rekomendasi Perbaikan:**
  Tambahkan validasi ukuran sebelum mengunggah file ke backend:
  ```dart
  if (bytes.length > 2 * 1024 * 1024) {
    throw const AppException(message: 'Ukuran foto maksimal adalah 2 MB.');
  }
  ```

---

## 4. Rekomendasi Keseluruhan

Untuk memperkuat postur keamanan (*Security Posture*), stabilitas performa, dan kemudahan pemeliharaan (*Maintainability*) project E-BK SMPN 1 Pabuaran, disarankan langkah perbaikan arsitektural berikut:

### 1. Arsitektur Keamanan (DevSecOps)
- **Adopsi Flutter Secure Storage:** Hapus penyimpanan token di `SharedPreferences` dan migrasikan seluruh kredensial sesi ke Android Keystore dan iOS Keychain Services.
- **Implementasi SSL/TLS Certificate Pinning:** Terapkan Certificate Pinning menggunakan package `http` dengan `SecurityContext` kustom atau `dio` agar aplikasi kebal terhadap proxy interception (seperti Burp Suite / Charles Proxy).
- **Enforce Strict API Rules pada PocketBase:** Pastikan keamanan data tidak hanya bergantung pada logika sisi klien (Flutter), tetapi dilindungi oleh API Rules PocketBase (misal: `@request.auth.role = 'guru_bk'` untuk mutasi kasus, dan `@request.auth.id = guardian.id` untuk pembacaan data siswa oleh wali murid).
- **Audit File Android & iOS:** Nonaktifkan flag `android:allowBackup="false"` di `AndroidManifest.xml` untuk mencegah ekstraksi database lokal melalui kabel debugging.

### 2. State Management & Lifecycle
- **Refaktor Dialog Form:** Hindari pembuatan controller lokal di dalam helper method. Ubah seluruh modal form (*Add/Edit Kasus, Tambah Siswa, Kelola Akun, Jadwal Konseling*) menjadi widget terisolasi (`StatefulWidget`) yang menjamin eksekusi `dispose()` untuk setiap `TextEditingController` dan `FocusNode`.
- **Standarisasi Error Handling:** Buat satu layer penanganan error global. Hapus seluruh blok `catch (_) {}` dan ganti dengan logging terstruktur (misalnya menggunakan package `logger` atau Firebase Crashlytics) serta informasikan error kepada pengguna secara transparan.

### 3. Otomasi Pengujian & SAST Tools Tambahan
- **Integrasi CI/CD Pipeline:** Tambahkan workflow GitHub Actions / GitLab CI yang menjalankan pengecekan linter dan security audit otomatis:
  ```bash
  flutter analyze --fatal-infos
  dart pub outdated --mode=security
  ```
- **Tingkatkan Rule Linter:** Aktifkan rule linter tambahan di `analysis_options.yaml`:
  - `avoid_empty_else`
  - `cancel_subscriptions`
  - `close_sinks`
  - `unawaited_futures`
  - `discarded_futures`
- **Automated Widget & Unit Testing:** Buat rangkaian unit test untuk `AuthService` (terutama verifikasi role switch & token refresh) serta widget test untuk memastikan tidak terjadi kebocoran controller saat dialog ditutup.

---
*Laporan ini disusun secara objektif berdasarkan pembacaan dan analisis source code terkini tanpa mengubah kode sumber aplikasi.*