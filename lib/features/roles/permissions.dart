import 'package:navigation_diploma_client/features/roles/role_manager.dart';

class Permissions {
  static bool canCalibrate() {
    return RoleManager().isAdmin || RoleManager().isCalibrator;
  }

  static bool canAccessDebugTools() {
    return RoleManager().isAdmin;
  }

  static bool canSendScan() {
    return true; // Все могут сканировать
  }
}
