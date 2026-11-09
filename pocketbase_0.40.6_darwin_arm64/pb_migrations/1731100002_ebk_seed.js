/// <reference path="../pb_data/types.d.ts" />

migrate((app) => {
  const catCol = app.findCollectionByNameOrId("case_categories");
  const studentCol = app.findCollectionByNameOrId("students");
  const caseCol = app.findCollectionByNameOrId("cases");
  const counselingCol = app.findCollectionByNameOrId("counseling_sessions");
  const parentConsCol = app.findCollectionByNameOrId("parent_consultations");
  const usersCol = app.findCollectionByNameOrId("users");

  // 1. Seed Case Categories
  const categoriesData = [
    {
      name: "Kedisiplinan",
      default_points: 25,
      default_title: "Membolos Sekolah saat Jam Efektif",
      default_location: "Warung Kopi Belakang Pagar Sekolah",
    },
    {
      name: "Perilaku & Ketertiban",
      default_points: 50,
      default_title: "Terlibat Tawuran / Perkelahian Antar Pelajar",
      default_location: "Pertigaan Jalan Stasiun Pabuaran",
    },
    {
      name: "Tata Tertib Seragam",
      default_points: 15,
      default_title: "Kelengkapan Atribut Seragam Sekolah",
      default_location: "Gerbang Utama & Lapangan Upacara",
    },
    {
      name: "Kedisiplinan Waktu",
      default_points: 10,
      default_title: "Terlambat Hadir Apel Pagi",
      default_location: "Gerbang Utama Sekolah",
    },
    {
      name: "Tata Tertib & Norma",
      default_points: 35,
      default_title: "Merokok / Menggunakan Vape di Area Sekolah",
      default_location: "Area Kamar Mandi Belakang Lab Komputer",
    },
    {
      name: "Perilaku & Sikap",
      default_points: 40,
      default_title: "Perundungan (Bullying) & Tindakan Tidak Sopan",
      default_location: "Koridor Kelas & Area Kantin",
    },
  ];

  const categoryMap = {};
  for (const c of categoriesData) {
    const rec = new Record(catCol);
    rec.set("name", c.name);
    rec.set("default_points", c.default_points);
    rec.set("default_title", c.default_title);
    rec.set("default_location", c.default_location);
    app.save(rec);
    categoryMap[c.name] = rec.id;
  }

  // 2. Seed Parent Accounts (role: orang_tua) & Students
  const parentsAndStudents = [
    {
      parent: {
        name: "Bapak Hendra Pratama",
        username: "hendra.pratama",
        email: "hendra.pratama@gmail.com",
        phone: "0812-8492-1034",
        is_active: true,
      },
      student: {
        name: "Rizky Pratama",
        nis: "242509042",
        nisn: "0094821034",
        class_name: "Kelas IX-B",
        grade_level: "Kelas IX",
        gender: "Laki-laki",
        guardian_name: "Bapak Hendra Pratama",
        guardian_relation: "Ayah Kandung",
        guardian_phone: "0812-8492-1034",
        address: "Jl. Raya Pabuaran No. 18, Kec. Pabuaran, Subang",
        total_points: 25,
      },
    },
    {
      parent: {
        name: "Ibu Dewi Maharani",
        username: "dewi.maharani",
        email: "dewi.maharani@yahoo.com",
        phone: "0813-9281-4420",
        is_active: true,
      },
      student: {
        name: "Alya Putri Maharani",
        nis: "252608014",
        nisn: "0103948219",
        class_name: "Kelas VIII-A",
        grade_level: "Kelas VIII",
        gender: "Perempuan",
        guardian_name: "Ibu Dewi Maharani",
        guardian_relation: "Ibu Kandung",
        guardian_phone: "0813-9281-4420",
        address: "Perum Griya Pabuaran Asri Blok B2 No. 7, Subang",
        total_points: 15,
      },
    },
    {
      parent: {
        name: "Bapak Agus Saputra",
        username: "agus.saputra",
        email: "agus.saputra@gmail.com",
        phone: "0857-2104-8831",
        is_active: true,
      },
      student: {
        name: "Dimas Aditya Saputra",
        nis: "262707088",
        nisn: "0112839401",
        class_name: "Kelas VII-C",
        grade_level: "Kelas VII",
        gender: "Laki-laki",
        guardian_name: "Bapak Agus Saputra",
        guardian_relation: "Ayah Kandung",
        guardian_phone: "0857-2104-8831",
        address: "Dusun Krajan RT 04/RW 02, Desa Pabuaran, Subang",
        total_points: 25,
      },
    },
    {
      parent: {
        name: "Ibu Rina Kusumawati",
        username: "rina.kusumawati",
        email: "rina.kusumawati@gmail.com",
        phone: "0812-3390-7162",
        is_active: true,
      },
      student: {
        name: "Nabila Zahra Aulia",
        nis: "242509019",
        nisn: "0098374612",
        class_name: "Kelas IX-A",
        grade_level: "Kelas IX",
        gender: "Perempuan",
        guardian_name: "Ibu Rina Kusumawati",
        guardian_relation: "Ibu Kandung",
        guardian_phone: "0812-3390-7162",
        address: "Jl. Stasiun Pabuaran No. 45, Kec. Pabuaran, Subang",
        total_points: 0,
      },
    },
    {
      parent: {
        name: "Bapak Dedi Nugraha",
        username: "dedi.nugraha",
        email: "dedi.nugraha@gmail.com",
        phone: "0878-4512-9087",
        is_active: true,
      },
      student: {
        name: "Fajar Nugraha",
        nis: "252608053",
        nisn: "0107462918",
        class_name: "Kelas VIII-B",
        grade_level: "Kelas VIII",
        gender: "Laki-laki",
        guardian_name: "Bapak Dedi Nugraha",
        guardian_relation: "Ayah Kandung",
        guardian_phone: "0878-4512-9087",
        address: "Kampung Sukamaju RT 02/RW 05, Desa Siluman, Pabuaran",
        total_points: 50,
      },
    },
    {
      parent: {
        name: "Ibu Siti Nurjanah",
        username: "siti.nurjanah",
        email: "siti.nurjanah@gmail.com",
        phone: "0821-6743-2910",
        is_active: false,
      },
      student: {
        name: "Salsabila Khairunnisa",
        nis: "262707021",
        nisn: "0115920384",
        class_name: "Kelas VII-A",
        grade_level: "Kelas VII",
        gender: "Perempuan",
        guardian_name: "Ibu Siti Nurjanah",
        guardian_relation: "Ibu Kandung",
        guardian_phone: "0821-6743-2910",
        address: "Desa Salamjaya RT 01/RW 03, Kec. Pabuaran, Subang",
        total_points: 0,
      },
    },
  ];

  const studentByNisn = {};
  const parentByStudentNisn = {};

  for (const item of parentsAndStudents) {
    const pRec = new Record(usersCol);
    pRec.set("name", item.parent.name);
    pRec.set("username", item.parent.username);
    pRec.set("email", item.parent.email);
    pRec.set("emailVisibility", true);
    pRec.set("verified", true);
    pRec.set("role", "orang_tua");
    pRec.set("phone", item.parent.phone);
    pRec.set("position", "Orang Tua / Wali Siswa");
    pRec.set("is_active", item.parent.is_active);
    pRec.set("notify_email", true);
    pRec.setPassword("password123");
    app.save(pRec);

    const sRec = new Record(studentCol);
    sRec.set("name", item.student.name);
    sRec.set("nis", item.student.nis);
    sRec.set("nisn", item.student.nisn);
    sRec.set("class_name", item.student.class_name);
    sRec.set("grade_level", item.student.grade_level);
    sRec.set("gender", item.student.gender);
    sRec.set("guardian", pRec.id);
    sRec.set("guardian_name", item.student.guardian_name);
    sRec.set("guardian_relation", item.student.guardian_relation);
    sRec.set("guardian_phone", item.student.guardian_phone);
    sRec.set("address", item.student.address);
    sRec.set("total_points", item.student.total_points);
    app.save(sRec);

    studentByNisn[item.student.nisn] = sRec.id;
    parentByStudentNisn[item.student.nisn] = pRec.id;
  }

  // 3. Seed Cases
  const casesData = [
    {
      code: "#BK-2026-001",
      nisn: "0112839401",
      category: "Kedisiplinan",
      title: "Membolos Sekolah saat Jam Efektif",
      incident_time: "2026-11-05 03:15:00.000Z",
      incident_time_text: "Kamis, 05 Nov 2026 • 10:15 WIB",
      location: "Warung Kopi Belakang Pagar Sekolah",
      chronology:
        "Siswa meninggalkan lingkungan sekolah melompati pagar samping saat pergantian jam pelajaran ketiga tanpa izin piket sekolah. Ditemukan oleh tim ketertiban sekolah bersama dua rekan.",
      handling:
        "Pemanggilan siswa ke Ruang BK untuk konseling individual, penyampaian notifikasi presensi ke orang tua/wali, serta penandatanganan komitmen tidak mengulangi.",
      handling_date: "2026-11-06 01:00:00.000Z",
      handling_date_text: "Jumat, 06 Nov 2026",
      counselor_name: "Pak Budi, S.Pd.",
      is_completed: false,
      points: 25,
    },
    {
      code: "#BK-2026-002",
      nisn: "0107462918",
      category: "Perilaku & Ketertiban",
      title: "Terlibat Tawuran / Perkelahian Antar Pelajar",
      incident_time: "2026-11-06 07:30:00.000Z",
      incident_time_text: "Jumat, 06 Nov 2026 • 14:30 WIB",
      location: "Pertigaan Jalan Stasiun Pabuaran",
      chronology:
        "Terlibat perselisihan dan perkelahian fisik sepulang sekolah akibat kesalahpahaman antarkelompok siswa di media sosial. Berhasil dilerai warga dan guru piket.",
      handling:
        "Mediasi restoratif bersama orang tua siswa kedua belah pihak, pembinaan intensif kepribadian bersama Guru BK, dan penetapan masa pemantauan perilaku selama 30 hari.",
      handling_date: "2026-11-07 01:00:00.000Z",
      handling_date_text: "Sabtu, 07 Nov 2026",
      counselor_name: "Pak Budi, S.Pd.",
      is_completed: false,
      points: 50,
    },
    {
      code: "#BK-2026-003",
      nisn: "0094821034",
      category: "Tata Tertib Seragam",
      title: "Kelengkapan Atribut Seragam Sekolah",
      incident_time: "2026-10-19 00:15:00.000Z",
      incident_time_text: "Senin, 19 Okt 2026 • 07:15 WIB",
      location: "Gerbang Utama & Lapangan Upacara",
      chronology:
        "Saat pemeriksaan kerapian pagi sebelum apel Senin pukul 07:15 WIB, ananda tercatat belum mengenakan topi dan dasi seragam sesuai tata tertib sekolah. Ananda bersikap sopan dan menyampaikan atribut tertinggal di rumah.",
      handling:
        "Telah diberikan arahan positif mengenai kebiasaan menyiapkan perlengkapan sekolah pada malam hari. Pada pemantauan hari berikutnya, ananda hadir tepat waktu dengan atribut lengkap dan rapi.",
      handling_date: "2026-10-20 01:00:00.000Z",
      handling_date_text: "Selasa, 20 Okt 2026",
      counselor_name: "Ibu Dra. Nurhayati, S.Pd.",
      is_completed: true,
      points: 15,
    },
    {
      code: "#BK-2026-004",
      nisn: "0103948219",
      category: "Kedisiplinan",
      title: "Keterlambatan Masuk Sekolah Berturut-turut",
      incident_time: "2026-10-28 00:35:00.000Z",
      incident_time_text: "Rabu, 28 Okt 2026 • 07:35 WIB",
      location: "Pintu Masuk Gerbang Depan Sekolah",
      chronology:
        "Siswa tiba di sekolah pukul 07:35 WIB (terlambat 35 menit) sebanyak 3 hari berturut-turut dikarenakan kendala transportasi pagi.",
      handling:
        "Konseling manajemen waktu pagi, koordinasi dengan wali murid untuk penyesuaian moda transportasi, serta pemberian tugas pembiasaan disiplin mandiri.",
      handling_date: "2026-10-29 01:00:00.000Z",
      handling_date_text: "Kamis, 29 Okt 2026",
      counselor_name: "Pak Budi, S.Pd.",
      is_completed: true,
      points: 15,
    },
    {
      code: "#BK-2026-005",
      nisn: "0094821034",
      category: "Kedisiplinan Waktu",
      title: "Terlambat Hadir Apel Pagi",
      incident_time: "2026-11-05 00:20:00.000Z",
      incident_time_text: "Kamis, 05 Nov 2026 • 07:20 WIB",
      location: "Gerbang Utama Sekolah",
      chronology:
        "Pendampingan manajemen waktu pagi bersama Guru BK & Wali Kelas.",
      handling:
        "Konseling kedisiplinan dan kesepakatan komitmen waktu bangun pagi.",
      handling_date: "2026-11-06 01:00:00.000Z",
      handling_date_text: "Jumat, 06 Nov 2026",
      counselor_name: "Ibu Dra. Nurhayati, S.Pd.",
      is_completed: false,
      points: 10,
    },
  ];

  for (const c of casesData) {
    const rec = new Record(caseCol);
    rec.set("code", c.code);
    rec.set("student", studentByNisn[c.nisn]);
    rec.set("category", categoryMap[c.category] || "");
    rec.set("category_name", c.category);
    rec.set("title", c.title);
    rec.set("incident_time", c.incident_time);
    rec.set("incident_time_text", c.incident_time_text);
    rec.set("location", c.location);
    rec.set("chronology", c.chronology);
    rec.set("handling", c.handling);
    rec.set("handling_date", c.handling_date);
    rec.set("handling_date_text", c.handling_date_text);
    rec.set("counselor_name", c.counselor_name);
    rec.set("is_completed", c.is_completed);
    rec.set("points", c.points);
    app.save(rec);
  }

  // 4. Seed Counseling Sessions
  const sessionsData = [
    {
      nisn: "0094821034",
      session_date: "2026-11-07 01:30:00.000Z",
      date_str: "Sabtu, 07 Nov 2026",
      day_index: 5,
      time_range: "08:30 – 09:15 WIB",
      counseling_type: "Individu",
      topic: "Pembinaan Disiplin & Manajemen Waktu Pagi",
      result_notes:
        "Siswa menyadari keterlambatan akibat kebiasaan tidur larut malam. Siswa bersedia menetapkan jam tidur mandiri maksimal pukul 21:30.",
      follow_up_plan:
        "Pemantauan buku presensi harian bersama wali kelas IX-B dan konfirmasi berkala kepada orang tua siswa selama dua pekan.",
      is_completed: false,
    },
    {
      nisn: "0103948219",
      session_date: "2026-11-07 03:00:00.000Z",
      date_str: "Sabtu, 07 Nov 2026",
      day_index: 5,
      time_range: "10:00 – 10:45 WIB",
      counseling_type: "Belajar / Akademik",
      topic: "Konseling Motivasi Belajar & Persiapan Ujian",
      result_notes:
        "Siswa mengalami kecemasan akademik menghadapi asesmen akhir. Telah diberikan strategi teknik relaksasi serta manajemen waktu belajar bertahap.",
      follow_up_plan:
        "Pemberian modul jadwal belajar terstruktur dan evaluasi perkembangan minat belajar pada sesi konsultasi lanjutan pekan depan.",
      is_completed: false,
    },
    {
      nisn: "0112839401",
      session_date: "2026-11-07 06:00:00.000Z",
      date_str: "Sabtu, 07 Nov 2026",
      day_index: 5,
      time_range: "13:00 – 13:45 WIB",
      counseling_type: "Sosial / Perilaku",
      topic: "Adaptasi Lingkungan Pergaulan Kelas Baru",
      result_notes:
        "Siswa mulai membuka komunikasi dan berpartisipasi aktif dalam kegiatan kerja kelompok setelah sesi pembinaan adaptasi sosial selesai.",
      follow_up_plan:
        "Koordinasi dengan pengurus OSIS dan wali kelas VII-C untuk melibatkan siswa dalam kegiatan ekstrakurikuler minat bakat.",
      is_completed: true,
    },
    {
      nisn: "0098374612",
      session_date: "2026-11-02 02:00:00.000Z",
      date_str: "Senin, 02 Nov 2026",
      day_index: 0,
      time_range: "09:00 – 09:45 WIB",
      counseling_type: "Karir",
      topic: "Eksplorasi Minat Lanjutan SMA/SMK",
      result_notes:
        "Siswa telah menetapkan peminatan jurusan Teknik Komputer Jaringan di SMK Negeri rujukan.",
      follow_up_plan:
        "Pemberian informasi syarat pendaftaran dan jalur prestasi.",
      is_completed: true,
    },
    {
      nisn: "0107462918",
      session_date: "2026-11-04 04:15:00.000Z",
      date_str: "Rabu, 04 Nov 2026",
      day_index: 2,
      time_range: "11:15 – 12:00 WIB",
      counseling_type: "Kelompok",
      topic: "Bimbingan Kelompok: Manajemen Emosi Remaja",
      result_notes:
        "Peserta kelompok aktif mendiskusikan studi kasus cara meredam perselisihan pertemanan.",
      follow_up_plan: "Refleksi jurnal harian pertemanan selama 1 pekan.",
      is_completed: true,
    },
    {
      nisn: "0115920384",
      session_date: "2026-11-05 01:00:00.000Z",
      date_str: "Kamis, 05 Nov 2026",
      day_index: 3,
      time_range: "08:00 – 08:45 WIB",
      counseling_type: "Individu",
      topic: "Kedisiplinan Kehadiran Pagi",
      result_notes:
        "Kesepakatan jadwal bangun pagi dan pendampingan orang tua.",
      follow_up_plan: "Pengecekan absensi kelas VII-A setiap hari Jumat.",
      is_completed: false,
    },
  ];

  for (const s of sessionsData) {
    const rec = new Record(counselingCol);
    rec.set("student", studentByNisn[s.nisn]);
    rec.set("session_date", s.session_date);
    rec.set("date_str", s.date_str);
    rec.set("day_index", s.day_index);
    rec.set("time_range", s.time_range);
    rec.set("counseling_type", s.counseling_type);
    rec.set("topic", s.topic);
    rec.set("result_notes", s.result_notes);
    rec.set("follow_up_plan", s.follow_up_plan);
    rec.set("is_completed", s.is_completed);
    app.save(rec);
  }

  // 5. Seed Parent Consultations
  const consultationsData = [
    {
      nisn: "0094821034",
      parent_name: "Bapak Hendra Pratama",
      held_at: "2026-11-10 03:00:00.000Z",
      date_time_text: "Selasa, 10 Nov 2026 • 10:00 WIB",
      consultation_method: "Tatap Muka di Ruang BK",
      topic: "Evaluasi Kedisiplinan Jam Bangun Pagi & Istirahat di Rumah",
      discussion_summary:
        "Orang tua menyepakati pembatasan gawai pada pukul 21:00 dan memastikan siswa sarapan sebelum berangkat sekolah.",
      follow_up_plan:
        "Wali murid mengabari guru BK melalui grup WhatsApp jika siswa mengalami kendala bangun pagi.",
      is_completed: false,
    },
    {
      nisn: "0103948219",
      parent_name: "Ibu Dewi Maharani",
      held_at: "2026-11-09 06:30:00.000Z",
      date_time_text: "Senin, 09 Nov 2026 • 13:30 WIB",
      consultation_method: "Panggilan Telepon / WA",
      topic: "Dukungan Persiapan Asesmen Akademik & Minat Belajar",
      discussion_summary:
        "Pemberian motivasi positif di rumah serta penataan ruang belajar yang kondusif tanpa tekanan nilai berlebih.",
      follow_up_plan:
        "Pemantauan nilai tugas mandiri siswa bersama guru mata pelajaran matematika.",
      is_completed: true,
    },
    {
      nisn: "0112839401",
      parent_name: "Bapak Agus Saputra",
      held_at: "2026-11-05 04:00:00.000Z",
      date_time_text: "Kamis, 05 Nov 2026 • 11:00 WIB",
      consultation_method: "Tatap Muka di Ruang BK",
      topic: "Adaptasi Perilaku dan Pergaulan Lingkungan Sekolah Baru",
      discussion_summary:
        "Orang tua berterima kasih atas perhatian pihak BK dan menyepakati pengawasan interaksi teman bermain di lingkungan rumah.",
      follow_up_plan:
        "Evaluasi perkembangan sosial Dimas dalam kegiatan ekstrakurikuler kepramukaan.",
      is_completed: true,
    },
    {
      nisn: "0098374612",
      parent_name: "Ibu Rina Kusumawati",
      held_at: "2026-11-04 07:00:00.000Z",
      date_time_text: "Rabu, 04 Nov 2026 • 14:00 WIB",
      consultation_method: "Home Visit / Kunjungan",
      topic: "Kunjungan Rumah Terkait Presensi & Peminatan Sekolah Lanjutan",
      discussion_summary:
        "Pihak sekolah berkunjung ke kediaman siswa untuk konfirmasi kondisi kesehatan keluarga dan arahan jalur afirmasi SMK Negeri rujukan.",
      follow_up_plan:
        "Pemberkasan dokumen pendaftaran kartu bantuan pendidikan bersama pihak TU.",
      is_completed: true,
    },
    {
      nisn: "0115920384",
      parent_name: "Ibu Siti Nurjanah",
      held_at: "2026-11-13 02:00:00.000Z",
      date_time_text: "Jumat, 13 Nov 2026 • 09:00 WIB",
      consultation_method: "Panggilan Telepon / WA",
      topic: "Konfirmasi Keterlambatan Masuk Sekolah Hari Senin",
      discussion_summary:
        "Pemberitahuan resmi mengenai jadwal jam masuk sekolah pukul 07:00 WIB dan aturan sanksi keterlambatan berulang.",
      follow_up_plan:
        "Wali murid mendampingi keberangkatan siswa naik angkutan pagi lebih awal.",
      is_completed: false,
    },
  ];

  for (const c of consultationsData) {
    const rec = new Record(parentConsCol);
    rec.set("parent", parentByStudentNisn[c.nisn]);
    rec.set("parent_name", c.parent_name);
    rec.set("student", studentByNisn[c.nisn]);
    rec.set("held_at", c.held_at);
    rec.set("date_time_text", c.date_time_text);
    rec.set("consultation_method", c.consultation_method);
    rec.set("topic", c.topic);
    rec.set("discussion_summary", c.discussion_summary);
    rec.set("follow_up_plan", c.follow_up_plan);
    rec.set("is_completed", c.is_completed);
    app.save(rec);
  }
}, (app) => {});
