class Category {
  final int id;
  final String nom;
  final String description;
  final String? image;
  final String? categoryType;

  Category({
    required this.id,
    required this.nom,
    required this.description,
    this.image,
    this.categoryType,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      image: json['image'],
      categoryType: json['category_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'image': image,
      'category_type': categoryType,
    };
  }
} 