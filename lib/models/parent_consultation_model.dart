import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../core/pb_client.dart';
import '../theme/app_colors.dart';

/// Model Catatan & Riwayat Konsultasi Orang Tua (`09 • Konsultasi Orang Tua (SRS-F-006)`)
/// Menyimpan informasi orang tua/wali, siswa, waktu, metode komunikasi, topik, hasil diskusi, dan tindak lanjut.
class ParentConsultationModel {
  final String id;
  final String parentId;
  final String studentId;
  final String parentName;
  final String studentName;
  final String studentClass;
  final String studentNisn;
  final String dateTimeText;
  final String consultationMethod; // 'Tatap Muka di Ruang BK', 'Panggilan Telepon / WA', 'Home Visit / Kunjungan'
  final String topic;
  final String discussionSummary;
  final String followUpPlan;
  final bool isCompleted;
  final bool isFromRequest;
  final String topicCategory;
  final String requestStatus; // 'pending', 'approved', 'rejected', 'done'
  final DateTime? consultationDate;

  const ParentConsultationModel({
    required this.id,
    this.parentId = '',
    this.studentId = '',
    required this.parentName,
    required this.studentName,
    required this.studentClass,
    required this.studentNisn,
    required this.dateTimeText,
    required this.consultationMethod,
    required this.topic,
    required this.discussionSummary,
    required this.followUpPlan,
    this.isCompleted = false,
    this.isFromRequest = false,
    this.topicCategory = '',
    this.requestStatus = '',
    this.consultationDate,
  });

