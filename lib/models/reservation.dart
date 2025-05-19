class Reservation {
  final int id;
  final int service;
  final int user;
  final DateTime date;
  final String statut;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.service,
    required this.user,
    required this.date,
    this.statut = 'pending',
    required this.createdAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      service: json['service'],
      user: json['user'],
      date: DateTime.parse(json['date']),
      statut: json['statut'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service,
      'user': user,
      'date': date.toIso8601String(),
      'statut': statut,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 