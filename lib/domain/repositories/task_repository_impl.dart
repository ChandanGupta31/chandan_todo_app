import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/task_model.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';


class TaskRepositoryImpl implements TaskRepository {
  final String _boxName = 'tasks_box';

  @override
  Future<void> addTask(TaskEntity task) async {
    final box = await Hive.openBox<TaskModel>(_boxName);
    final model = TaskModel.fromEntity(task);
    await box.put(model.id, model);
  }

  @override
  Future<List<TaskEntity>> getTasks() async {
    final box = await Hive.openBox<TaskModel>(_boxName);
    return box.values.toList();
  }

  @override
  Future<void> deleteTask(String id) async {
    final box = await Hive.openBox<TaskModel>(_boxName);
    await box.delete(id);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final box = await Hive.openBox<TaskModel>(_boxName);
    final model = TaskModel.fromEntity(task);
    await box.put(model.id, model);
  }
}