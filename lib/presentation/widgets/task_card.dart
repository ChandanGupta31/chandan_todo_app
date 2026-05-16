import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onEdit;

  const TaskCard({super.key, required this.task, required this.onEdit});

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 3:
        return Colors.red.shade400; // High
      case 2:
        return Colors.orange.shade400; // Medium
      default:
        return Colors.green.shade400; // Low
    }
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 3:
        return 'High';
      case 2:
        return 'Medium';
      case 1:
      default:
        return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (value) {
              DateTime updatedDate = task.dueDate;
              bool targetCompletionStatus = value ?? false;

              // Check if the task repeats and is being marked as complete
              if (task.recurrenceType != 'none' && targetCompletionStatus) {
                // Calculate the next occurrence date
                updatedDate = TaskDateUtils.calculateNextDueDate(
                  task.dueDate,
                  task.recurrenceType,
                );

                // Keep the task active (false) for its next cycle
                targetCompletionStatus = false;

                // Show a quick snackbar so the user knows it rolled over
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Recurring task rolled over to next scheduled date!',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }

              // Dispatch the update event to BLoC
              context.read<TaskBloc>().add(
                UpdateTaskEvent(
                  TaskEntity(
                    id: task.id,
                    title: task.title,
                    description: task.description,
                    dueDate: updatedDate,
                    priority: task.priority,
                    isCompleted: targetCompletionStatus,
                    recurrenceType: task.recurrenceType,
                    reminderTime: task.reminderTime,
                  ),
                ),
              );
            },
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted
                  ? theme.colorScheme.outline
                  : theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(task.dueDate),
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(
                        task.priority,
                      ).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getPriorityLabel(task.priority),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getPriorityColor(task.priority),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
        ),
      ),
    );
  }
}
