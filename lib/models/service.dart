class Service {
  final int id;
  final String nom;
  final String description;
  final double prix;
  final String? image;
  final int? fournisseur;
  final double? avgRating;

  Service({
    required this.id,
    required this.nom,
    required this.description,
    required this.prix,
    this.image,
    this.fournisseur,
    this.avgRating = 0.0,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      nom: json['nom'] ?? json['name'],
      description: json['description'],
      prix: double.parse(json['prix'].toString()),
      image: json['image'],
      fournisseur: json['fournisseur'],
      avgRating: json['avg_rating'] != null ? double.parse(json['avg_rating'].toString()) : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'prix': prix,
      'image': image,
      'fournisseur': fournisseur,
      'avg_rating': avgRating,
    };
  }
} 