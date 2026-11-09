import 'package:pocketbase/pocketbase.dart';
import '../core/pb_client.dart';

/// Model Data Kasus Pelanggaran Siswa (`SRS-F-004`, `SRS-F-008`, `SRS-F-009`)
/// Menyimpan informasi jenis kasus (membolos, tawuran, dll), waktu kejadian,
/// tempat kejadian, deskripsi kronologi, serta catatan penanganan oleh Guru BK.
class CaseRecordModel {
  /// Kode kasus yang ditampilkan di UI, mis: `#BK-2026-045`
  final String id;

  /// ID record PocketBase (`cases.id`) untuk operasi update/delete.
  final String recordId;

  /// Relasi ID siswa di PocketBase (`students.id`).
  final String studentId;

  final String studentName;
  final String studentNisn;
  final String studentClass;
  final String caseCategory;
  final String caseTitle;

  /// Waktu & tanggal kejadian dalam bentuk DateTime (di backend PocketBase tersimpan di kolom `incident_time` berformat date/ISO-8601).
  final DateTime? incidentDate;

  /// Teks waktu kejadian terformat dalam Bahasa Indonesia, misal: `Sabtu, 07 Nov 2026 • 09:30 WIB`.
  final String incidentTime;
  final String incidentLocation;
  final String chronology;
  final String handling;
  final String handlingDate;
  final String counselorName;
  final bool isCompleted;
  final int violationPoints;

  const CaseRecordModel({
    required this.id,
    this.recordId = '',
    this.studentId = '',
    required this.studentName,
    required this.studentNisn,
    required this.studentClass,
    required this.caseCategory,
    required this.caseTitle,
    this.incidentDate,
    required this.incidentTime,
    required this.incidentLocation,
    required this.chronology,
    required this.handling,
    required this.handlingDate,
    required this.counselorName,
    required this.isCompleted,
    required this.violationPoints,
  });

  /// Mengembalikan `DateTime` kejadian yang valid. Jika `incidentDate` kosong,
  /// fungsi ini akan mem-parse `incidentTime` (string tanggal/jam Indonesia atau ISO).
  DateTime get resolvedIncidentDate {
    if (incidentDate != null) return incidentDate!;
    return parseIncidentDateTime(incidentTime);
  }

  CaseRecordModel copyWith({
    String? id,
    String? recordId,
    String? studentId,
    String? studentName,
    String? studentNisn,
    String? studentClass,
    String? caseCategory,
    String? caseTitle,
    DateTime? incidentDate,
    String? incidentTime,
    String? incidentLocation,
    String? chronology,
    String? handling,
    String? handlingDate,
    String? counselorName,
    bool? isCompleted,
    int? violationPoints,
  }) {
    return CaseRecordModel(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentNisn: studentNisn ?? this.studentNisn,
      studentClass: studentClass ?? this.studentClass,
      caseCategory: caseCategory ?? this.caseCategory,
      caseTitle: caseTitle ?? this.caseTitle,
      incidentDate: incidentDate ?? this.incidentDate,
      incidentTime: incidentTime ?? this.incidentTime,
      incidentLocation: incidentLocation ?? this.incidentLocation,
      chronology: chronology ?? this.chronology,
      handling: handling ?? this.handling,
      handlingDate: handlingDate ?? this.handlingDate,
      counselorName: counselorName ?? this.counselorName,
      isCompleted: isCompleted ?? this.isCompleted,
      violationPoints: violationPoints ?? this.violationPoints,
    );
  }

