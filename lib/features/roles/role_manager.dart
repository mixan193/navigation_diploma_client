import 'package:navigation_diploma_client/features/roles/role.dart';

class RoleManager {
  static final RoleManager _instance = RoleManager._internal();
  factory RoleManager() => _instance;
  RoleManager._internal();

  // Текущая роль (можно заменить на хранение в SecureStorage)
  UserRole _role = UserRole.user;

  UserRole get role => _role;

  void setRole(UserRole newRole) {
    _role = newRole;
    // Можно добавить notifyListeners или stream, если нужна реактивность
  }

  bool get isAdmin => _role == UserRole.admin;
  bool get isCalibrator => _role == UserRole.calibrator;
  bool get isUser => _role == UserRole.user;
}