  ParentConsultationModel copyWith({
    String? id,
    String? parentId,
    String? studentId,
    String? parentName,
    String? studentName,
    String? studentClass,
    String? studentNisn,
    String? dateTimeText,
    String? consultationMethod,
    String? topic,
    String? discussionSummary,
    String? followUpPlan,
    bool? isCompleted,
    bool? isFromRequest,
    String? topicCategory,
    String? requestStatus,
    DateTime? consultationDate,
  }) {
    return ParentConsultationModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      studentId: studentId ?? this.studentId,
      parentName: parentName ?? this.parentName,
      studentName: studentName ?? this.studentName,
      studentClass: studentClass ?? this.studentClass,
      studentNisn: studentNisn ?? this.studentNisn,
      dateTimeText: dateTimeText ?? this.dateTimeText,
      consultationMethod: consultationMethod ?? this.consultationMethod,
      topic: topic ?? this.topic,
      discussionSummary: discussionSummary ?? this.discussionSummary,
      followUpPlan: followUpPlan ?? this.followUpPlan,
      isCompleted: isCompleted ?? this.isCompleted,
      isFromRequest: isFromRequest ?? this.isFromRequest,
      topicCategory: topicCategory ?? this.topicCategory,
      requestStatus: requestStatus ?? this.requestStatus,
      consultationDate: consultationDate ?? this.consultationDate,
    );
  }

  factory ParentConsultationModel.fromRecord(RecordModel r) {
    final expandedStudents = r.get<List<RecordModel>>('expand.student');
    final studentRec =
        expandedStudents.isNotEmpty ? expandedStudents.first : null;

    final expandedParents = r.get<List<RecordModel>>('expand.parent');
    final parentRec =
        expandedParents.isNotEmpty ? expandedParents.first : null;

    final pName = r.getStringValue('parent_name').isNotEmpty
        ? r.getStringValue('parent_name')
        : (parentRec?.getStringValue('name') ??
            studentRec?.getStringValue('guardian_name') ??
            'Orang Tua Siswa');

    String dtText = r.getStringValue('date_time_text');
    if (dtText.isEmpty) {
      final rawHeld = r.getStringValue('held_at');
      final parsed = DateTime.tryParse(rawHeld);
      dtText = parsed != null ? PbClient.formatDateTimeWib(parsed) : rawHeld;
    }

    return ParentConsultationModel(
      id: r.id,
      parentId: r.getStringValue('parent'),
      studentId: r.getStringValue('student'),
      parentName: pName,
      studentName: studentRec?.getStringValue('name') ?? 'Siswa',
      studentClass: studentRec?.getStringValue('class_name') ?? '-',
      studentNisn: studentRec?.getStringValue('nisn') ?? '-',
      dateTimeText: dtText,
      consultationMethod: r.getStringValue('consultation_method').isNotEmpty
          ? r.getStringValue('consultation_method')
          : 'Tatap Muka di Ruang BK',
      topic: r.getStringValue('topic'),
      discussionSummary: r.getStringValue('discussion_summary'),
      followUpPlan: r.getStringValue('follow_up_plan'),
      isCompleted: r.getBoolValue('is_completed'),
      isFromRequest: false,
      consultationDate: DateTime.tryParse(r.getStringValue('held_at')) ??
          DateTime.tryParse(r.getStringValue('created')),
      requestStatus: '',
    );
  }

  /// Konversi record dari collection `consultation_requests` (pengajuan wali murid)
  /// agar langsung tampil dan dapat dikelola pada menu Konsultasi Orang Tua (Guru BK).
  factory ParentConsultationModel.fromRequestRecord(RecordModel r) {
    final expandedStudents = r.get<List<RecordModel>>('expand.student');
    final studentRec =
        expandedStudents.isNotEmpty ? expandedStudents.first : null;

    final expandedParents = r.get<List<RecordModel>>('expand.parent');
    final parentRec =
        expandedParents.isNotEmpty ? expandedParents.first : null;

    final parentNameFromUser = parentRec?.getStringValue('name') ?? '';
    final parentUsername = parentRec?.getStringValue('username') ?? '';
    final guardianName = studentRec?.getStringValue('guardian_name') ?? '';

    final pName = parentNameFromUser.isNotEmpty
        ? parentNameFromUser
        : (guardianName.isNotEmpty
            ? guardianName
            : (parentUsername.isNotEmpty ? parentUsername : 'Orang Tua Siswa'));

    final prefDate = r.getStringValue('preferred_date').trim();
    final prefTime = r.getStringValue('preferred_time').trim();
    final rawCreated = r.getStringValue('created');
    final parsedCreated = DateTime.tryParse(rawCreated);
    final parsedPrefDate = DateTime.tryParse(prefDate);
    String dtText = '';
    if (prefDate.isNotEmpty) {
      final datePart = parsedPrefDate != null
          ? PbClient.formatDateFull(parsedPrefDate)
          : prefDate;
      if (prefTime.isNotEmpty) {
        final timePart = prefTime.toUpperCase().contains('WIB')
            ? prefTime
            : '$prefTime WIB';
        dtText = '$datePart • $timePart';
      } else {
        dtText = datePart;
      }
    } else {
      dtText = parsedCreated != null
          ? PbClient.formatDateTimeWib(parsedCreated)
          : rawCreated;
    }

    final rawStatus = r.getStringValue('status');
    final isDone = rawStatus == 'done';

    return ParentConsultationModel(
      id: r.id,
      parentId: r.getStringValue('parent'),
      studentId: r.getStringValue('student'),
      parentName: pName,
      studentName: studentRec?.getStringValue('name') ?? 'Siswa',
      studentClass: studentRec?.getStringValue('class_name') ?? '-',
      studentNisn: studentRec?.getStringValue('nisn') ?? '-',
      dateTimeText: dtText,
      consultationMethod: 'Tatap Muka di Ruang BK',
      topic: r.getStringValue('topic'),
      discussionSummary: r.getStringValue('message'),
      followUpPlan: r.getStringValue('response_note'),
      isCompleted: isDone,
      isFromRequest: true,
      topicCategory: r.getStringValue('topic_category'),
      requestStatus: rawStatus,
      consultationDate: parsedPrefDate ?? parsedCreated,
    );
  }

  Map<String, dynamic> toJson({
    required String resolvedStudentId,
    String? resolvedParentId,
    String? counselorId,
  }) {
    return {
      if (resolvedParentId != null && resolvedParentId.isNotEmpty)
        'parent': resolvedParentId,
      'parent_name': parentName,
      'student': resolvedStudentId,
      if (counselorId != null && counselorId.isNotEmpty)
        'counselor': counselorId,
      'held_at': DateTime.now().toUtc().toIso8601String(),
      'date_time_text': dateTimeText,
      'consultation_method': consultationMethod,
      'topic': topic,
      'discussion_summary': discussionSummary,
      'follow_up_plan': followUpPlan,
      'is_completed': isCompleted,
    };
  }

  String get statusLabel {
    if (isCompleted) return 'Selesai';
    if (isFromRequest) {
      if (requestStatus == 'pending') return 'Menunggu Konfirmasi';
      if (requestStatus == 'approved') return 'Disetujui';
      return 'Dalam Proses';
    }
    return 'Dalam Proses';
  }

  Color get statusBgColor {
    if (isCompleted) return AppColors.successBg;
    if (isFromRequest) {
      if (requestStatus == 'approved') return AppColors.primaryTint;
      if (requestStatus == 'pending') return AppColors.warningBg;
      return AppColors.warningBg;
    }
    return AppColors.warningBg;
  }

  Color get statusTextColor {
    if (isCompleted) return AppColors.successText;
    if (isFromRequest) {
      if (requestStatus == 'approved') return AppColors.primaryNavy;
      if (requestStatus == 'pending') return AppColors.warningText;
      return AppColors.warningText;
    }
    return AppColors.warningText;
  }

  static List<ParentConsultationModel> getInitialConsultations() {
    return [
      const ParentConsultationModel(
        id: 'KOP-01',
        parentName: 'Bapak Hendra Pratama',
        studentName: 'Rizky Pratama',
        studentClass: 'Kelas IX-B',
        studentNisn: '0094821034',
        dateTimeText: 'Selasa, 10 Nov 2026 • 10:00 WIB',
        consultationMethod: 'Tatap Muka di Ruang BK',
        topic: 'Evaluasi Kedisiplinan Jam Bangun Pagi & Istirahat di Rumah',
        discussionSummary:
            'Orang tua menyepakati pembatasan gawai pada pukul 21:00 dan memastikan siswa sarapan sebelum berangkat sekolah.',
        followUpPlan:
            'Wali murid mengabari guru BK melalui grup WhatsApp jika siswa mengalami kendala bangun pagi.',
        isCompleted: false,
      ),
      const ParentConsultationModel(
        id: 'KOP-02',
        parentName: 'Ibu Dewi Maharani',
        studentName: 'Alya Putri Maharani',
        studentClass: 'Kelas VIII-A',
        studentNisn: '0103948219',
        dateTimeText: 'Senin, 09 Nov 2026 • 13:30 WIB',
        consultationMethod: 'Panggilan Telepon / WA',
        topic: 'Dukungan Persiapan Asesmen Akademik & Minat Belajar',
        discussionSummary:
            'Pemberian motivasi positif di rumah serta penataan ruang belajar yang kondusif tanpa tekanan nilai berlebih.',
        followUpPlan:
            'Pemantauan nilai tugas mandiri siswa bersama guru mata pelajaran matematika.',
        isCompleted: true,
      ),
      const ParentConsultationModel(
        id: 'KOP-03',
        parentName: 'Bapak Agus Saputra',
        studentName: 'Dimas Aditya Saputra',
        studentClass: 'Kelas VII-C',
        studentNisn: '0112839401',
        dateTimeText: 'Kamis, 05 Nov 2026 • 11:00 WIB',
        consultationMethod: 'Tatap Muka di Ruang BK',
        topic: 'Adaptasi Perilaku dan Pergaulan Lingkungan Sekolah Baru',
        discussionSummary:
            'Orang tua berterima kasih atas perhatian pihak BK dan menyepakati pengawasan interaksi teman bermain di lingkungan rumah.',
        followUpPlan:
            'Evaluasi perkembangan sosial Dimas dalam kegiatan ekstrakurikuler kepramukaan.',
        isCompleted: true,
      ),
      const ParentConsultationModel(
        id: 'KOP-04',
        parentName: 'Ibu Rina Kusumawati',
        studentName: 'Nabila Zahra Aulia',
        studentClass: 'Kelas IX-A',
        studentNisn: '0098374612',
        dateTimeText: 'Rabu, 04 Nov 2026 • 14:00 WIB',
        consultationMethod: 'Home Visit / Kunjungan',
        topic: 'Kunjungan Rumah Terkait Presensi & Peminatan Sekolah Lanjutan',
        discussionSummary:
            'Pihak sekolah berkunjung ke kediaman siswa untuk konfirmasi kondisi kesehatan keluarga dan arahan jalur afirmasi SMK Negeri rujukan.',
        followUpPlan:
            'Pemberkasan dokumen pendaftaran kartu bantuan pendidikan bersama pihak TU.',
        isCompleted: true,
      ),
      const ParentConsultationModel(
        id: 'KOP-05',
        parentName: 'Ibu Siti Nurjanah',
        studentName: 'Salsabila Khairunnisa',
        studentClass: 'Kelas VII-A',
        studentNisn: '0115920384',
        dateTimeText: 'Jumat, 13 Nov 2026 • 09:00 WIB',
        consultationMethod: 'Panggilan Telepon / WA',
        topic: 'Konfirmasi Keterlambatan Masuk Sekolah Hari Senin',
        discussionSummary:
            'Pemberitahuan resmi mengenai jadwal jam masuk sekolah pukul 07:00 WIB dan aturan sanksi keterlambatan berulang.',
        followUpPlan:
            'Wali murid mendampingi keberangkatan siswa naik angkutan pagi lebih awal.',
        isCompleted: false,
      ),
    ];
  }
}
