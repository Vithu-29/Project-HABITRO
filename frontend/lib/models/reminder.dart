import 'package:flutter/material.dart';

class Reminder {
  final String id;
  final String habitId;
  final String habitName;
  final TimeOfDay time;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? endedAt;
  final int trackingDurationDays;

  Reminder({
    required this.id,
    required this.habitId,
    required this.habitName,
    required this.time,
    required this.trackingDurationDays,
    this.isActive = true,
    this.endedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'habitName': habitName,
      'hour': time.hour,
      'minute': time.minute,
      'isActive': isActive,
      'trackingDurationDays': trackingDurationDays,
      'createdAt': createdAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      habitId: map['habitId'],
      habitName: map['habitName'],
      time: TimeOfDay(hour: map['hour'], minute: map['minute']),
      isActive: map['isActive'] ?? true,
      trackingDurationDays: map['trackingDurationDays'],
      createdAt: DateTime.parse(map['createdAt']),
      endedAt: map['endedAt'] != null ? DateTime.parse(map['endedAt']) : null,
    );
  }

  bool shouldBeActiveToday() {
    if (!isActive) return false;
    if (endedAt != null && DateTime.now().isAfter(endedAt!)) return false;
    
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    return daysSinceCreation < trackingDurationDays;
  }

  // Helper to convert TimeOfDay to DateTime
  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }
}