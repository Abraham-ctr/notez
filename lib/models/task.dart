import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;  // unique task id
  final String title; // task title or content
  final bool isDone;  // task completed or not
  final Timestamp timestamp;  // task created at or updated at

  Task({
    required this.id,
    required this.title,
    required this.isDone,
    required this.timestamp,
  });

  // Convert Firestore document to Task
  factory Task.fromMap(Map<String, dynamic> data, String documentId) {
    return Task(
      id: documentId,
      title: data['title'] ?? '',
      isDone: data['isDone'] ?? false,
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Convert Task to Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
      'timestamp': timestamp,
    };
  }
}
