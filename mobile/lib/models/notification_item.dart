import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final IconData icon;
  final Color color;

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.icon,
    required this.color,
  });
}
