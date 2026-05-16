import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasksUseCase;
  final AddTaskUseCase addTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  TaskBloc({
    required this.getTasksUseCase,
    required this.addTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
  }) : super(TaskInitial()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<AddTaskEvent>(_onAddTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<SearchTasksEvent>(_onSearchTasks);
    on<FilterPriorityEvent>(_onFilterPriority);
  }

  Future<void> _onLoadTasks(LoadTasksEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await getTasksUseCase();
      emit(TaskLoaded(tasks: tasks));
    } catch (e) {
      emit(const TaskError('Failed to fetch tasks.'));
    }
  }

  Future<void> _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await addTaskUseCase(event.task);
      final tasks = await getTasksUseCase();
      
      if (state is TaskLoaded) {
        final currentState = state as TaskLoaded;
        emit(currentState.copyWith(tasks: tasks));
      } else {
        emit(TaskLoaded(tasks: tasks));
      }
    } catch (e) {
      emit(const TaskError('Failed to add task.'));
    }
  }

  Future<void> _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await updateTaskUseCase(event.task);
      final tasks = await getTasksUseCase();

      if (state is TaskLoaded) {
        final currentState = state as TaskLoaded;
        emit(currentState.copyWith(tasks: tasks));
      }
    } catch (e) {
      emit(const TaskError('Failed to update task.'));
    }
  }

  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await deleteTaskUseCase(event.id);
      final tasks = await getTasksUseCase();

      if (state is TaskLoaded) {
        final currentState = state as TaskLoaded;
        emit(currentState.copyWith(tasks: tasks));
      }
    } catch (e) {
      emit(const TaskError('Failed to delete task.'));
    }
  }

  void _onSearchTasks(SearchTasksEvent event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      emit(currentState.copyWith(searchQuery: event.query));
    }
  }

  void _onFilterPriority(FilterPriorityEvent event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      emit(currentState.copyWith(priorityFilter: event.priority));
    }
  }
}