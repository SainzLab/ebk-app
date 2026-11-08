/// Model Catatan & Riwayat Konsultasi Orang Tua (`09 • Konsultasi Orang Tua (SRS-F-006)`)
/// Menyimpan informasi orang tua/wali, siswa, waktu, metode komunikasi, topik, hasil diskusi, dan tindak lanjut.
class ParentConsultationModel {
  final String id;
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

  const ParentConsultationModel({
    required this.id,
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
  });

  ParentConsultationModel copyWith({
    String? id,
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
  }) {
    return ParentConsultationModel(
      id: id ?? this.id,
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
    );
  }

  String get statusLabel => isCompleted ? 'Selesai' : 'Dalam Proses';

  static List<ParentConsultationModel> getInitialConsultations() {
    return [
      const ParentConsultationModel(
        id: 'KOP-01',
        parentName: 'Bapak Hendra Pratama',
        studentName: 'Rizky Pratama',
        studentClass: 'Kelas IX-B',
        studentNisn: '0081234567',
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
        parentName: 'Ibu Ratna Dewi',
        studentName: 'Alya Putri Maharani',
        studentClass: 'Kelas VIII-A',
        studentNisn: '0098765432',
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
        parentName: 'Bapak Suryadi',
        studentName: 'Dimas Aditya Saputra',
        studentClass: 'Kelas VII-C',
        studentNisn: '0105678912',
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
        parentName: 'Ibu Sri Wahyuni',
        studentName: 'Farhan Maulana',
        studentClass: 'Kelas IX-A',
        studentNisn: '0087654321',
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
        parentName: 'Bapak Agus Santoso',
        studentName: 'Budi Santoso',
        studentClass: 'Kelas VII-A',
        studentNisn: '0103456789',
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
