import 'package:flutter/material.dart';

class Task {
  final int id;
  String title;
  String description;
  DateTime timeStart;
  DateTime timeEnd;
  Color color;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.timeStart,
    required this.timeEnd,
    required this.color,
  }) : isCompleted = false;
}

class Subject {
  String name;
  String iconAssetPath;
  Color color;
  int numTasksLeft;

  Subject({
    required this.name,
    required this.color,
    required this.iconAssetPath,
    required this.numTasksLeft,
  });

  // Optional: Add a named constructor for creating a Subject with default values.
  Subject.defaultValues()
      : name = 'Default Subject',
        color = Colors.grey,
        iconAssetPath = 'assets/default_icon.png',
        numTasksLeft = 0;
}
