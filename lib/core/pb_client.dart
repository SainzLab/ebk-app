import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart';

/// Singleton client PocketBase dengan persistensi sesi di SharedPreferences.
class PbClient {
  PbClient._();

  static const String _authStoreKey = 'ebk_pb_auth';
  static PocketBase? _instance;

  static PocketBase get instance {
    return _instance ??= PocketBase(AppConfig.pbUrl);
  }

  /// Inisialisasi PocketBase beserta `AsyncAuthStore` dan locale tanggal Indonesia.
  static Future<PocketBase> init() async {
    await initializeDateFormatting('id_ID', null);
    final prefs = await SharedPreferences.getInstance();
    final store = AsyncAuthStore(
      save: (String data) async => prefs.setString(_authStoreKey, data),
      initial: prefs.getString(_authStoreKey),
      clear: () async => prefs.remove(_authStoreKey),
    );
    _instance = PocketBase(AppConfig.pbUrl, authStore: store);
    return _instance!;
  }

  /// Override instance untuk keperluan unit test.
  static void setTestInstance(PocketBase client) {
    _instance = client;
  }

  /// Format DateTime ke teks Bahasa Indonesia, mis: `Kamis, 05 Nov 2026 • 10:15 WIB`
  static String formatDateTimeWib(DateTime dt) {
    final local = dt.toLocal();
    try {
      final datePart = DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(local);
      final timePart = DateFormat('HH:mm').format(local);
      return '$datePart • $timePart WIB';
    } catch (_) {
      return '${local.day}/${local.month}/${local.year}';
    }
  }

  /// Format DateTime ke tanggal pendek Bahasa Indonesia, mis: `Jumat, 06 Nov 2026`
  static String formatDateFull(DateTime dt) {
    final local = dt.toLocal();
    try {
      return DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(local);
    } catch (_) {
      return '${local.day}/${local.month}/${local.year}';
    }
  }

  /// Format DateTime ke tanggal ringkas, mis: `16 Jul 2026`
  static String formatDateShort(DateTime dt) {
    final local = dt.toLocal();
    try {
      return DateFormat('dd MMM yyyy', 'id_ID').format(local);
    } catch (_) {
      return '${local.day}/${local.month}/${local.year}';
    }
  }
}
