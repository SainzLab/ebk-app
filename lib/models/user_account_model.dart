/// Model Akun Pengguna Orang Tua (`13 • Kelola Pengguna (SRS-F-007)`)
/// Menyimpan identitas akun orang tua/wali, kredensial, kontak, serta data siswa asuh.
class UserAccountModel {
  final String id;
  final String fullName; // Nama Orang Tua / Wali
  final String username;
  final String emailOrPhone;
  final String studentChildName; // Nama Siswa Asuh
  final String studentClass; // Kelas Siswa
  final String studentNisn; // NISN Siswa
  final bool isActive;
  final String createdAt;

  const UserAccountModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.emailOrPhone,
    required this.studentChildName,
    required this.studentClass,
    required this.studentNisn,
    this.isActive = true,
    this.createdAt = '01 Nov 2026',
  });

  UserAccountModel copyWith({
    String? id,
    String? fullName,
    String? username,
    String? emailOrPhone,
    String? studentChildName,
    String? studentClass,
    String? studentNisn,
    bool? isActive,
    String? createdAt,
  }) {
    return UserAccountModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      emailOrPhone: emailOrPhone ?? this.emailOrPhone,
      studentChildName: studentChildName ?? this.studentChildName,
      studentClass: studentClass ?? this.studentClass,
      studentNisn: studentNisn ?? this.studentNisn,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static List<UserAccountModel> getInitialAccounts() {
    return [
      const UserAccountModel(
        id: 'ORTU-001',
        fullName: 'Bapak Hendra Pratama',
        username: 'hendra.pratama',
        emailOrPhone: 'hendra.pratama@gmail.com',
        studentChildName: 'Rizky Pratama',
        studentClass: 'Kelas IX-B',
        studentNisn: '0081234567',
        isActive: true,
        createdAt: '16 Jul 2026',
      ),
      const UserAccountModel(
        id: 'ORTU-002',
        fullName: 'Ibu Ratna Dewi',
        username: 'ratna.dewi',
        emailOrPhone: 'ratna.dewi@yahoo.com',
        studentChildName: 'Alya Putri Maharani',
        studentClass: 'Kelas VIII-A',
        studentNisn: '0098765432',
        isActive: true,
        createdAt: '18 Jul 2026',
      ),
      const UserAccountModel(
        id: 'ORTU-003',
        fullName: 'Bapak Suryadi',
        username: 'suryadi.bk',
        emailOrPhone: 'suryadi77@gmail.com',
        studentChildName: 'Dimas Aditya Saputra',
        studentClass: 'Kelas VII-C',
        studentNisn: '0105678912',
        isActive: true,
        createdAt: '19 Jul 2026',
      ),
      const UserAccountModel(
        id: 'ORTU-004',
        fullName: 'Ibu Sri Wahyuni',
        username: 'sri.wahyuni',
        emailOrPhone: 'sri.wahyuni@gmail.com',
        studentChildName: 'Farhan Maulana',
        studentClass: 'Kelas IX-A',
        studentNisn: '0087654321',
        isActive: true,
        createdAt: '20 Jul 2026',
      ),
      const UserAccountModel(
        id: 'ORTU-005',
        fullName: 'Ibu Maryam Hasanah',
        username: 'maryam.h',
        emailOrPhone: 'maryam.h@gmail.com',
        studentChildName: 'Siti Nurhaliza',
        studentClass: 'Kelas VIII-B',
        studentNisn: '0091238901',
        isActive: true,
        createdAt: '21 Jul 2026',
      ),
      const UserAccountModel(
        id: 'ORTU-006',
        fullName: 'Bapak Agus Santoso',
        username: 'agus.santoso',
        emailOrPhone: 'agus.santoso@gmail.com',
        studentChildName: 'Budi Santoso',
        studentClass: 'Kelas VII-A',
        studentNisn: '0103456789',
        isActive: false,
        createdAt: '22 Jul 2026',
      ),
    ];
  }
}
