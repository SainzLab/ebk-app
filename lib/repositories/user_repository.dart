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
  }) async {
    try {
      final rawContact = account.emailOrPhone.trim();
      final isEmail = rawContact.contains('@');
      final cleanUsername = account.username.trim();
      final emailValue =
          isEmail ? rawContact : '$cleanUsername@ortu.ebk.sch.id';
      final phoneValue = isEmail ? '' : rawContact;
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
      await StudentRepository.instance.resolveOrCreateStudentId(
        nisn: account.studentNisn,
        name: account.studentChildName,
        className: account.studentClass,
        guardianName: account.fullName,
        guardianId: createdUser.id,
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
  }) async {
    try {
      final rawContact = account.emailOrPhone.trim();
      final isEmail = rawContact.contains('@');
      final cleanUsername = account.username.trim();

      final body = <String, dynamic>{
        'name': account.fullName.trim(),
        'username': cleanUsername,
        if (isEmail) 'email': rawContact else 'phone': rawContact,
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

      // Pastikan siswa tertaut ke guardian ini
      if (account.studentNisn.isNotEmpty && account.studentNisn != '-') {
        await StudentRepository.instance.resolveOrCreateStudentId(
          nisn: account.studentNisn,
          name: account.studentChildName.split(' (+').first,
          className: account.studentClass,
          guardianName: account.fullName,
          guardianId: updatedUser.id,
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
