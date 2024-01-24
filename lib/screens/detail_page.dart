import 'package:flutter/material.dart';
import 'package:studize_interview/widgets/date_picker.dart';
import 'package:studize_interview/widgets/task_timeline.dart';
import 'package:studize_interview/widgets/task_title.dart';
import 'package:studize_interview/services/tasks/tasks_classes.dart';
import 'package:studize_interview/services/tasks/tasks_service.dart';

class DetailPage extends StatefulWidget {
  final Key? key;
  final Subject sub;

  const DetailPage({this.key, required this.sub}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late DateTime selectedDay;

  @override
  void initState() {
    final now = DateTime.now();
    selectedDay = DateTime(
      now.year,
      now.month,
      now.day,
    );
    super.initState();
  }

  void _openNewTaskModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return NewTaskForm(
          onTaskAdded: () {
            // Callback to refresh the state in DetailPage
            setState(() {});
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: (widget.sub.name == 'All tasks')
          ? TasksService.getDayTasks(selectedDay.day)
          : TasksService.getDaySubjectTasks(selectedDay.day, widget.sub.name),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text("Error: Could not fetch tasks."),
          );
        } else {
          final List<Task> taskList = snapshot.data as List<Task>;
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.sub.name,
                  style:
                      const TextStyle(color: Color(0xFF00695C), fontSize: 24)),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF80D8FF),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                _openNewTaskModal(context);
              },
              label: const Text('New Task'),
              icon: const Icon(Icons.edit),
            ),
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0F7FA),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DatePicker(
                          callback: (selectedDay) =>
                              setState(() => this.selectedDay = selectedDay),
                        ),
                        const TaskTitle(),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) => TaskTimeline(
                      task: taskList.isEmpty ? null : taskList[0],
                      subjectColor: taskList[index].color,
                      isFirst: index == 0,
                      isLast: index == taskList.length - 1,
                      refreshCallback: () {
                        setState(() {});
                      },
                    ),
                    childCount: taskList.length,
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }
}

class NewTaskForm extends StatefulWidget {
  final VoidCallback onTaskAdded;

  const NewTaskForm({required this.onTaskAdded, Key? key}) : super(key: key);

  @override
  _NewTaskFormState createState() => _NewTaskFormState();
}

class _NewTaskFormState extends State<NewTaskForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DateTimePicker(
                  labelText: 'Start Time',
                  initialDateTime: _startTime,
                  onDateTimeChanged: (DateTime value) {
                    setState(() {
                      _startTime = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DateTimePicker(
                  labelText: 'End Time',
                  initialDateTime: _endTime,
                  onDateTimeChanged: (DateTime value) {
                    setState(() {
                      _endTime = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Access the entered values using controllers
              String title = _titleController.text;
              String description = _descriptionController.text;

              TasksService.addTask(Task(
                id: TasksService.taskListLength,
                title: title,
                description: description,
                timeStart: _startTime,
                timeEnd: _endTime,
                color: Colors.orangeAccent,
              ));

              // Call the callback to notify the parent about the task addition
              widget.onTaskAdded();

              Navigator.pop(context); // Close the modal
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _DateTimePicker extends StatelessWidget {
  final String labelText;
  final DateTime initialDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;

  const _DateTimePicker({
    Key? key,
    required this.labelText,
    required this.initialDateTime,
    required this.onDateTimeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: initialDateTime,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(initialDateTime),
              );
              if (pickedTime != null) {
                DateTime selectedDateTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
                onDateTimeChanged(selectedDateTime);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Date and Time'),
                Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
