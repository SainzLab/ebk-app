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
      final results = <ParentConsultationModel>[];

      // 1. Ambil pengajuan konsultasi dari orang tua (`consultation_requests`)
      try {
        final reqRecords =
            await _pb.collection('consultation_requests').getFullList(
                  filter: filter,
                  sort: '-created',
                  expand: 'student,parent',
                );
        results.addAll(
          reqRecords.map(ParentConsultationModel.fromRequestRecord),
        );
      } catch (_) {}

      // 2. Ambil catatan konsultasi orang tua (`parent_consultations`)
      try {
        final records =
            await _pb.collection('parent_consultations').getFullList(
                  filter: filter,
                  sort: '-held_at,-created',
                  expand: 'student,parent,counselor',
                );
        results.addAll(records.map(ParentConsultationModel.fromRecord));
      } catch (_) {}

      // Urutkan seluruh hasil (gabungan requests dan consultations) terbaru lebih dulu
      results.sort((a, b) {
        final aDate =
            a.consultationDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            b.consultationDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      if (results.isEmpty) {
        return ParentConsultationModel.getInitialConsultations();
      }

      return results;
    } catch (e) {
      return ParentConsultationModel.getInitialConsultations();
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

      if (item.isFromRequest) {
        final rec = await _pb.collection('consultation_requests').update(
              item.id,
              body: {
                if (studentId.isNotEmpty) 'student': studentId,
                'topic': item.topic,
                'message': item.discussionSummary,
                'response_note': item.followUpPlan,
                'status': item.isCompleted
                    ? 'done'
                    : (item.requestStatus.isNotEmpty
                        ? item.requestStatus
                        : 'approved'),
              },
              expand: 'student,parent',
            );
        return ParentConsultationModel.fromRequestRecord(rec);
      }

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

  /// Konfirmasi & setujui permohonan konsultasi dari orang tua murid (`status = 'approved'`).
  Future<ParentConsultationModel> confirmRequest(
    String id, {
    String? responseNote,
  }) async {
    try {
      final rec = await _pb.collection('consultation_requests').update(
            id,
            body: {
              'status': 'approved',
              if (responseNote != null && responseNote.isNotEmpty)
                'response_note': responseNote,
            },
            expand: 'student,parent',
          );
      return ParentConsultationModel.fromRequestRecord(rec);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> deleteConsultation(
    String id, {
    bool isFromRequest = false,
  }) async {
    try {
      if (isFromRequest) {
        await _pb.collection('consultation_requests').delete(id);
        return;
      }
      try {
        await _pb.collection('parent_consultations').delete(id);
      } catch (_) {
        await _pb.collection('consultation_requests').delete(id);
      }
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
