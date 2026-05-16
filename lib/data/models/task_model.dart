import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/task_entity.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0) // Unique ID for this class in Hive
class TaskModel extends TaskEntity {
  @override
  @HiveField(0)
  final String id;
  
  @override
  @HiveField(1)
  final String title;
  
  @override
  @HiveField(2)
  final String description;
  
  @override
  @HiveField(3)
  final DateTime dueDate;
  
  @override
  @HiveField(4)
  final int priority;
  
  @override
  @HiveField(5)
  final bool isCompleted;

  @HiveField(6)
  final String recurrenceType;

  @HiveField(7)
  final int? reminderHour;

  @HiveField(8)
  final int? reminderMinute;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    this.recurrenceType = 'none',
    this.reminderHour,
    this.reminderMinute,
  }) : super(
          id: id,
          title: title,
          description: description,
          dueDate: dueDate,
          priority: priority,
          isCompleted: isCompleted,
          recurrenceType: recurrenceType,
          reminderTime: reminderHour != null && reminderMinute != null
              ? TimeOfDay(hour: reminderHour, minute: reminderMinute)
              : null,
        );

  // Convert Entity to Model
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      priority: entity.priority,
      isCompleted: entity.isCompleted,
      recurrenceType: entity.recurrenceType,
      reminderHour: entity.reminderTime?.hour,
      reminderMinute: entity.reminderTime?.minute,
    );
  }
}