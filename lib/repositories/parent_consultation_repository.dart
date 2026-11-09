import 'package:pocketbase/pocketbase.dart';
import '../core/app_exception.dart';
import '../core/auth_service.dart';
import '../core/pb_client.dart';
import '../models/parent_consultation_model.dart';
import 'student_repository.dart';

class ParentConsultationRepository {
  ParentConsultationRepository._();
  static final ParentConsultationRepository instance =
      ParentConsultationRepository._();

  PocketBase get _pb => PbClient.instance;

  Future<List<ParentConsultationModel>> getConsultations({
    String? filter,
  }) async {
    try {
      final records = await _pb.collection('parent_consultations').getFullList(
            filter: filter,
            sort: '-held_at,-created',
            expand: 'student,parent,counselor',
          );
      return records.map(ParentConsultationModel.fromRecord).toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<ParentConsultationModel> createConsultation(
    ParentConsultationModel item,
  ) async {
    try {
      final studentId = item.studentId.isNotEmpty
          ? item.studentId
          : await StudentRepository.instance.resolveOrCreateStudentId(
              nisn: item.studentNisn,
              name: item.studentName,
              className: item.studentClass,
              guardianName: item.parentName,
            );
      final counselorId = AuthService.instance.currentUserId;

      final rec = await _pb.collection('parent_consultations').create(
            body: item.toJson(
              resolvedStudentId: studentId,
              resolvedParentId: item.parentId.isNotEmpty ? item.parentId : null,
              counselorId: counselorId.isNotEmpty ? counselorId : null,
            ),
            expand: 'student,parent,counselor',
          );
      return ParentConsultationModel.fromRecord(rec);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<ParentConsultationModel> updateConsultation(
    ParentConsultationModel item,
  ) async {
    try {
      final studentId = item.studentId.isNotEmpty
          ? item.studentId
          : await StudentRepository.instance.resolveOrCreateStudentId(
              nisn: item.studentNisn,
              name: item.studentName,
              className: item.studentClass,
              guardianName: item.parentName,
            );
      final rec = await _pb.collection('parent_consultations').update(
            item.id,
            body: item.toJson(
              resolvedStudentId: studentId,
              resolvedParentId: item.parentId.isNotEmpty ? item.parentId : null,
            ),
            expand: 'student,parent,counselor',
          );
      return ParentConsultationModel.fromRecord(rec);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> deleteConsultation(String id) async {
    try {
      await _pb.collection('parent_consultations').delete(id);
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
