import 'package:pocketbase/pocketbase.dart';
import '../core/pb_client.dart';
import 'student_model.dart';

/// Model Akun Pengguna Orang Tua (`13 • Kelola Pengguna (SRS-F-007)`)
/// Menyimpan identitas akun orang tua/wali, kredensial, kontak, serta data siswa asuh.
/// Mendukung satu orang tua dengan banyak anak (relasi `students.guardian`).
class UserAccountModel {
  final String id;
  final String fullName; // Nama Orang Tua / Wali
  final String username;
  final String email;
  final String phone;
  final String studentChildName; // Nama Siswa Asuh (atau ringkasan jika >1 anak)
  final String studentClass; // Kelas Siswa
  final String studentNisn; // NISN Siswa
  final bool isActive;
  final String createdAt;
  final List<StudentDataModel> children;

  const UserAccountModel({
    required this.id,
    required this.fullName,
    required this.username,
    this.email = '',
    this.phone = '',
    required this.studentChildName,
    required this.studentClass,
    required this.studentNisn,
    this.isActive = true,
    this.createdAt = '01 Nov 2026',
    this.children = const [],
  });

  /// Gabungan kontak untuk pencarian / ringkasan tampilan.
  String get emailOrPhone => [email, phone].where((e) => e.isNotEmpty).join(' / ');

  /// Email placeholder otomatis (tanpa email asli) tidak ditampilkan di form.
  bool get hasRealEmail => email.isNotEmpty && !email.endsWith('@ortu.ebk.sch.id');

  UserAccountModel copyWith({
    String? id,
    String? fullName,
    String? username,
    String? email,
    String? phone,
    String? studentChildName,
    String? studentClass,
    String? studentNisn,
    bool? isActive,
    String? createdAt,
    List<StudentDataModel>? children,
  }) {
    return UserAccountModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      studentChildName: studentChildName ?? this.studentChildName,
      studentClass: studentClass ?? this.studentClass,
      studentNisn: studentNisn ?? this.studentNisn,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      children: children ?? this.children,
    );
  }

  factory UserAccountModel.fromRecord(
    RecordModel r, {
    List<StudentDataModel> linkedChildren = const [],
  }) {
    final firstChild = linkedChildren.isNotEmpty ? linkedChildren.first : null;
    final extraCount = linkedChildren.length > 1 ? linkedChildren.length - 1 : 0;
    final childNameDisplay = firstChild == null
        ? 'Belum tertaut siswa'
        : (extraCount > 0
            ? '${firstChild.name} (+$extraCount anak)'
            : firstChild.name);

    final email = r.getStringValue('email');
    final phone = r.getStringValue('phone');

    final rawCreated = r.getStringValue('created');
    final parsedCreated = DateTime.tryParse(rawCreated);
    final createdText = parsedCreated != null
        ? PbClient.formatDateShort(parsedCreated)
        : '01 Nov 2026';

    return UserAccountModel(
      id: r.id,
      fullName: r.getStringValue('name'),
      username: r.getStringValue('username').isNotEmpty
          ? r.getStringValue('username')
          : email.split('@').first,
      email: email,
      phone: phone,
      studentChildName: childNameDisplay,
      studentClass: firstChild?.className ?? '-',
      studentNisn: firstChild?.nisn ?? '-',
      isActive: r.getBoolValue('is_active'),
      createdAt: createdText,
      children: linkedChildren,
    );
  }

  static List<UserAccountModel> getInitialAccounts() {
    return [
      const UserAccountModel(
        id: 'ORTU-001',
        fullName: 'Bapak Hendra Pratama',
        username: 'hendra.pratama',
        email: 'hendra.pratama@gmail.com',
        studentChildName: 'Rizky Pratama',
        studentClass: 'Kelas IX-B',
        studentNisn: '0094821034',
        isActive: true,
        createdAt: '16 Jul 2026',
      ),
      const UserAccountModel(
        id: 'ORTU-002',
        fullName: 'Ibu Dewi Maharani',
        username: 'dewi.maharani',
        email: 'dewi.maharani@yahoo.com',
        studentChildName: 'Alya Putri Maharani',
        studentClass: 'Kelas VIII-A',
        studentNisn: '0103948219',
        isActive: true,
        createdAt: '18 Jul 2026',
      ),
      const UserAccountModel(
        id: 'ORTU-003',
        fullName: 'Bapak Agus Saputra',
        username: 'agus.saputra',
        email: 'agus.saputra@gmail.com',
        studentChildName: 'Dimas Aditya Saputra',
        studentClass: 'Kelas VII-C',
        studentNisn: '0112839401',
        isActive: true,
        createdAt: '19 Jul 2026',
      ),
      const UserAccountModel(
        id: 'ORTU-004',
        fullName: 'Ibu Rina Kusumawati',
        username: 'rina.kusumawati',
        email: 'rina.kusumawati@gmail.com',
        studentChildName: 'Nabila Zahra Aulia',
        studentClass: 'Kelas IX-A',
        studentNisn: '0098374612',
        isActive: true,
        createdAt: '20 Jul 2026',
      ),
      const UserAccountModel(
        id: 'ORTU-005',
        fullName: 'Bapak Dedi Nugraha',
        username: 'dedi.nugraha',
        email: 'dedi.nugraha@gmail.com',
        studentChildName: 'Fajar Nugraha',
        studentClass: 'Kelas VIII-B',
        studentNisn: '0107462918',
        isActive: true,
        createdAt: '21 Jul 2026',
      ),
      const UserAccountModel(
        id: 'ORTU-006',
        fullName: 'Ibu Siti Nurjanah',
        username: 'siti.nurjanah',
        email: 'siti.nurjanah@gmail.com',
        studentChildName: 'Salsabila Khairunnisa',
        studentClass: 'Kelas VII-A',
        studentNisn: '0115920384',
        isActive: false,
        createdAt: '22 Jul 2026',
      ),
    ];
  }
}
