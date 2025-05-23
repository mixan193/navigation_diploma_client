enum UserRole {
  user,
  calibrator,
  admin,
}

extension UserRoleExt on UserRole {
  String get name {
    switch (this) {
      case UserRole.user:
        return "Пользователь";
      case UserRole.calibrator:
        return "Калибратор";
      case UserRole.admin:
        return "Администратор";
    }
  }
}