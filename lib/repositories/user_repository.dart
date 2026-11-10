import 'package:pocketbase/pocketbase.dart';
import '../core/app_exception.dart';
import '../core/pb_client.dart';
import '../models/student_model.dart';
import '../models/user_account_model.dart';
import 'student_repository.dart';

class UserRepository {
  UserRepository._();
  static final UserRepository instance = UserRepository._();

  PocketBase get _pb => PbClient.instance;

  /// Ambil seluruh akun orang tua (`role = 'orang_tua'`) beserta daftar anak (`students.guardian`).
  Future<List<UserAccountModel>> getParentAccounts() async {
    try {
      final userRecords = await _pb.collection('users').getFullList(
            filter: "role = 'orang_tua'",
            sort: '-created',
          );
      final allStudents = await StudentRepository.instance.getStudents();

      final childrenByGuardian = <String, List<StudentDataModel>>{};
      for (final s in allStudents) {
        if (s.guardianId.isNotEmpty) {
          childrenByGuardian.putIfAbsent(s.guardianId, () => []).add(s);
        }
      }

      return userRecords.map((r) {
        final children = childrenByGuardian[r.id] ?? const [];
        return UserAccountModel.fromRecord(r, linkedChildren: children);
      }).toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Buat akun orang tua baru di `users` dan tautkan ke siswa di `students`.
  Future<UserAccountModel> createParentAccount({
    required UserAccountModel account,
    String password = 'password123',
    List<Map<String, String>>? students,
  }) async {
    try {
      final cleanUsername = account.username.trim();
      final rawEmail = account.email.trim();
      final emailValue =
          rawEmail.isNotEmpty ? rawEmail : '$cleanUsername@ortu.ebk.sch.id';
      final phoneValue = account.phone.trim();
      final effectivePassword =
          password.trim().length >= 8 ? password.trim() : 'password123';

      final createdUser = await _pb.collection('users').create(
        body: {
          'name': account.fullName.trim(),
          'username': cleanUsername,
          'email': emailValue,
          'emailVisibility': true,
          'password': effectivePassword,
          'passwordConfirm': effectivePassword,
          'role': 'orang_tua',
          'phone': phoneValue,
          'position': 'Orang Tua / Wali Siswa',
          'is_active': account.isActive,
          'notify_email': true,
        },
      );

      // Tautkan siswa ke akun orang tua ini (1 orang tua bisa punya banyak anak)
      await _linkStudents(
        students ??
            [
              {
                'child': account.studentChildName,
                'class': account.studentClass,
                'nisn': account.studentNisn,
              }
            ],
        guardianId: createdUser.id,
        guardianName: account.fullName,
      );

      final children = await StudentRepository.instance.getStudents(
        filter: "guardian = '${createdUser.id}'",
      );
      return UserAccountModel.fromRecord(createdUser, linkedChildren: children);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Perbarui akun orang tua dan tautan siswa.
  Future<UserAccountModel> updateParentAccount({
    required UserAccountModel account,
    String? newPassword,
    List<Map<String, String>>? students,
  }) async {
    try {
      final cleanUsername = account.username.trim();
      final rawEmail = account.email.trim();

      final body = <String, dynamic>{
        'name': account.fullName.trim(),
        'username': cleanUsername,
        // Kosongkan email -> kembali ke email placeholder berbasis username
        'email':
            rawEmail.isNotEmpty ? rawEmail : '$cleanUsername@ortu.ebk.sch.id',
        'phone': account.phone.trim(),
        'is_active': account.isActive,
      };

      if (newPassword != null && newPassword.trim().length >= 8) {
        body['password'] = newPassword.trim();
        body['passwordConfirm'] = newPassword.trim();
      }

      final updatedUser = await _pb.collection('users').update(
            account.id,
            body: body,
          );

      if (students != null) {
        // Sinkronkan: tautkan semua anak terpilih, lepas anak yang dihapus.
        await _linkStudents(
          students,
          guardianId: updatedUser.id,
          guardianName: account.fullName,
        );
        final keepNisn = students.map((e) => e['nisn'] ?? '').toSet();
        final current = await StudentRepository.instance.getStudents(
          filter: "guardian = '${updatedUser.id}'",
        );
        for (final st in current) {
          if (!keepNisn.contains(st.nisn)) {
            await _pb.collection('students').update(
              st.id,
              body: {'guardian': '', 'guardian_name': '-'},
            );
          }
        }
      } else if (account.studentNisn.isNotEmpty && account.studentNisn != '-') {
        await _linkStudents(
          [
            {
              'child': account.studentChildName.split(' (+').first,
              'class': account.studentClass,
              'nisn': account.studentNisn,
            }
          ],
          guardianId: updatedUser.id,
          guardianName: account.fullName,
        );
      }

      final children = await StudentRepository.instance.getStudents(
        filter: "guardian = '${updatedUser.id}'",
      );
      return UserAccountModel.fromRecord(updatedUser, linkedChildren: children);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> _linkStudents(
    List<Map<String, String>> students, {
    required String guardianId,
    required String guardianName,
  }) async {
    for (final st in students) {
      await StudentRepository.instance.resolveOrCreateStudentId(
        nisn: st['nisn'] ?? '',
        name: st['child'] ?? '',
        className: st['class'] ?? '',
        guardianName: guardianName,
        guardianId: guardianId,
      );
    }
  }

  Future<void> toggleActiveStatus(String userId, bool isActive) async {
    try {
      await _pb.collection('users').update(
        userId,
        body: {'is_active': isActive},
      );
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> deleteParentAccount(String userId) async {
    try {
      await _pb.collection('users').delete(userId);
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
