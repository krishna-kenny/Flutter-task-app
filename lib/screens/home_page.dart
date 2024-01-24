import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studize_interview/screens/detail_page.dart';
import 'package:studize_interview/services/tasks/tasks_classes.dart';
import 'package:studize_interview/services/tasks/tasks_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks', style: TextStyle(color: Colors.black54,fontSize: 40),),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF80D8FF),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE0F7FA),
        ),
        child: const Padding(
          padding: EdgeInsets.only(top: 40.0), // Adjust the top margin as needed
          child: SubjectsGrid(),
        ),
      ),
    );
  }
}



class SubjectsGrid extends StatefulWidget {
  const SubjectsGrid({Key? key}) : super(key: key);

  @override
  _SubjectsGridState createState() => _SubjectsGridState();
}

class _SubjectsGridState extends State<SubjectsGrid> {
  late final StreamSubscription<bool> _subjectsStreamSubscription;
  late Future<List<Subject>> _subjectListFuture;

  @override
  void initState() {
    super.initState();
    _subjectListFuture = TasksService.getSubjectList();
    _subjectsStreamSubscription = TasksService.subjectsStream.listen((_) {
      // Update subject list when stream receives an event
      _updateSubjectList();
    });
  }

  @override
  void dispose() {
    _subjectsStreamSubscription.cancel();
    super.dispose();
  }

  void _updateSubjectList() {
    setState(() {
      _subjectListFuture = TasksService.getSubjectList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: _subjectListFuture,
      builder: (BuildContext context, AsyncSnapshot<List<Subject>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            List<Subject> subjectList = snapshot.data!;
            return ListView(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: subjectList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: screenWidth > 650 ? 3 : 2,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 25,
                    ),
                    itemBuilder: (context, index) =>
                        _buildSubject(context, subjectList[index]),
                  ),
                ),
              ],
            );
          case ConnectionState.waiting:
          case ConnectionState.active:
            return const Center(
              child: CircularProgressIndicator(), // Show a loading indicator
            );

          case ConnectionState.none:
            return const Center(
              child: Text("Error: Could not get subjects from storage"),
            );
        }
      },
    );
  }

  Widget _buildSubject(BuildContext context, Subject subject) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailPage(sub: subject),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              subject.color.withOpacity(0.8),
              Colors.white,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: -2,
              blurRadius: 6,
              offset: const Offset(-4, -4), // Adjust these values for the desired 3D effect
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              subject.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTaskStatus(
                  Colors.white,
                  subject.color,
                  '${subject.numTasksLeft} left',
                  Colors.black87,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }




  Widget _buildTaskStatus(
    Color bgColor,
    Color txColor,
    String text,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10), // Added border radius
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
        ),
      ),
    );
  }
}
