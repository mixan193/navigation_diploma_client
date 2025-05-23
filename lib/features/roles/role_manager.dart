import 'package:navigation_diploma_client/features/roles/role.dart';

class RoleManager {
  static final RoleManager _instance = RoleManager._internal();
  factory RoleManager() => _instance;
  RoleManager._internal();

  UserRole _role = UserRole.user;

  bool get isAdmin => _role == UserRole.admin;
  bool get isCalibrator => _role == UserRole.calibrator;

  void setRole(UserRole role) {
    _role = role;
  }

  UserRole get role => _role;
}