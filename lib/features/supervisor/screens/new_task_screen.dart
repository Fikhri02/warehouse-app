import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:warehouse_app/core/models/staff_task.dart';
import 'package:warehouse_app/core/theme/app_text_styles.dart';
import 'package:warehouse_app/features/supervisor/providers/assign_tasks_provider.dart';
import 'package:warehouse_app/features/tasks/widgets/task_card.dart';

/// A supervisor creates a task on the phone (spec addendum 3d §2). It is queued like any other change.
class NewTaskScreen extends ConsumerStatefulWidget {
  const NewTaskScreen({super.key});

  @override
  ConsumerState<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends ConsumerState<NewTaskScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  TaskType _type = TaskType.stockCount;
  String? _placeId;
  String? _assigneeId;
  DateTime? _due;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      initialDate: _due ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_due ?? now));
    if (time == null) return;
    setState(() => _due = DateTime(day.year, day.month, day.day, time.hour, time.minute));
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(assignTasksProvider.notifier).create(NewTask(
            id: const Uuid().v4(),
            title: _title.text,
            type: _type,
            locationId: _placeId,
            assigneeId: _assigneeId,
            dueAt: _due,
          ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task created')));
      Navigator.of(context).pop();
    } on StateError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final team = ref.watch(teamProvider).valueOrNull ?? const <TeamMember>[];
    final places = ref.watch(taskPlacesProvider).valueOrNull ?? const <TaskPlace>[];
    return Scaffold(
      appBar: AppBar(title: const Text('New Task')),
      body: SafeArea(
        top: false,
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _title,
                maxLength: 200,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 8),
              Text('Type', style: AppTextStyles.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final t in TaskType.values)
                    ChoiceChip(label: Text(t.label), selected: _type == t, onSelected: (_) => setState(() => _type = t)),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _placeId,
                decoration: const InputDecoration(labelText: 'Bin (optional)'),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('None')),
                  for (final p in places) DropdownMenuItem<String?>(value: p.id, child: Text(p.code)),
                ],
                onChanged: (v) => setState(() => _placeId = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _assigneeId,
                decoration: InputDecoration(
                  labelText: 'Assign to (optional)',
                  helperText: team.isEmpty ? 'Connect once to load your team' : null,
                ),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('Nobody yet')),
                  for (final m in team) DropdownMenuItem<String?>(value: m.id, child: Text(m.name)),
                ],
                onChanged: team.isEmpty ? null : (v) => setState(() => _assigneeId = v),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: Text(_due == null ? 'No due date' : 'Due ${dueLabel(_due!)}'),
                onTap: _pickDue,
                trailing: _due == null
                    ? null
                    : IconButton(icon: const Icon(Icons.clear), tooltip: 'Clear due date', onPressed: () => setState(() => _due = null)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _saving ? null : _save, child: const Text('Create Task')),
            ],
          ),
        ),
      ),
    );
  }
}
