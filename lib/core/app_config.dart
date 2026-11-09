import 'package:flutter/foundation.dart';

/// Konfigurasi global aplikasi E-BK SMPN 1 Pabuaran.
class AppConfig {
  AppConfig._();

  static const String _envPbUrl = String.fromEnvironment('PB_URL');

  /// URL Server PocketBase lokal sesuai platform:
  /// - Android Emulator: `http://10.0.2.2:8090`
  /// - iOS Simulator / macOS / Web: `http://127.0.0.1:8090`
  /// - Dapat di-override melalui `--dart-define=PB_URL=http://192.168.x.x:8090`
  static String get pbUrl {
    if (_envPbUrl.isNotEmpty) {
      return _envPbUrl;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8090';
    }
    return 'http://127.0.0.1:8090';
  }
}
