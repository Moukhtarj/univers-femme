class Reservation {
  final int id;
  final int userId;
  final int serviceId;
  final String serviceName;
  final String serviceType;
  final DateTime date;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reservation({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.serviceType,
    required this.date,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      userId: json['user'],
      serviceId: json['service']['id'],
      serviceName: json['service']['name'],
      serviceType: json['service']['type'],
      date: DateTime.parse(json['date']),
      status: json['statut'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'service': {
        'id': serviceId,
        'name': serviceName,
        'type': serviceType,
      },
      'date': date.toIso8601String(),
      'statut': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 