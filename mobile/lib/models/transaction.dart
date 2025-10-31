import 'package:flutter/material.dart';

class Transaction {
  final String id;
  final String type;
  final double amount;
  final DateTime date;
  final String status;
  final String description;
  final IconData? icon; // Made optional
  final Color? color; // Made optional

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.status,
    required this.description,
    this.icon,
    this.color,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        type: json['type'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        status: json['status'] as String,
        description: json['description'] as String,
        // IconData and Color are client-side determined, not typically from API
        icon: null, // Default or map from string if API provides
        color: null, // Default or map from string if API provides
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'amount': amount,
        'date': date.toIso8601String(),
        'status': status,
        'description': description,
        // IconData and Color are client-side determined, not sent to API
      };
}