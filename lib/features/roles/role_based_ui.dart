import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/roles/role.dart';
import 'package:navigation_diploma_client/features/roles/role_manager.dart';

class RoleBasedUI extends StatelessWidget {
  final Widget userView;
  final Widget calibratorView;
  final Widget adminView;

  const RoleBasedUI({
    super.key,
    required this.userView,
    required this.calibratorView,
    required this.adminView,
  });

  @override
  Widget build(BuildContext context) {
    final role = RoleManager().role;
    if (role == UserRole.admin) return adminView;
    if (role == UserRole.calibrator) return calibratorView;
    return userView;
  }
}