  factory CaseRecordModel.fromRecord(RecordModel r) {
    final expandedStudents = r.get<List<RecordModel>>('expand.student');
    final studentRec =
        expandedStudents.isNotEmpty ? expandedStudents.first : null;

    final expandedCats = r.get<List<RecordModel>>('expand.category');
    final catRec = expandedCats.isNotEmpty ? expandedCats.first : null;

    final expandedCounselors = r.get<List<RecordModel>>('expand.counselor');
    final counselorRec =
        expandedCounselors.isNotEmpty ? expandedCounselors.first : null;

    final codeStr = r.getStringValue('code').isNotEmpty
        ? r.getStringValue('code')
        : '#BK-${r.id.substring(0, r.id.length > 6 ? 6 : r.id.length).toUpperCase()}';

    final rawDate = r.getStringValue('incident_time');
    DateTime? incidentDate;
    if (rawDate.isNotEmpty) {
      incidentDate = DateTime.tryParse(rawDate)?.toLocal();
    }

    String incidentText = r.getStringValue('incident_time_text');
    if (incidentText.isEmpty && incidentDate != null) {
      incidentText = PbClient.formatDateTimeWib(incidentDate);
    } else if (incidentText.isEmpty) {
      incidentText = rawDate;
    }

    if (incidentDate == null && incidentText.isNotEmpty) {
      incidentDate = parseIncidentDateTime(incidentText);
    }

    String handlingDateText = r.getStringValue('handling_date_text');
    if (handlingDateText.isEmpty) {
      final rawHandlingDate = r.getStringValue('handling_date');
      final parsed = DateTime.tryParse(rawHandlingDate);
      handlingDateText =
          parsed != null ? PbClient.formatDateFull(parsed) : rawHandlingDate;
    }

    final catName = r.getStringValue('category_name').isNotEmpty
        ? r.getStringValue('category_name')
        : (catRec?.getStringValue('name') ?? 'Kedisiplinan');

    final cName = r.getStringValue('counselor_name').isNotEmpty
        ? r.getStringValue('counselor_name')
        : (counselorRec?.getStringValue('name') ?? 'Pak Budi, S.Pd.');

    return CaseRecordModel(
      id: codeStr,
      recordId: r.id,
      studentId: r.getStringValue('student'),
      studentName: studentRec?.getStringValue('name') ?? 'Siswa',
      studentNisn: studentRec?.getStringValue('nisn') ?? '-',
      studentClass: studentRec?.getStringValue('class_name') ?? '-',
      caseCategory: catName,
      caseTitle: r.getStringValue('title'),
      incidentDate: incidentDate,
      incidentTime: incidentText,
      incidentLocation: r.getStringValue('location'),
      chronology: r.getStringValue('chronology'),
      handling: r.getStringValue('handling'),
      handlingDate: handlingDateText,
      counselorName: cName,
      isCompleted: r.getBoolValue('is_completed'),
      violationPoints: r.getIntValue('points'),
    );
  }

  Map<String, dynamic> toJson({
    required String resolvedStudentId,
    String? categoryId,
    String? counselorId,
  }) {
    final effectiveDate = incidentDate ?? resolvedIncidentDate;
    return {
      if (id.startsWith('#BK-') && !id.endsWith('BARU')) 'code': id,
      'student': resolvedStudentId,
      if (categoryId != null && categoryId.isNotEmpty) 'category': categoryId,
      'category_name': caseCategory,
      'title': caseTitle,
      'incident_time': effectiveDate.toUtc().toIso8601String(),
      'incident_time_text': incidentTime,
      'location': incidentLocation,
      'chronology': chronology,
      'handling': handling,
      'handling_date': DateTime.now().toUtc().toIso8601String(),
      'handling_date_text': handlingDate,
      if (counselorId != null && counselorId.isNotEmpty)
        'counselor': counselorId,
      'counselor_name': counselorName,
      'is_completed': isCompleted,
      'points': violationPoints,
    };
  }

  /// Parser cerdas untuk membaca tanggal, bulan, tahun, serta jam kejadian
  /// dari teks format Indonesia (mis: `Sabtu, 07 Nov 2026 • 09:30 WIB`) maupun string ISO-8601.
  static DateTime parseIncidentDateTime(String? raw, [DateTime? fallback]) {
    if (raw == null || raw.trim().isEmpty) {
      return fallback ?? DateTime.now();
    }
    final trimmed = raw.trim();

    final iso = DateTime.tryParse(trimmed);
    if (iso != null) return iso.toLocal();

    try {
      final regex = RegExp(
        r'(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})(?:\s*[•·-]\s*(\d{1,2})[:.](\d{2}))?',
      );
      final match = regex.firstMatch(trimmed);
      if (match != null) {
        final day = int.parse(match.group(1)!);
        final monthStr = match.group(2)!.toLowerCase();
        final year = int.parse(match.group(3)!);
        final hour = match.group(4) != null ? int.parse(match.group(4)!) : 9;
        final minute = match.group(5) != null ? int.parse(match.group(5)!) : 0;

        const monthMap = {
          'jan': 1, 'januari': 1, 'january': 1,
          'feb': 2, 'februari': 2, 'february': 2,
          'mar': 3, 'maret': 3, 'march': 3,
          'apr': 4, 'april': 4,
          'mei': 5, 'may': 5,
          'jun': 6, 'juni': 6, 'june': 6,
          'jul': 7, 'juli': 7, 'july': 7,
          'agu': 8, 'agustus': 8, 'agt': 8, 'aug': 8, 'august': 8,
          'sep': 9, 'september': 9,
          'okt': 10, 'oktober': 10, 'oct': 10, 'october': 10,
          'nov': 11, 'november': 11,
          'des': 12, 'desember': 12, 'dec': 12, 'december': 12,
        };
        int month = 1;
        for (final entry in monthMap.entries) {
          if (monthStr.startsWith(entry.key)) {
            month = entry.value;
            break;
          }
        }
        return DateTime(year, month, day, hour, minute);
      }
    } catch (_) {}

    return fallback ?? DateTime.now();
  }

