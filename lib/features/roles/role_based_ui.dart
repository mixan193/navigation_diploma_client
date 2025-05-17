import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/roles/role.dart';
import 'package:navigation_diploma_client/features/roles/role_manager.dart';

class RoleBasedMenu extends StatelessWidget {
  const RoleBasedMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final role = RoleManager().role;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Ваша роль: ${role.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Обычное сканирование доступно всегда
            Navigator.of(context).pushNamed('/scan');
          },
          child: const Text("Навигация"),
        ),
        if (role == UserRole.admin || role == UserRole.calibrator)
          ElevatedButton(
            onPressed: () {
              // Открыть экран ручной калибровки
              Navigator.of(context).pushNamed('/calibration');
            },
            child: const Text("Ручная калибровка"),
          ),
        if (role == UserRole.admin)
          ElevatedButton(
            onPressed: () {
              // Доступ к debug-инструментам
              Navigator.of(context).pushNamed('/debug');
            },
            child: const Text("Инструменты отладки"),
          ),
      ],
    );
  }
}

// Пример смены роли (например, для теста)
class RoleSelector extends StatelessWidget {
  const RoleSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<UserRole>(
      value: RoleManager().role,
      items: UserRole.values.map((role) {
        return DropdownMenuItem(
          value: role,
          child: Text(role.name),
        );
      }).toList(),
      onChanged: (role) {
        if (role != null) {
          RoleManager().setRole(role);
        }
      },
    );
  }
}
