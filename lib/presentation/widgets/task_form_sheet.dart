import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task_entity.dart';

class TaskFormSheet extends StatefulWidget {
  final TaskEntity? taskToEdit;
  final Function(TaskEntity) onSave;

  const TaskFormSheet({super.key, this.taskToEdit, required this.onSave});

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late DateTime _selectedDate;
  late int _selectedPriority;
  
  // New local form states for bonus features
  late String _selectedRecurrence;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descController = TextEditingController(text: widget.taskToEdit?.description ?? '');
    _selectedDate = widget.taskToEdit?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _selectedPriority = widget.taskToEdit?.priority ?? 1;
    _selectedRecurrence = widget.taskToEdit?.recurrenceType ?? 'none';
    _selectedTime = widget.taskToEdit?.reminderTime;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final task = TaskEntity(
        id: widget.taskToEdit?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        dueDate: _selectedDate,
        priority: _selectedPriority,
        isCompleted: widget.taskToEdit?.isCompleted ?? false,
        recurrenceType: _selectedRecurrence,
        reminderTime: _selectedTime,
      );
      widget.onSave(task);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, padding + 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.taskToEdit == null ? 'Add New Task' : 'Edit Task',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title*', border: OutlineInputBorder()),
                validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              
              // Date Picker Group
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Due Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}', style: theme.textTheme.bodyMedium),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text('Select Date'),
                    onPressed: _pickDate,
                  ),
                ],
              ),
              
              // Custom Time Picker Group
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedTime == null 
                        ? 'No Alert Scheduled' 
                        : 'Alert Time: ${_selectedTime!.format(context)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.access_time, size: 18),
                    label: Text(_selectedTime == null ? 'Set Reminder' : 'Change Time'),
                    onPressed: _pickTime,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Priority Form Dropdown
              DropdownButtonFormField<int>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Low')),
                  DropdownMenuItem(value: 2, child: Text('Medium')),
                  DropdownMenuItem(value: 3, child: Text('High')),
                ],
                onChanged: (val) => setState(() => _selectedPriority = val ?? 1),
              ),
              const SizedBox(height: 12),

              // New Recurrence Form Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedRecurrence,
                decoration: const InputDecoration(labelText: 'Repeat Task', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('Do Not Repeat')),
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'alternate', child: Text('Alternate Days')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                ],
                onChanged: (val) => setState(() => _selectedRecurrence = val ?? 'none'),
              ),
              
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(onPressed: _submit, child: const Text('Save Task')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}