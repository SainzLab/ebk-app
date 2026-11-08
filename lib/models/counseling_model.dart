/// Model Layanan Konseling (`08 • Jadwal Konseling (SRS-F-005)`)
/// Menyimpan informasi sesi, jenis konseling, hasil evaluasi, tindak lanjut, dan status kasus.
class CounselingModel {
  final String id;
  final String studentName;
  final String studentClass;
  final String studentNisn;
  final String dateStr;
  final int dayIndex; // 0: Sen, 1: Sel, 2: Rab, 3: Kam, 4: Jum, 5: Sab, 6: Min
  final String timeRange;
  final String counselingType; // 'Individu', 'Kelompok', 'Belajar / Akademik', 'Karir', 'Sosial / Perilaku'
  final String topic;
  final String resultNotes;
  final String followUpPlan;
  final bool isCompleted;

  const CounselingModel({
    required this.id,
    required this.studentName,
    required this.studentClass,
    required this.studentNisn,
    required this.dateStr,
    required this.dayIndex,
    required this.timeRange,
    required this.counselingType,
    required this.topic,
    this.resultNotes = '',
    this.followUpPlan = '',
    this.isCompleted = false,
  });

  CounselingModel copyWith({
    String? id,
    String? studentName,
    String? studentClass,
    String? studentNisn,
    String? dateStr,
    int? dayIndex,
    String? timeRange,
    String? counselingType,
    String? topic,
    String? resultNotes,
    String? followUpPlan,
    bool? isCompleted,
  }) {
    return CounselingModel(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      studentClass: studentClass ?? this.studentClass,
      studentNisn: studentNisn ?? this.studentNisn,
      dateStr: dateStr ?? this.dateStr,
      dayIndex: dayIndex ?? this.dayIndex,
      timeRange: timeRange ?? this.timeRange,
      counselingType: counselingType ?? this.counselingType,
      topic: topic ?? this.topic,
      resultNotes: resultNotes ?? this.resultNotes,
      followUpPlan: followUpPlan ?? this.followUpPlan,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Warna latar belakang badge status (hijau jika selesai, amber jika dalam proses)
  int get statusBgColorHex => isCompleted ? 0xFFDCFCE7 : 0xFFFEF3C7;

  /// Warna teks badge status
  int get statusTextColorHex => isCompleted ? 0xFF15803D : 0xFFB45309;

  /// Label teks status (tanpa dot)
  String get statusLabel => isCompleted ? 'Selesai' : 'Dalam Proses';

  /// Daftar data awal (mock) sesuai konteks SMPN 1 Pabuaran
  static List<CounselingModel> getInitialSessions() {
    return [
      const CounselingModel(
        id: 'KSL-01',
        studentName: 'Rizky Pratama',
        studentClass: 'Kelas IX-B',
        studentNisn: '0081234567',
        dateStr: 'Sabtu, 07 Nov 2026',
        dayIndex: 5,
        timeRange: '08:30 – 09:15 WIB',
        counselingType: 'Individu',
        topic: 'Pembinaan Disiplin & Manajemen Waktu Pagi',
        resultNotes:
            'Siswa menyadari keterlambatan akibat kebiasaan tidur larut malam. Siswa bersedia menetapkan jam tidur mandiri maksimal pukul 21:30.',
        followUpPlan:
            'Pemantauan buku presensi harian bersama wali kelas IX-B dan konfirmasi berkala kepada orang tua siswa selama dua pekan.',
        isCompleted: false,
      ),
      const CounselingModel(
        id: 'KSL-02',
        studentName: 'Alya Putri Maharani',
        studentClass: 'Kelas VIII-A',
        studentNisn: '0098765432',
        dateStr: 'Sabtu, 07 Nov 2026',
        dayIndex: 5,
        timeRange: '10:00 – 10:45 WIB',
        counselingType: 'Belajar / Akademik',
        topic: 'Konseling Motivasi Belajar & Persiapan Ujian',
        resultNotes:
            'Siswa mengalami kecemasan akademik menghadapi asesmen akhir. Telah diberikan strategi teknik relaksasi serta manajemen waktu belajar bertahap.',
        followUpPlan:
            'Pemberian modul jadwal belajar terstruktur dan evaluasi perkembangan minat belajar pada sesi konsultasi lanjutan pekan depan.',
        isCompleted: false,
      ),
      const CounselingModel(
        id: 'KSL-03',
        studentName: 'Dimas Aditya Saputra',
        studentClass: 'Kelas VII-C',
        studentNisn: '0105678912',
        dateStr: 'Sabtu, 07 Nov 2026',
        dayIndex: 5,
        timeRange: '13:00 – 13:45 WIB',
        counselingType: 'Sosial / Perilaku',
        topic: 'Adaptasi Lingkungan Pergaulan Kelas Baru',
        resultNotes:
            'Siswa mulai membuka komunikasi dan berpartisipasi aktif dalam kegiatan kerja kelompok setelah sesi pembinaan adaptasi sosial selesai.',
        followUpPlan:
            'Koordinasi dengan pengurus OSIS dan wali kelas VII-C untuk melibatkan siswa dalam kegiatan ekstrakurikuler minat bakat.',
        isCompleted: true,
      ),
      const CounselingModel(
        id: 'KSL-04',
        studentName: 'Farhan Maulana',
        studentClass: 'Kelas IX-A',
        studentNisn: '0087654321',
        dateStr: 'Senin, 02 Nov 2026',
        dayIndex: 0,
        timeRange: '09:00 – 09:45 WIB',
        counselingType: 'Karir',
        topic: 'Eksplorasi Minat Lanjutan SMA/SMK',
        resultNotes:
            'Siswa telah menetapkan peminatan jurusan Teknik Komputer Jaringan di SMK Negeri rujukan.',
        followUpPlan:
            'Pemberian informasi syarat pendaftaran dan jalur prestasi.',
        isCompleted: true,
      ),
      const CounselingModel(
        id: 'KSL-05',
        studentName: 'Siti Nurhaliza',
        studentClass: 'Kelas VIII-B',
        studentNisn: '0091238901',
        dateStr: 'Rabu, 04 Nov 2026',
        dayIndex: 2,
        timeRange: '11:15 – 12:00 WIB',
        counselingType: 'Kelompok',
        topic: 'Bimbingan Kelompok: Manajemen Emosi Remaja',
        resultNotes:
            'Peserta kelompok aktif mendiskusikan studi kasus cara meredam perselisihan pertemanan.',
        followUpPlan:
            'Refleksi jurnal harian pertemanan selama 1 pekan.',
        isCompleted: true,
      ),
      const CounselingModel(
        id: 'KSL-06',
        studentName: 'Budi Santoso',
        studentClass: 'Kelas VII-A',
        studentNisn: '0103456789',
        dateStr: 'Kamis, 05 Nov 2026',
        dayIndex: 3,
        timeRange: '08:00 – 08:45 WIB',
        counselingType: 'Individu',
        topic: 'Kedisiplinan Kehadiran Pagi',
        resultNotes:
            'Kesepakatan jadwal bangun pagi dan pendampingan orang tua.',
        followUpPlan:
            'Pengecekan absensi kelas VII-A setiap hari Jumat.',
        isCompleted: false,
      ),
    ];
  }
}
