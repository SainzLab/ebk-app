/// Model Data Kasus Pelanggaran Siswa (`SRS-F-004`, `SRS-F-008`, `SRS-F-009`)
/// Menyimpan informasi jenis kasus (membolos, tawuran, dll), waktu kejadian,
/// tempat kejadian, deskripsi kronologi, serta catatan penanganan oleh Guru BK.
class CaseRecordModel {
  final String id;
  final String studentName;
  final String studentNisn;
  final String studentClass;
  final String caseCategory;
  final String caseTitle;
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
    required this.studentName,
    required this.studentNisn,
    required this.studentClass,
    required this.caseCategory,
    required this.caseTitle,
    required this.incidentTime,
    required this.incidentLocation,
    required this.chronology,
    required this.handling,
    required this.handlingDate,
    required this.counselorName,
    required this.isCompleted,
    required this.violationPoints,
  });

  CaseRecordModel copyWith({
    String? id,
    String? studentName,
    String? studentNisn,
    String? studentClass,
    String? caseCategory,
    String? caseTitle,
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
      studentName: studentName ?? this.studentName,
      studentNisn: studentNisn ?? this.studentNisn,
      studentClass: studentClass ?? this.studentClass,
      caseCategory: caseCategory ?? this.caseCategory,
      caseTitle: caseTitle ?? this.caseTitle,
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
