import 'package:cloud_firestore/cloud_firestore.dart';

class CalificacionModel {
  final String userId;
  final double stars;
  final String? comment;
  final DateTime? date;

  CalificacionModel({
    required this.userId,
    required this.stars,
    this.comment,
    this.date,
  });

  factory CalificacionModel.fromJson(Map<String, dynamic> json) {
    return CalificacionModel(
      userId: json['userId'] ?? '',
      stars: (json['stars'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String?,
      date: json['date'] != null ? (json['date'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'stars': stars,
    'comment': comment,
    'date': date != null ? Timestamp.fromDate(date!) : null,
  };
}
