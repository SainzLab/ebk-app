import 'package:pocketbase/pocketbase.dart';
import '../core/app_exception.dart';
import '../core/auth_service.dart';
import '../core/pb_client.dart';
import '../models/student_model.dart';

class StudentRepository {
  StudentRepository._();
  static final StudentRepository instance = StudentRepository._();

  PocketBase get _pb => PbClient.instance;

  static String deriveGradeLevel(String className) {
    if (className.startsWith('Kelas IX')) return 'Kelas IX';
    if (className.startsWith('Kelas VIII')) return 'Kelas VIII';
    return 'Kelas VII';
  }

  /// Ambil seluruh daftar siswa dari PocketBase.
  Future<List<StudentDataModel>> getStudents({
    String? filter,
    String sort = 'name',
  }) async {
    try {
      final records = await _pb.collection('students').getFullList(
            filter: filter,
            sort: sort,
            expand: 'guardian',
          );
      return records.map(StudentDataModel.fromRecord).toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Ambil daftar anak yang terhubung ke akun orang tua yang sedang login.
  Future<List<StudentDataModel>> getMyChildren() async {
    final uid = AuthService.instance.currentUserId;
    if (uid.isEmpty) return [];
    return getStudents(filter: "guardian = '$uid'");
  }

  /// Cari siswa berdasarkan NISN atau Nama; jika belum ada di `students`, buat otomatis.
  Future<String> resolveOrCreateStudentId({
    required String nisn,
    required String name,
    required String className,
    String? guardianName,
    String? guardianId,
  }) async {
    final cleanNisn = nisn.trim();
    try {
      if (cleanNisn.isNotEmpty && cleanNisn != '-') {
        final found = await _pb.collection('students').getList(
              page: 1,
              perPage: 1,
              filter: "nisn = '$cleanNisn'",
            );
        if (found.items.isNotEmpty) {
          final existing = found.items.first;
          if (guardianId != null &&
              guardianId.isNotEmpty &&
              existing.getStringValue('guardian') != guardianId) {
            await _pb.collection('students').update(
              existing.id,
              body: {
                'guardian': guardianId,
                if (guardianName != null && guardianName.isNotEmpty)
                  'guardian_name': guardianName,
              },
            );
          }
          return existing.id;
        }
      }

      // Coba cari berdasarkan nama jika NISN kosong
      final escapedName = name.trim().replaceAll("'", "\\'");
      if (escapedName.isNotEmpty) {
        final byName = await _pb.collection('students').getList(
              page: 1,
              perPage: 1,
              filter: "name = '$escapedName'",
            );
        if (byName.items.isNotEmpty) {
          return byName.items.first.id;
        }
      }

      // Buat record siswa baru
      final normClass =
          className.startsWith('Kelas ') ? className : 'Kelas $className';
      final created = await _pb.collection('students').create(
        body: {
          'name': name.trim().isNotEmpty ? name.trim() : 'Siswa Baru',
          'nis': cleanNisn,
          'nisn': cleanNisn.isNotEmpty
              ? cleanNisn
              : DateTime.now().millisecondsSinceEpoch.toString().substring(3),
          'class_name': normClass,
          'grade_level': deriveGradeLevel(normClass),
          'gender': 'Laki-laki',
          if (guardianId != null && guardianId.isNotEmpty)
            'guardian': guardianId,
          'guardian_name': guardianName ?? '-',
          'guardian_relation': 'Orang Tua / Wali',
          'guardian_phone': '-',
          'address': '-',
          'total_points': 0,
        },
      );
      return created.id;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<StudentDataModel> createStudent(StudentDataModel student) async {
    try {
      final rec = await _pb.collection('students').create(
            body: student.toJson(),
            expand: 'guardian',
          );
      return StudentDataModel.fromRecord(rec);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<StudentDataModel> updateStudent(
    String id,
    StudentDataModel student,
  ) async {
    try {
      final rec = await _pb.collection('students').update(
            id,
            body: student.toJson(),
            expand: 'guardian',
          );
      return StudentDataModel.fromRecord(rec);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _pb.collection('students').delete(id);
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
