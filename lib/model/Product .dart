class Product {
  final String id;
  final String title;
  final String description;
  final String price;
  final String category;
  final String imagePath;
  bool isFavorite;
  bool isNew;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.imagePath,
    this.isFavorite = false,
    this.isNew = false,
  });
}