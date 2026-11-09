import 'package:pocketbase/pocketbase.dart';
import '../core/pb_client.dart';

/// Model Pengajuan Konsultasi oleh Orang Tua (`11 • Ajukan Konsultasi (SRS-F-010)`).
/// Terhubung ke collection `consultation_requests` di PocketBase.
class ConsultationRequestModel {
  final String id;
  final String parentId;
  final String studentId;
  final String studentName;
  final String topicCategory; // 'Akademik', 'Perilaku', 'Sosial', 'Minat Bakat'
  final String topic;
  final String preferredDate;
  final String preferredTime;
  final String message;
  final String status; // 'pending', 'approved', 'rejected', 'done'
  final String responseNote;
  final String createdAtText;

  const ConsultationRequestModel({
    required this.id,
    required this.parentId,
    this.studentId = '',
    this.studentName = '',
    required this.topicCategory,
    required this.topic,
    this.preferredDate = '',
    this.preferredTime = '',
    required this.message,
    this.status = 'pending',
    this.responseNote = '',
    this.createdAtText = '',
  });

  factory ConsultationRequestModel.fromRecord(RecordModel r) {
    final expandedStudents = r.get<List<RecordModel>>('expand.student');
    final studentRec =
        expandedStudents.isNotEmpty ? expandedStudents.first : null;

    final rawCreated = r.getStringValue('created');
    final parsed = DateTime.tryParse(rawCreated);

    return ConsultationRequestModel(
      id: r.id,
      parentId: r.getStringValue('parent'),
      studentId: r.getStringValue('student'),
      studentName: studentRec?.getStringValue('name') ?? '',
      topicCategory: r.getStringValue('topic_category'),
      topic: r.getStringValue('topic'),
      preferredDate: r.getStringValue('preferred_date'),
      preferredTime: r.getStringValue('preferred_time'),
      message: r.getStringValue('message'),
      status: r.getStringValue('status').isNotEmpty
          ? r.getStringValue('status')
          : 'pending',
      responseNote: r.getStringValue('response_note'),
      createdAtText:
          parsed != null ? PbClient.formatDateShort(parsed) : rawCreated,
    );
  }
}
