class Review {
  final int? id;
  final int service;
  final int? user;
  final String? userName;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  Review({
    this.id,
    required this.service,
    this.user,
    this.userName,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      service: json['service'],
      user: json['user'],
      userName: json['user_name'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service,
      'user': user,
      'rating': rating,
      'comment': comment,
    };
  }
} 