import 'package:pocketbase/pocketbase.dart';

/// Model Data Siswa (`06 • Data Siswa (SRS-F-003)`)
/// Terhubung ke collection `students` di PocketBase.
class StudentDataModel {
  final String id;
  final String name;
  final String nis;
  final String nisn;
  final String className;
  final String gradeLevel;
  final String gender;
  final String guardianId;
  final String guardianName;
  final String guardianRelation;
  final String guardianPhone;
  final String address;
  final int totalPoints;

  const StudentDataModel({
    this.id = '',
    required this.name,
    required this.nis,
    required this.nisn,
    required this.className,
    required this.gradeLevel,
    required this.gender,
    this.guardianId = '',
    required this.guardianName,
    required this.guardianRelation,
    required this.guardianPhone,
    required this.address,
    this.totalPoints = 0,
  });

  StudentDataModel copyWith({
    String? id,
    String? name,
    String? nis,
    String? nisn,
    String? className,
    String? gradeLevel,
    String? gender,
    String? guardianId,
    String? guardianName,
    String? guardianRelation,
    String? guardianPhone,
    String? address,
    int? totalPoints,
  }) {
    return StudentDataModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nis: nis ?? this.nis,
      nisn: nisn ?? this.nisn,
      className: className ?? this.className,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      gender: gender ?? this.gender,
      guardianId: guardianId ?? this.guardianId,
      guardianName: guardianName ?? this.guardianName,
      guardianRelation: guardianRelation ?? this.guardianRelation,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      address: address ?? this.address,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }

  factory StudentDataModel.fromRecord(RecordModel r) {
    final expandedGuardians = r.get<List<RecordModel>>('expand.guardian');
    final guardianRec =
        expandedGuardians.isNotEmpty ? expandedGuardians.first : null;

    final gName = r.getStringValue('guardian_name').isNotEmpty
        ? r.getStringValue('guardian_name')
        : (guardianRec?.getStringValue('name') ?? '-');
    final gPhone = r.getStringValue('guardian_phone').isNotEmpty
        ? r.getStringValue('guardian_phone')
        : (guardianRec?.getStringValue('phone') ?? '-');

    return StudentDataModel(
      id: r.id,
      name: r.getStringValue('name'),
      nis: r.getStringValue('nis'),
      nisn: r.getStringValue('nisn'),
      className: r.getStringValue('class_name'),
      gradeLevel: r.getStringValue('grade_level'),
      gender: r.getStringValue('gender'),
      guardianId: r.getStringValue('guardian'),
      guardianName: gName,
      guardianRelation: r.getStringValue('guardian_relation').isNotEmpty
          ? r.getStringValue('guardian_relation')
          : 'Orang Tua / Wali',
      guardianPhone: gPhone,
      address: r.getStringValue('address'),
      totalPoints: r.getIntValue('total_points'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nis': nis,
      'nisn': nisn,
      'class_name': className,
      'grade_level': gradeLevel,
      'gender': gender,
      if (guardianId.isNotEmpty) 'guardian': guardianId,
      'guardian_name': guardianName,
      'guardian_relation': guardianRelation,
      'guardian_phone': guardianPhone,
      'address': address,
      'total_points': totalPoints,
    };
  }

  static List<StudentDataModel> get defaultStudents => const [
        StudentDataModel(
          id: 'std-1',
          name: 'Rizky Pratama',
          nis: '242509042',
          nisn: '0094821034',
          className: 'Kelas IX-B',
          gradeLevel: 'Kelas IX',
          gender: 'Laki-laki',
          guardianName: 'Bapak Hendra Pratama',
          guardianRelation: 'Ayah Kandung',
          guardianPhone: '0812-8492-1034',
          address: 'Jl. Raya Pabuaran No. 18, Kec. Pabuaran, Subang',
          totalPoints: 25,
        ),
        StudentDataModel(
          id: 'std-2',
          name: 'Alya Putri Maharani',
          nis: '252608014',
          nisn: '0103948219',
          className: 'Kelas VIII-A',
          gradeLevel: 'Kelas VIII',
          gender: 'Perempuan',
          guardianName: 'Ibu Dewi Maharani',
          guardianRelation: 'Ibu Kandung',
          guardianPhone: '0813-9281-4420',
          address: 'Perum Griya Pabuaran Asri Blok B2 No. 7, Subang',
          totalPoints: 15,
        ),
        StudentDataModel(
          id: 'std-3',
          name: 'Dimas Aditya Saputra',
          nis: '262707088',
          nisn: '0112839401',
          className: 'Kelas VII-C',
          gradeLevel: 'Kelas VII',
          gender: 'Laki-laki',
          guardianName: 'Bapak Agus Saputra',
          guardianRelation: 'Ayah Kandung',
          guardianPhone: '0857-2104-8831',
          address: 'Dusun Krajan RT 04/RW 02, Desa Pabuaran, Subang',
          totalPoints: 25,
        ),
        StudentDataModel(
          id: 'std-4',
          name: 'Nabila Zahra Aulia',
          nis: '242509019',
          nisn: '0098374612',
          className: 'Kelas IX-A',
          gradeLevel: 'Kelas IX',
          gender: 'Perempuan',
          guardianName: 'Ibu Rina Kusumawati',
          guardianRelation: 'Ibu Kandung',
          guardianPhone: '0812-3390-7162',
          address: 'Jl. Stasiun Pabuaran No. 45, Kec. Pabuaran, Subang',
          totalPoints: 0,
        ),
        StudentDataModel(
          id: 'std-5',
          name: 'Fajar Nugraha',
          nis: '252608053',
          nisn: '0107462918',
          className: 'Kelas VIII-B',
          gradeLevel: 'Kelas VIII',
          gender: 'Laki-laki',
          guardianName: 'Bapak Dedi Nugraha',
          guardianRelation: 'Ayah Kandung',
          guardianPhone: '0878-4512-9087',
          address: 'Kampung Sukamaju RT 02/RW 05, Desa Siluman, Pabuaran',
          totalPoints: 50,
        ),
        StudentDataModel(
          id: 'std-6',
          name: 'Salsabila Khairunnisa',
          nis: '262707021',
          nisn: '0115920384',
          className: 'Kelas VII-A',
          gradeLevel: 'Kelas VII',
          gender: 'Perempuan',
          guardianName: 'Ibu Siti Nurjanah',
          guardianRelation: 'Ibu Kandung',
          guardianPhone: '0821-6743-2910',
          address: 'Desa Salamjaya RT 01/RW 03, Kec. Pabuaran, Subang',
          totalPoints: 0,
        ),
      ];
}
