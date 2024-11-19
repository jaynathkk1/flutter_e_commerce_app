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
}
