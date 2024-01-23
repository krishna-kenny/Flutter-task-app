import 'dart:math';
import 'package:flutter/material.dart';
import 'package:studize_interview/services/tasks/tasks_classes.dart';
import 'package:studize_interview/services/tasks/tasks_exceptions.dart';
import 'dart:async';

class TasksService {
  static List<Task> taskList = [];
  static int taskListLength = 1;

  static final _subjectsController = StreamController<bool>.broadcast();

  static Stream<bool> get subjectsStream => _subjectsController.stream;

  static addTask(Task task) {
    taskList.add(task);
    taskListLength++;

    // Update subject list after adding a task
    _updateSubjects();
  }

  static deleteTask(int taskId) {
    taskList.removeWhere((task) => task.id == taskId);

    // Update subject list after deleting a task
    _updateSubjects();
  }

  static _updateSubjects() {
    _subjectsController.add(true);
  }

  static Future<List<Subject>> getSubjectList() async {
    List<Subject> subjectList = [
      Subject(
        name: 'All tasks',
        color: const Color(0xE1E1E1FF),
        iconAssetPath: 'assets/icons/physics.png',
        numTasksLeft: taskList.length,
      ),
    ];

    Set<String> uniqueSubjects = {};
    // Collect unique subjects from tasks
    for (int i = 0; i < taskList.length; i++) {
      uniqueSubjects.add(taskList[i].title);
    }

    // Assign random unique colors to each unique subject
    List<Color> uniqueColors = _generateUniqueColors(uniqueSubjects.length);

    // Create Subject objects with names and colors
    uniqueSubjects.forEach((subjectName) {
      int numTasks = taskList.where((task) => task.title == subjectName).length;
      Subject subject = Subject(
        name: subjectName,
        color: uniqueColors.removeAt(0),
        iconAssetPath: 'assets/icons/subject_icon.png', // Replace with actual icon path
        numTasksLeft: numTasks,
      );
      subjectList.add(subject);
    });

    return subjectList;
  }


  // Generate a list of unique random colors
  // Generate a list of unique random colors
  static List<Color> _generateUniqueColors(int count) {
    List<Color> colors = [];
    Set<int> usedIndexes = Set<int>();

    List<Color> primaryColors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
    ];

    Random random = Random();
    while (colors.length < count) {
      int colorIndex = random.nextInt(primaryColors.length);
      if (!usedIndexes.contains(colorIndex)) {
        usedIndexes.add(colorIndex);
        colors.add(primaryColors[colorIndex]);
      }
    }

    return colors;
  }


  static Future<void> _addNewSubjectIfNotExists(String subjectName) async {
    List<Subject> subjectList = await getSubjectList();
    bool subjectExists =
        subjectList.any((subject) => subject.name == subjectName);

    if (!subjectExists) {
      // Add a new subject with a random color
      Color randomColor = _generateUniqueColors(1).first;
      Subject newSubject = Subject(name: subjectName, color: randomColor, iconAssetPath: 'assets/default_icon.png', numTasksLeft: 1);
      subjectList.add(newSubject);
    }
  }

  static Future<List<Task>> getDayTasks(int selectedDay) async {
    List<Task> dayTaskList = [];

    for (int i = 0; i < taskList.length; i++) {
      if (taskList[i].timeStart.day <= selectedDay &&
          taskList[i].timeEnd.day >= selectedDay) {
        dayTaskList.add(taskList[i]);
      }
    }

    // Sort the list based on Task.startTime
    dayTaskList.sort((a, b) => a.timeStart.compareTo(b.timeStart));

    return dayTaskList;
  }

  /// Returns task object that corresponds to the specified [taskId] inside the
  /// specified [subjectName].
  ///
  /// Throws exception `TaskNotFoundException` if specified `taskId` is not found
  /// and `SubjectNotFoundException` if specified `subjectName` is not found.
  static Future<Task> getTask(
      {required int taskId, required int selectedDay}) async {
    List<Task> taskList = await getDayTasks(selectedDay);
    for (int i = 0; i < taskList.length; i++) {
      if (taskList[i].id == taskId) {
        return taskList[i];
      }
    }

    // If the loop completes without finding the specified id, then throw
    // exception
    throw TaskNotFoundException();
  }
}
