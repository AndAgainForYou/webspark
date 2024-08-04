import 'package:dio/dio.dart';
import 'package:webspark_test/Pages/clases.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<List<Task>> getTasks(String url) async {
    try {
      Response response = await _dio.get('${url}flutter/api');
      print(response.data);
      if (response.data['error']) {
        throw Exception(response.data['message']);
      }
      return (response.data['data'] as List)
          .map((task) => Task.fromJson(task as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<List<TaskResult>> sendResults(String url, List<Task> results) async {
    try {
      List<Map<String, dynamic>> requestBody = results.map((task) {
        return {
          'id': task.id,
          'result': {
            'steps': task.steps.map((step) => {'x': step.x, 'y': step.y}).toList(),
            'path': task.path,
          },
        };
      }).toList();

      print(requestBody);

      Response response = await _dio.post('${url}flutter/api', data: requestBody);

      if (response.data['error']) {
        throw Exception(response.data['message']);
      }

      return (response.data['data'] as List)
          .map((result) => TaskResult.fromJson(result as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print(e);
      throw Exception('Failed to send results: $e');
    }
  }
}
