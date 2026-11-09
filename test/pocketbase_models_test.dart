import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:ebkapp/core/app_exception.dart';
import 'package:ebkapp/models/case_model.dart';
import 'package:ebkapp/models/counseling_model.dart';
import 'package:ebkapp/models/parent_consultation_model.dart';
import 'package:ebkapp/models/student_model.dart';
import 'package:ebkapp/models/user_account_model.dart';
import 'package:ebkapp/models/consultation_request_model.dart';

void main() {
  group('PocketBase Model Serialization Tests', () {
    test('StudentDataModel fromRecord & toJson', () {
      final record = RecordModel.fromJson({
        'id': 'std123456789012',
        'name': 'Rizky Pratama',
        'nis': '242509042',
        'nisn': '0094821034',
        'class_name': 'Kelas IX-B',
        'grade_level': 'Kelas IX',
        'gender': 'Laki-laki',
        'guardian': 'usr123456789012',
        'guardian_name': 'Bapak Hendra Pratama',
        'guardian_relation': 'Ayah Kandung',
        'guardian_phone': '0812-8492-1034',
        'address': 'Jl. Raya Pabuaran No. 18',
        'total_points': 25,
      });

      final model = StudentDataModel.fromRecord(record);
      expect(model.id, 'std123456789012');
      expect(model.name, 'Rizky Pratama');
      expect(model.nisn, '0094821034');
      expect(model.totalPoints, 25);

      final json = model.toJson();
      expect(json['name'], 'Rizky Pratama');
      expect(json['guardian'], 'usr123456789012');
    });

    test('CaseRecordModel fromRecord with expanded student', () {
      final record = RecordModel.fromJson({
        'id': 'cas123456789012',
        'code': '#BK-2026-001',
        'student': 'std123456789012',
        'category_name': 'Kedisiplinan',
        'title': 'Membolos Sekolah saat Jam Efektif',
        'incident_time_text': 'Kamis, 05 Nov 2026 • 10:15 WIB',
        'location': 'Warung Kopi Belakang Pagar Sekolah',
        'chronology': 'Melompati pagar samping',
        'handling': 'Konseling individual',
        'handling_date_text': 'Jumat, 06 Nov 2026',
        'counselor_name': 'Pak Budi, S.Pd.',
        'is_completed': false,
        'points': 25,
        'expand': {
          'student': {
            'id': 'std123456789012',
            'name': 'Dimas Aditya Saputra',
            'nisn': '0112839401',
            'class_name': 'Kelas VII-C',
          },
        },
      });

      final model = CaseRecordModel.fromRecord(record);
      expect(model.id, '#BK-2026-001');
      expect(model.recordId, 'cas123456789012');
      expect(model.studentName, 'Dimas Aditya Saputra');
      expect(model.studentClass, 'Kelas VII-C');
      expect(model.violationPoints, 25);
      expect(model.incidentDate, isNotNull);
      expect(model.incidentDate!.year, 2026);
      expect(model.incidentDate!.month, 11);
      expect(model.incidentDate!.day, 5);

      // Verifikasi toJson menghasilkan ISO UTC pada kolom incident_time backend
      final json = model.toJson(resolvedStudentId: 'std123456789012');
      expect(json['incident_time'], contains('2026-11-05'));

      // Verifikasi parseIncidentDateTime menangani format teks dan typo
      final parsedWithTypo = CaseRecordModel.parseIncidentDateTime('Sabtu, 07 Nov 2026 • 09:30IB');
      expect(parsedWithTypo.year, 2026);
      expect(parsedWithTypo.month, 11);
      expect(parsedWithTypo.day, 7);
      expect(parsedWithTypo.hour, 9);
      expect(parsedWithTypo.minute, 30);
    });

    test('CounselingModel fromRecord & ParentConsultationModel fromRecord', () {
      final cRec = RecordModel.fromJson({
        'id': 'csl123456789012',
        'student': 'std123456789012',
        'date_str': 'Sabtu, 07 Nov 2026',
        'day_index': 5,
        'time_range': '08:30 – 09:15 WIB',
        'counseling_type': 'Individu',
        'topic': 'Pembinaan Disiplin',
        'result_notes': 'Catatan hasil',
        'follow_up_plan': 'Tindak lanjut',
        'is_completed': true,
        'expand': {
          'student': {
            'id': 'std123456789012',
            'name': 'Rizky Pratama',
            'nisn': '0094821034',
            'class_name': 'Kelas IX-B',
          },
        },
      });

      final counseling = CounselingModel.fromRecord(cRec);
      expect(counseling.studentName, 'Rizky Pratama');
      expect(counseling.isCompleted, isTrue);
      expect(counseling.resolvedDate.year, 2026);
      expect(counseling.resolvedDate.month, 11);
      expect(counseling.resolvedDate.day, 7);

      final cJson = counseling.toJson(resolvedStudentId: 'std123456789012');
      expect(cJson['session_date'], contains('2026-11'));

      final pRec = RecordModel.fromJson({
        'id': 'pco123456789012',
        'parent_name': 'Bapak Hendra Pratama',
        'student': 'std123456789012',
        'date_time_text': 'Selasa, 10 Nov 2026 • 10:00 WIB',
        'consultation_method': 'Tatap Muka di Ruang BK',
        'topic': 'Evaluasi Kedisiplinan',
        'discussion_summary': 'Ringkasan diskusi',
        'follow_up_plan': 'Tindak lanjut',
        'is_completed': false,
        'expand': {
          'student': {
            'id': 'std123456789012',
            'name': 'Rizky Pratama',
            'nisn': '0094821034',
            'class_name': 'Kelas IX-B',
          },
        },
      });

      final parentCons = ParentConsultationModel.fromRecord(pRec);
      expect(parentCons.parentName, 'Bapak Hendra Pratama');
      expect(parentCons.studentName, 'Rizky Pratama');
    });

    test('UserAccountModel supports multiple children per parent', () {
      final userRec = RecordModel.fromJson({
        'id': 'usr123456789012',
        'name': 'Bapak Hendra Pratama',
        'username': 'hendra.pratama',
        'email': 'hendra.pratama@gmail.com',
        'is_active': true,
        'created': '2026-07-16 00:00:00.000Z',
      });

      final children = [
        StudentDataModel.defaultStudents[0],
        StudentDataModel.defaultStudents[1],
      ];

      final account = UserAccountModel.fromRecord(
        userRec,
        linkedChildren: children,
      );
      expect(account.studentChildName, 'Rizky Pratama (+1 anak)');
      expect(account.children.length, 2);
    });

    test('ConsultationRequestModel fromRecord & AppException mapping', () {
      final reqRec = RecordModel.fromJson({
        'id': 'req123456789012',
        'parent': 'usr123456789012',
        'topic_category': 'Akademik',
        'topic': 'Akademik / Perilaku Siswa',
        'message': 'Mohon jadwal konsultasi',
        'status': 'pending',
      });
      final req = ConsultationRequestModel.fromRecord(reqRec);
      expect(req.topicCategory, 'Akademik');
      expect(req.status, 'pending');

      final clientErr = ClientException(
        statusCode: 401,
        response: {'message': 'Unauthorized'},
      );
      final appErr = AppException.from(clientErr);
      expect(appErr.isUnauthorized, isTrue);
    });
  });
}
