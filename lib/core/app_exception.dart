import 'package:pocketbase/pocketbase.dart';

/// Exception terstandarisasi untuk menampilkan pesan Bahasa Indonesia di UI.
class AppException implements Exception {
  final String message;
  final int statusCode;
  final Object? originalError;

  const AppException({
    required this.message,
    this.statusCode = 0,
    this.originalError,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNetworkError => statusCode == 0;

  factory AppException.from(Object error) {
    if (error is AppException) return error;
    if (error is ClientException) {
      final code = error.statusCode;
      final resp = error.response;
      final rawMsg = (resp['message'] as String?) ?? '';

      if (code == 0 || error.isAbort) {
        return AppException(
          message:
              'Tidak dapat terhubung ke server PocketBase. Pastikan server lokal sedang berjalan.',
          statusCode: 0,
          originalError: error,
        );
      }

      if (code == 400) {
        // Cek detail field error
        final data = resp['data'];
        if (data is Map && data.isNotEmpty) {
          final firstKey = data.keys.first;
          final firstVal = data[firstKey];
          if (firstVal is Map && firstVal['message'] is String) {
            return AppException(
              message: 'Validasi gagal ($firstKey): ${firstVal['message']}',
              statusCode: code,
              originalError: error,
            );
          }
        }
        if (rawMsg.toLowerCase().contains('authenticate')) {
          return AppException(
            message:
                'Username/Email atau kata sandi tidak sesuai, atau akun tidak aktif.',
            statusCode: code,
            originalError: error,
          );
        }
        return AppException(
          message: rawMsg.isNotEmpty
              ? rawMsg
              : 'Data yang dikirimkan belum lengkap atau tidak valid.',
          statusCode: code,
          originalError: error,
        );
      }

      if (code == 401) {
        return AppException(
          message: 'Sesi Anda telah berakhir. Silakan masuk kembali.',
          statusCode: 401,
          originalError: error,
        );
      }

      if (code == 403) {
        return AppException(
          message: 'Anda tidak memiliki hak akses untuk melakukan aksi ini.',
          statusCode: 403,
          originalError: error,
        );
      }

      if (code == 404) {
        return AppException(
          message: 'Data yang diminta tidak ditemukan di server.',
          statusCode: 404,
          originalError: error,
        );
      }

      return AppException(
        message: rawMsg.isNotEmpty
            ? rawMsg
            : 'Terjadi kesalahan pada server (Kode $code).',
        statusCode: code,
        originalError: error,
      );
    }

    return AppException(
      message: error.toString(),
      statusCode: 0,
      originalError: error,
    );
  }

  @override
  String toString() => message;
}
