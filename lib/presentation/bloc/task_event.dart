import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskEvent {}

class AddTaskEvent extends TaskEvent {
  final TaskEntity task;
  const AddTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTaskEvent extends TaskEvent {
  final TaskEntity task;
  const UpdateTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTaskEvent extends TaskEvent {
  final String id;
  const DeleteTaskEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchTasksEvent extends TaskEvent {
  final String query;
  const SearchTasksEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterPriorityEvent extends TaskEvent {
  final int priority; // 0: All, 1: Low, 2: Medium, 3: High
  const FilterPriorityEvent(this.priority);

  @override
  List<Object?> get props => [priority];
}