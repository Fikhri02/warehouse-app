import 'package:flutter/material.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/models/user_session.dart';
import 'package:warehouse_app/core/theme/app_colors.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';

/// Asks who a task should go to. The chosen person's id, or null if cancelled.
Future<String?> pickAssignee(BuildContext context, {required List<TeamMember> team, String? current}) =>
    showDialog<String>(context: context, builder: (_) => _AssigneeDialog(team: team, current: current));

class _AssigneeDialog extends StatefulWidget {
  const _AssigneeDialog({required this.team, this.current});

  final List<TeamMember> team;
  final String? current;

  @override
  State<_AssigneeDialog> createState() => _AssigneeDialogState();
}

class _AssigneeDialogState extends State<_AssigneeDialog> {
  late String? _selected = widget.current;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Assign to'),
        content: widget.team.isEmpty
            ? const Text('Connect once to load your team')
            : SizedBox(
                width: double.maxFinite,
                child: RadioGroup<String>(
                  groupValue: _selected,
                  onChanged: (v) => setState(() => _selected = v),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final m in widget.team)
                        RadioListTile<String>(
                          value: m.id,
                          title: Text(m.name, style: AppTextStyles.bodyMedium),
                          subtitle: Text(m.role == UserRole.supervisor ? 'Supervisor' : 'Worker', style: AppTextStyles.bodySmall),
                          activeColor: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: _selected == null || widget.team.isEmpty ? null : () => Navigator.pop(context, _selected),
            child: const Text('Assign'),
          ),
        ],
      );
}
