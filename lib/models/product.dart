class Product {
  final String id;
  final String name;
  final String image;
  final String description;
  final int oldPrice;
  final int newPrice;
  final String category;
  final int maxQuantity;

  Product(
      {required this.id,
      required this.name,
      required this.image,
      required this.description,
      required this.oldPrice,
      required this.newPrice,
      required this.category,
      required this.maxQuantity});

  factory Product.fromFirestore(Map<String, dynamic> doc) {
    return Product(
        id: doc['id'] ?? '',
        name: doc['name'] ?? '',
        image: doc['image'] ?? '',
        description: doc['description'] ?? '',
        oldPrice: doc['old_price'] ?? 0,
        newPrice: doc['new_price'] ?? 0,
        category: doc['category'] ?? '',
        maxQuantity: doc['maxQuantity'] ?? 0);
  }
  // Convert Product instance to Map (for serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'old_price': oldPrice,
      'new_price': newPrice,
      'category': category,
      'maxQuantity': maxQuantity,
    };
  }
}
