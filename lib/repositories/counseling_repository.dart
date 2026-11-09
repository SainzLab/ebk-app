import 'package:pocketbase/pocketbase.dart';
import '../core/app_exception.dart';
import '../core/auth_service.dart';
import '../core/pb_client.dart';
import '../models/counseling_model.dart';
import 'student_repository.dart';

class CounselingRepository {
  CounselingRepository._();
  static final CounselingRepository instance = CounselingRepository._();

  PocketBase get _pb => PbClient.instance;

  Future<List<CounselingModel>> getSessions({String? filter}) async {
    try {
      final records = await _pb.collection('counseling_sessions').getFullList(
            filter: filter,
            sort: '-session_date,-created',
            expand: 'student,counselor',
          );
      return records.map(CounselingModel.fromRecord).toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<CounselingModel> createSession(CounselingModel item) async {
    try {
      final studentId = item.studentId.isNotEmpty
          ? item.studentId
          : await StudentRepository.instance.resolveOrCreateStudentId(
              nisn: item.studentNisn,
              name: item.studentName,
              className: item.studentClass,
            );
      final counselorId = AuthService.instance.currentUserId;

      final rec = await _pb.collection('counseling_sessions').create(
            body: item.toJson(
              resolvedStudentId: studentId,
              counselorId: counselorId.isNotEmpty ? counselorId : null,
            ),
            expand: 'student,counselor',
          );
      return CounselingModel.fromRecord(rec);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<CounselingModel> updateSession(CounselingModel item) async {
    try {
      final studentId = item.studentId.isNotEmpty
          ? item.studentId
          : await StudentRepository.instance.resolveOrCreateStudentId(
              nisn: item.studentNisn,
              name: item.studentName,
              className: item.studentClass,
            );
      final rec = await _pb.collection('counseling_sessions').update(
            item.id,
            body: item.toJson(resolvedStudentId: studentId),
            expand: 'student,counselor',
          );
      return CounselingModel.fromRecord(rec);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> deleteSession(String id) async {
    try {
      await _pb.collection('counseling_sessions').delete(id);
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