  /// Data awal kasus pelanggaran siswa SMPN 1 Pabuaran
  static List<CaseRecordModel> get defaultCases => [
        const CaseRecordModel(
          id: '#BK-2026-045',
          studentName: 'Dimas Aditya Saputra',
          studentNisn: '0112839401',
          studentClass: 'Kelas VII-C',
          caseCategory: 'Kedisiplinan',
          caseTitle: 'Membolos Sekolah saat Jam Efektif',
          incidentTime: 'Kamis, 05 Nov 2026 • 10:15 WIB',
          incidentLocation: 'Warung Kopi Belakang Pagar Sekolah',
          chronology:
              'Siswa meninggalkan lingkungan sekolah melompati pagar samping saat pergantian jam pelajaran ketiga tanpa izin piket sekolah. Ditemukan oleh tim ketertiban sekolah bersama dua rekan.',
          handling:
              'Pemanggilan siswa ke Ruang BK untuk konseling individual, penyampaian notifikasi presensi ke orang tua/wali, serta penandatanganan komitmen tidak mengulangi.',
          handlingDate: 'Jumat, 06 Nov 2026',
          counselorName: 'Pak Budi, S.Pd.',
          isCompleted: false,
          violationPoints: 25,
        ),
        const CaseRecordModel(
          id: '#BK-2026-048',
          studentName: 'Fajar Nugraha',
          studentNisn: '0107462918',
          studentClass: 'Kelas VIII-B',
          caseCategory: 'Perilaku & Ketertiban',
          caseTitle: 'Terlibat Tawuran / Perkelahian Antar Pelajar',
          incidentTime: 'Jumat, 06 Nov 2026 • 14:30 WIB',
          incidentLocation: 'Pertigaan Jalan Stasiun Pabuaran',
          chronology:
              'Terlibat perselisihan dan perkelahian fisik sepulang sekolah akibat kesalahpahaman antarkelompok siswa di media sosial. Berhasil dilerai warga dan guru piket.',
          handling:
              'Mediasi restoratif bersama orang tua siswa kedua belah pihak, pembinaan intensif kepribadian bersama Guru BK, dan penetapan masa pemantauan perilaku selama 30 hari.',
          handlingDate: 'Sabtu, 07 Nov 2026',
          counselorName: 'Pak Budi, S.Pd.',
          isCompleted: false,
          violationPoints: 50,
        ),
        const CaseRecordModel(
          id: '#BK-2026-042',
          studentName: 'Rizky Pratama',
          studentNisn: '0094821034',
          studentClass: 'Kelas IX-B',
          caseCategory: 'Tata Tertib Seragam',
          caseTitle: 'Kelengkapan Atribut Seragam Sekolah',
          incidentTime: 'Senin, 19 Okt 2026 • 07:15 WIB',
          incidentLocation: 'Gerbang Utama & Lapangan Upacara',
          chronology:
              'Saat pemeriksaan kerapian pagi sebelum apel Senin pukul 07:15 WIB, ananda tercatat belum mengenakan topi dan dasi seragam sesuai tata tertib sekolah. Ananda bersikap sopan dan menyampaikan atribut tertinggal di rumah.',
          handling:
              'Telah diberikan arahan positif mengenai kebiasaan menyiapkan perlengkapan sekolah pada malam hari. Pada pemantauan hari berikutnya, ananda hadir tepat waktu dengan atribut lengkap dan rapi.',
          handlingDate: 'Selasa, 20 Okt 2026',
          counselorName: 'Ibu Dra. Nurhayati, S.Pd.',
          isCompleted: true,
          violationPoints: 15,
        ),
        const CaseRecordModel(
          id: '#BK-2026-039',
          studentName: 'Alya Putri Maharani',
          studentNisn: '0103948219',
          studentClass: 'Kelas VIII-A',
          caseCategory: 'Kedisiplinan',
          caseTitle: 'Keterlambatan Masuk Sekolah Berturut-turut',
          incidentTime: 'Rabu, 28 Okt 2026 • 07:35 WIB',
          incidentLocation: 'Pintu Masuk Gerbang Depan Sekolah',
          chronology:
              'Siswa tiba di sekolah pukul 07:35 WIB (terlambat 35 menit) sebanyak 3 hari berturut-turut dikarenakan kendala transportasi pagi.',
          handling:
              'Konseling manajemen waktu pagi, koordinasi dengan wali murid untuk penyesuaian moda transportasi, serta pemberian tugas pembiasaan disiplin mandiri.',
          handlingDate: 'Kamis, 29 Okt 2026',
          counselorName: 'Pak Budi, S.Pd.',
          isCompleted: true,
          violationPoints: 15,
        ),
      ];
}
