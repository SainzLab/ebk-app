import 'package:pocketbase/pocketbase.dart';
import '../core/app_exception.dart';
import '../core/auth_service.dart';
import '../core/pb_client.dart';
import '../models/consultation_request_model.dart';
import 'student_repository.dart';

class ConsultationRequestRepository {
  ConsultationRequestRepository._();
  static final ConsultationRequestRepository instance =
      ConsultationRequestRepository._();

  PocketBase get _pb => PbClient.instance;

  Future<List<ConsultationRequestModel>> getRequests() async {
    try {
      final records = await _pb.collection('consultation_requests').getFullList(
            sort: '-created',
            expand: 'student,parent',
          );
      return records.map(ConsultationRequestModel.fromRecord).toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<ConsultationRequestModel> submitRequest({
    required String topicCategory,
    required String topic,
    required String message,
    String? preferredDate,
    String? preferredTime,
    String? studentId,
  }) async {
    final parentId = AuthService.instance.currentUserId;
    if (parentId.isEmpty) {
      throw const AppException(
        message: 'Sesi orang tua tidak ditemukan. Silakan login kembali.',
        statusCode: 401,
      );
    }

    try {
      String? resolvedStudent = studentId;
      if (resolvedStudent == null || resolvedStudent.isEmpty) {
        final myChildren = await StudentRepository.instance.getMyChildren();
        if (myChildren.isNotEmpty) {
          resolvedStudent = myChildren.first.id;
        }
      }

      final rec = await _pb.collection('consultation_requests').create(
            body: {
              'parent': parentId,
              if (resolvedStudent != null && resolvedStudent.isNotEmpty)
                'student': resolvedStudent,
              'topic_category': topicCategory,
              'topic': topic,
              if (preferredDate != null) 'preferred_date': preferredDate,
              if (preferredTime != null) 'preferred_time': preferredTime,
              'message': message,
              'status': 'pending',
            },
            expand: 'student,parent',
          );
      return ConsultationRequestModel.fromRecord(rec);
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
