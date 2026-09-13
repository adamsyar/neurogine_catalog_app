class Product {
  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.thumbnail,
    required List<String> images,
  }) : images = List.unmodifiable(images);

  final int id;
  final String title;
  final String description;
  final double price;
  final double rating;
  final String thumbnail;
  final List<String> images;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      thumbnail: json['thumbnail'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? []).cast<String>(),
    );
  }
}
