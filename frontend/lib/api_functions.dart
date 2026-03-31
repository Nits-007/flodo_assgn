import 'package:flutter/material.dart';
import 'package:frontend/model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  final String baseUrl = "http://localhost:8000/tasks"; 

  Future<void> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/'));
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      _tasks = List<Task>.from(l.map((model) => Task.fromJson(model)));
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    _isLoading = true;
    notifyListeners(); 

    await Future.delayed(const Duration(seconds: 2)); 

    final response = await http.post(
      Uri.parse('$baseUrl/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 200) {
      _tasks.add(Task.fromJson(json.decode(response.body)));
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateTask(int taskId, Task updatedTask) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$taskId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedTask.toJson()),
      );

      if (response.statusCode == 200) {
        int index = _tasks.indexWhere((t) => t.id == taskId);
        if (index != -1) {
          _tasks[index] = Task.fromJson(json.decode(response.body));
        }
      }
    } catch (e) {
      debugPrint("Update failed: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> deleteTask(int taskId) async {
    _isLoading = true;
    notifyListeners();

   
    await Future.delayed(const Duration(seconds: 2));

    try {
      final response = await http.delete(Uri.parse('$baseUrl/$taskId'));

      if (response.statusCode == 200) {

        _tasks.removeWhere((t) => t.id == taskId);
      }
    } catch (e) {
      debugPrint("Delete failed: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
}