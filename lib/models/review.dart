class Review {
  final int id;
  final int userId;
  final String userName;
  final int? hammamServiceId;
  final int? gymServiceId;
  final int? makeupServiceId;
  final int? hennaServiceId;
  final int? accessoryServiceId;
  final int? melhfaServiceId;
  final String serviceName;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final bool userHasLiked;
  final bool canEdit;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.hammamServiceId,
    this.gymServiceId,
    this.makeupServiceId,
    this.hennaServiceId,
    this.accessoryServiceId,
    this.melhfaServiceId,
    required this.serviceName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.likesCount,
    required this.userHasLiked,
    required this.canEdit,
  });

  String get serviceType {
    if (hammamServiceId != null) return 'hammam';
    if (gymServiceId != null) return 'gym';
    if (makeupServiceId != null) return 'makeup';
    if (hennaServiceId != null) return 'henna';
    if (accessoryServiceId != null) return 'accessory';
    if (melhfaServiceId != null) return 'melhfa';
    return 'unknown';
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['user'],
      userName: json['user_name'],
      hammamServiceId: json['hammam_service'],
      gymServiceId: json['gym_service'],
      makeupServiceId: json['makeup_service'],
      hennaServiceId: json['henna_service'],
      accessoryServiceId: json['accessory_service'],
      melhfaServiceId: json['melhfa_service'],
      serviceName: json['service_name'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      likesCount: json['likes_count'],
      userHasLiked: json['user_has_liked'],
      canEdit: json['can_edit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'user_name': userName,
      'hammam_service': hammamServiceId,
      'gym_service': gymServiceId,
      'makeup_service': makeupServiceId,
      'henna_service': hennaServiceId,
      'accessory_service': accessoryServiceId,
      'melhfa_service': melhfaServiceId,
      'service_name': serviceName,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'likes_count': likesCount,
      'user_has_liked': userHasLiked,
      'can_edit': canEdit,
    };
  }
} 