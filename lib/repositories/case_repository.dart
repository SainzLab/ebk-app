import 'package:pocketbase/pocketbase.dart';
import '../core/app_exception.dart';
import '../core/auth_service.dart';
import '../core/pb_client.dart';
import '../models/case_model.dart';
import '../models/student_model.dart';
import 'student_repository.dart';

class CaseRepository {
  CaseRepository._();
  static final CaseRepository instance = CaseRepository._();

  PocketBase get _pb => PbClient.instance;

  /// Ambil seluruh daftar kasus pelanggaran (otomatis terfilter oleh API rules PocketBase).
  Future<List<CaseRecordModel>> getCases({String? filter}) async {
    try {
      final records = await _pb.collection('cases').getFullList(
            filter: filter,
            sort: '-created',
            expand: 'student,category,counselor',
          );
      return records.map(CaseRecordModel.fromRecord).toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Ambil kasus milik anak-anak wali yang sedang login.
  /// Difilter di server (`student.guardian = <uid>`) dan diverifikasi ulang
  /// di klien terhadap daftar anak agar data wali lain tidak pernah tampil.
  Future<List<CaseRecordModel>> getMyCases(
    List<StudentDataModel> myChildren,
  ) async {
    final uid = AuthService.instance.currentUserId;
    if (uid.isEmpty || myChildren.isEmpty) return [];
    final childIds = myChildren.map((c) => c.id).toSet();
    final list = await getCases(filter: "student.guardian = '$uid'");
    return list.where((c) => childIds.contains(c.studentId)).toList();
  }

  /// Cari ID kategori berdasarkan namanya di `case_categories`.
  Future<String?> _resolveCategoryId(String categoryName) async {
    try {
      final escaped = categoryName.trim().replaceAll("'", "\\'");
      final list = await _pb.collection('case_categories').getList(
            page: 1,
            perPage: 1,
            filter: "name = '$escaped'",
          );
      if (list.items.isNotEmpty) {
        return list.items.first.id;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Simpan kasus pelanggaran baru ke PocketBase (`cases`).
  /// Kode kasus (`#BK-YYYY-NNN`) otomatis digenerate oleh hook PocketBase jika dikosongkan.
  Future<CaseRecordModel> createCase(CaseRecordModel item) async {
    try {
      final studentId = item.studentId.isNotEmpty
          ? item.studentId
          : await StudentRepository.instance.resolveOrCreateStudentId(
              nisn: item.studentNisn,
              name: item.studentName,
              className: item.studentClass,
            );
      final categoryId = await _resolveCategoryId(item.caseCategory);
      final counselorId = AuthService.instance.currentUserId;

      final body = item.toJson(
        resolvedStudentId: studentId,
        categoryId: categoryId,
        counselorId: counselorId.isNotEmpty ? counselorId : null,
      );
      // Biarkan hook PocketBase meng-generate kode `#BK-YYYY-NNN`
      body.remove('code');

      final rec = await _pb.collection('cases').create(
            body: body,
            expand: 'student,category,counselor',
          );
      return CaseRecordModel.fromRecord(rec);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Perbarui kasus pelanggaran di PocketBase (`cases`).
  Future<CaseRecordModel> updateCase(CaseRecordModel item) async {
    try {
      String targetRecordId = item.recordId;
      if (targetRecordId.isEmpty) {
        final escapedCode = item.id.replaceAll("'", "\\'");
        final found = await _pb.collection('cases').getList(
              page: 1,
              perPage: 1,
              filter: "code = '$escapedCode'",
            );
        if (found.items.isNotEmpty) {
          targetRecordId = found.items.first.id;
        }
      }
      if (targetRecordId.isEmpty) {
        return createCase(item);
      }

      final studentId = item.studentId.isNotEmpty
          ? item.studentId
          : await StudentRepository.instance.resolveOrCreateStudentId(
              nisn: item.studentNisn,
              name: item.studentName,
              className: item.studentClass,
            );
      final categoryId = await _resolveCategoryId(item.caseCategory);

      final rec = await _pb.collection('cases').update(
            targetRecordId,
            body: item.toJson(
              resolvedStudentId: studentId,
              categoryId: categoryId,
            ),
            expand: 'student,category,counselor',
          );
      return CaseRecordModel.fromRecord(rec);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Hapus kasus pelanggaran dari PocketBase (`cases`).
  Future<void> deleteCase(CaseRecordModel item) async {
    try {
      String targetRecordId = item.recordId;
      if (targetRecordId.isEmpty) {
        final escapedCode = item.id.replaceAll("'", "\\'");
        final found = await _pb.collection('cases').getList(
              page: 1,
              perPage: 1,
              filter: "code = '$escapedCode'",
            );
        if (found.items.isNotEmpty) {
          targetRecordId = found.items.first.id;
        }
      }
      if (targetRecordId.isNotEmpty) {
        await _pb.collection('cases').delete(targetRecordId);
      }
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
