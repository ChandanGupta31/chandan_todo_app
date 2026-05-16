import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/task_model.dart';
import '../../domain/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../presentation/bloc/task_bloc.dart';
import '../../presentation/bloc/theme_bloc.dart';
import '../services/notification_service.dart';

// sl stands for Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  // Initialize Hive Local Storage
  await Hive.initFlutter();

  // Register the Hive TypeAdapter
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TaskModelAdapter());
  }

  // Register ThemeBloc
  sl.registerFactory(() => ThemeBloc());

  // Initialize and register notification service
  final notificationService = NotificationService();
  await notificationService.initNotification();
  sl.registerLazySingleton<NotificationService>(() => notificationService);

  // Repositories
  // LazySingleton means the instance is only created the first time it's called
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl());

  // Use Cases
  sl.registerLazySingleton(() => GetTasksUseCase(sl()));
  sl.registerLazySingleton(() => AddTaskUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => TaskBloc(
      getTasksUseCase: sl(),
      addTaskUseCase: sl(),
      updateTaskUseCase: sl(),
      deleteTaskUseCase: sl(),
    ),
  );

}
