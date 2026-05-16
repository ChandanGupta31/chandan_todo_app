import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/notification_service.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../bloc/theme_bloc.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showTaskForm(BuildContext context, {TaskEntity? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TaskFormSheet(
        taskToEdit: task,
        onSave: (savedTask) {
          if (task == null) {
            context.read<TaskBloc>().add(AddTaskEvent(savedTask));

            // Schedule dynamic notification based on custom parameters selected by user
            if (savedTask.reminderTime != null) {
              final scheduleDateTime = DateTime(
                savedTask.dueDate.year,
                savedTask.dueDate.month,
                savedTask.dueDate.day,
                savedTask.reminderTime!.hour,
                savedTask.reminderTime!.minute,
              );

              sl<NotificationService>().scheduleNotification(
                id: savedTask.id.hashCode,
                title: 'Task Reminder',
                body: 'Time to finish: ${savedTask.title}',
                scheduledNotificationDateTime: scheduleDateTime,
              );
            }
          } else {
            context.read<TaskBloc>().add(UpdateTaskEvent(savedTask));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chandan ToDo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          // Theme Dynamic Toggle Button
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              final isDark =
                  state.themeMode == ThemeMode.dark ||
                  (state.themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark);

              return IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                ),
                tooltip: 'Toggle Theme Mode',
                onPressed: () {
                  context.read<ThemeBloc>().add(ToggleThemeEvent());
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Inputs Panel
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (query) {
                context.read<TaskBloc>().add(SearchTasksEvent(query));
              },
            ),
          ),

          // Filters Chips Row
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              int activeFilter = 0;
              if (state is TaskLoaded) activeFilter = state.priorityFilter;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [0, 1, 2, 3].map((priorityIndex) {
                    final labels = ['All', 'Low', 'Medium', 'High'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: activeFilter == priorityIndex,
                        label: Text(labels[priorityIndex]),
                        onSelected: (_) {
                          context.read<TaskBloc>().add(
                            FilterPriorityEvent(priorityIndex),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Tasks Stream Output List
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TaskLoaded) {
                  // Perform Search and Filtering on Client side safely using the Bloc variables
                  final filteredTasks = state.tasks.where((task) {
                    final matchesSearch =
                        task.title.toLowerCase().contains(
                          state.searchQuery.toLowerCase(),
                        ) ||
                        task.description.toLowerCase().contains(
                          state.searchQuery.toLowerCase(),
                        );
                    final matchesFilter =
                        state.priorityFilter == 0 ||
                        task.priority == state.priorityFilter;
                    return matchesSearch && matchesFilter;
                  }).toList();

                  if (filteredTasks.isEmpty) {
                    return const Center(
                      child: Text('No matching tasks found.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final item = filteredTasks[index];
                      return TaskCard(
                        task: item,
                        onEdit: () => _showTaskForm(context, task: item),
                      );
                    },
                  );
                }

                if (state is TaskError) {
                  return Center(child: Text(state.message));
                }

                return const Center(
                  child: Text('No updates yet. Start creating tasks!'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskForm(context),
        label: const Text('New Task'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
