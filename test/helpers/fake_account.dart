import 'package:my_first_flutter_app/state/auth_repository.dart';
import 'package:my_first_flutter_app/state/employee_repository.dart';
import 'package:my_first_flutter_app/state/invite_repository.dart';

/// A login system for the account screens: records what it was asked and
/// fails on demand.
class AccountFakeAuth implements AuthRepository {
  AccountFakeAuth({this.signedUp});

  /// Who a correct activation code signs in.
  final AppUser? signedUp;

  /// Set to make the next call of that kind fail.
  AuthFailure? failStart;
  AuthFailure? failFinish;
  AuthFailure? failReset;
  AuthFailure? failChange;

  final calls = <String>[];

  @override
  bool get usesBackend => true;

  @override
  Future<AppUser> signIn(String email, String password) async =>
      throw UnimplementedError();

  @override
  Future<AppUser?> restoreSession() async => null;

  @override
  Future<void> signOut() async => calls.add('signOut');

  @override
  Future<void> startSignUp(String email, String password) async {
    calls.add('startSignUp $email $password');
    if (failStart != null) throw failStart!;
  }

  @override
  Future<AppUser> finishSignUp(String email, String code) async {
    calls.add('finishSignUp $email $code');
    if (failFinish != null) throw failFinish!;
    return signedUp!;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    calls.add('sendPasswordReset $email');
    if (failStart != null) throw failStart!;
  }

  @override
  Future<void> resetPassword(String email, String code, String pw) async {
    calls.add('resetPassword $email $code $pw');
    if (failReset != null) throw failReset!;
  }

  @override
  Future<void> changePassword(String current, String next) async {
    calls.add('changePassword $current $next');
    if (failChange != null) throw failChange!;
  }
}

/// A stand-in for the invites table.
class FakeInviteRepository implements InviteRepository {
  FakeInviteRepository([this.info = const AccountInfo(AccountStatus.none)]);

  AccountInfo info;
  SaveFailure? failNextWrite;
  final calls = <String>[];

  @override
  bool get usesBackend => true;

  @override
  Future<AccountInfo> statusOf(String staffId) async => info;

  @override
  Future<void> invite(String staffId, String email) async {
    calls.add('invite $staffId $email');
    final f = failNextWrite;
    failNextWrite = null;
    if (f != null) throw f;
    info = AccountInfo(AccountStatus.invited, email);
  }

  @override
  Future<void> cancel(String staffId) async {
    calls.add('cancel $staffId');
    info = const AccountInfo(AccountStatus.none);
  }
}
