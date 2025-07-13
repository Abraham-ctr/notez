import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/task.dart';

enum TaskFilter { all, completed, pending }

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Task> _tasks = [];
  String _searchQuery = '';
  TaskFilter _filter = TaskFilter.all;
  bool _isLoading = true;
  String? _error;

  List<Task> get tasks => _tasks;
  String get searchQuery => _searchQuery;
  TaskFilter get filter => _filter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch tasks in real-time
  void loadTasks() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _firestore
        .collection('tasks')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _tasks.clear();
      for (var doc in snapshot.docs) {
        _tasks.add(Task.fromMap(doc.data(), doc.id));
      }
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      _error = 'Failed to load tasks';
      _isLoading = false;
      notifyListeners();
    });
  }

  // Add new task
  Future<void> addTask(String title) async {
    await _firestore.collection('tasks').add({
      'title': title,
      'isDone': false,
      'timestamp': Timestamp.now(),
    });
  }

  // Update task title
  Future<void> updateTaskTitle(String taskId, String newTitle) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'title': newTitle,
    });
  }

  // Toggle task completion
  Future<void> toggleTaskStatus(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update({
      'isDone': !task.isDone,
    });
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(TaskFilter newFilter) {
    _filter = newFilter;
    notifyListeners();
  }

  List<Task> get filteredTasks {
    return _tasks.where((task) {
      final matchesSearch =
          task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = switch (_filter) {
        TaskFilter.completed => task.isDone,
        TaskFilter.pending => !task.isDone,
        TaskFilter.all => true,
      };
      return matchesSearch && matchesFilter;
    }).toList();
  }
}
