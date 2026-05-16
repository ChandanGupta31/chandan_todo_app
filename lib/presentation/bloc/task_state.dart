import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;
  final String searchQuery;
  final int priorityFilter; // 0: All, 1: Low, 2: Medium, 3: High

  const TaskLoaded({
    required this.tasks,
    this.searchQuery = '',
    this.priorityFilter = 0,
  });

  @override
  List<Object?> get props => [tasks, searchQuery, priorityFilter];

  TaskLoaded copyWith({
    List<TaskEntity>? tasks,
    String? searchQuery,
    int? priorityFilter,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      searchQuery: searchQuery ?? this.searchQuery,
      priorityFilter: priorityFilter ?? this.priorityFilter,
    );
  }
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}