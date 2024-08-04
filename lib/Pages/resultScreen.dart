import 'package:flutter/material.dart';
import 'package:webspark_test/Pages/api.dart';
import 'package:webspark_test/Pages/clases.dart';

class ResultsScreen extends StatelessWidget {
  final List<Task> tasks;
  final String apiUrl;
  final ApiService apiService = ApiService();

  ResultsScreen({required this.tasks, required this.apiUrl});

  void _sendResult(BuildContext context, Task task) async {
    try {
      List<TaskResult> results = await apiService.sendResults(apiUrl, [task]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Result for task ${task.id} sent successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send result for task ${task.id}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Task ID: ${task.id}'),
                const Text('Field:'),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: task.field.first.length,
                  ),
                  itemCount: task.field.length * task.field.first.length,
                  itemBuilder: (context, index) {
                    int row = index ~/ task.field.first.length;
                    int col = index % task.field.first.length;
                    final cell = task.field[row][col];
                    return Container(
                      width: 50,
                      height: 50,
                      color: cell == 'X' ? Colors.black : Colors.white,
                      child: Center(
                        child: Text(
                          '($row,$col)',
                          style: TextStyle(
                            color: cell == 'X' ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Text('Path: ${task.path}'),
                const Text('Steps:'),
                for (final step in task.steps) Text('(${step.x}, ${step.y})'),
                ElevatedButton(
                  onPressed: () => _sendResult(context, task),
                  child: Text('Send Result for Task ${task.id}'),
                ),
                const Divider(),
              ],
            );
          },
        ),
      ),
    );
  }
}
