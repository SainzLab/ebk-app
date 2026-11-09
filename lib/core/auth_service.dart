import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../screens/dashboard/profil_view.dart';
import 'app_exception.dart';
import 'pb_client.dart';

/// Layanan autentikasi pengguna E-BK terhadap collection `users` di PocketBase.
class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  PocketBase get _pb => PbClient.instance;

  bool get isLoggedIn =>
      _pb.authStore.isValid && _pb.authStore.record != null;

  RecordModel? get currentUser => _pb.authStore.record;

  String get currentUserId => currentUser?.id ?? '';

  String get currentUserName {
    final name = currentUser?.getStringValue('name') ?? '';
    if (name.isNotEmpty) return name;
    return switch (currentRole) {
      ProfilRole.guruBk => 'Dra. Hj. Siti Aminah, M.Pd.',
      ProfilRole.kepalaSekolah => 'Drs. H. Ahmad Fauzi, M.M.Pd.',
      ProfilRole.orangTua => 'Bapak Hendra Pratama',
    };
  }

  String get currentUserEmail =>
      currentUser?.getStringValue('email') ?? '';

  String get currentUserPhone =>
      currentUser?.getStringValue('phone') ?? '';

  String get currentUserNip =>
      currentUser?.getStringValue('nip') ?? '';

  String get currentUserPosition =>
      currentUser?.getStringValue('position') ?? '';

  bool get currentUserNotifyEmail =>
      currentUser?.getBoolValue('notify_email') ?? true;

  ProfilRole get currentRole {
    final roleStr = currentUser?.getStringValue('role') ?? '';
    switch (roleStr) {
      case 'orang_tua':
        return ProfilRole.orangTua;
      case 'kepala_sekolah':
        return ProfilRole.kepalaSekolah;
      case 'guru_bk':
      default:
        return ProfilRole.guruBk;
    }
  }

  String get initialRoute {
    if (!isLoggedIn) return '/login';
    return routeForRole(currentRole);
  }

  static String routeForRole(ProfilRole role) {
    switch (role) {
      case ProfilRole.orangTua:
        return '/dashboard-ortu';
      case ProfilRole.kepalaSekolah:
        return '/dashboard-kepsek';
      case ProfilRole.guruBk:
        return '/dashboard-guru';
    }
  }

  /// Login ke PocketBase menggunakan email atau username.
  Future<ProfilRole> login({
    required String identifier,
    required String password,
  }) async {
    final cleanId = identifier.trim();
    if (cleanId.isEmpty || password.isEmpty) {
      throw const AppException(
        message: 'Harap masukkan Email/Username dan Kata Sandi.',
        statusCode: 400,
      );
    }

    try {
      final authData = await _pb
          .collection('users')
          .authWithPassword(cleanId, password);

      final roleStr = authData.record.getStringValue('role');
      final isActive = authData.record.getBoolValue('is_active');
      if (roleStr == 'orang_tua' && !isActive) {
        _pb.authStore.clear();
        throw const AppException(
          message:
              'Akun Orang Tua Anda sedang dinonaktifkan. Hubungi Guru BK.',
          statusCode: 403,
        );
      }

      notifyListeners();
      return currentRole;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Refresh sesi jika token masih ada saat aplikasi dibuka.
  Future<bool> tryRefreshSession() async {
    if (!isLoggedIn) return false;
    try {
      await _pb.collection('users').authRefresh();
      notifyListeners();
      return true;
    } catch (e) {
      final appErr = AppException.from(e);
      if (appErr.isUnauthorized) {
        _pb.authStore.clear();
        notifyListeners();
        return false;
      }
      // Jika hanya kendala jaringan sementara, pertahankan sesi lokal
      return isLoggedIn;
    }
  }

  /// Perbarui data profil pengguna yang sedang login.
  Future<RecordModel> updateProfile({
    String? name,
    String? phone,
    String? nip,
    String? position,
    bool? notifyEmail,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw const AppException(
        message: 'Sesi tidak ditemukan. Silakan login kembali.',
        statusCode: 401,
      );
    }
    try {
      final body = <String, dynamic>{
        if (name != null) 'name': name.trim(),
        if (phone != null) 'phone': phone.trim(),
        if (nip != null) 'nip': nip.trim(),
        if (position != null) 'position': position.trim(),
        if (notifyEmail != null) 'notify_email': notifyEmail,
      };
      final updated = await _pb
          .collection('users')
          .update(user.id, body: body);
      _pb.authStore.save(_pb.authStore.token, updated);
      notifyListeners();
      return updated;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Ubah kata sandi akun yang sedang login.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw const AppException(
        message: 'Sesi tidak ditemukan. Silakan login kembali.',
        statusCode: 401,
      );
    }
    try {
      await _pb.collection('users').update(
        user.id,
        body: {
          'oldPassword': oldPassword,
          'password': newPassword,
          'passwordConfirm': confirmPassword,
        },
      );
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Logout dan bersihkan token dari penyimpanan lokal.
  Future<void> logout() async {
    _pb.authStore.clear();
    notifyListeners();
  }
}
