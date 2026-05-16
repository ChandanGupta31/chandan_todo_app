import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final int priority; // 1: Low, 2: Medium, 3: High
  final bool isCompleted;
  final String recurrenceType; // 'none', 'daily', 'alternate', 'weekly', 'monthly'
  final TimeOfDay? reminderTime; // Custom time selected by the user

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    this.recurrenceType = 'none',
    this.reminderTime,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    dueDate,
    priority,
    isCompleted,
    recurrenceType, 
    reminderTime
  ];
}
