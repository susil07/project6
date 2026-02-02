class CartItem {
  final String id; // cart item ID (Firestore doc ID)
  final String foodId;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;
  final String? specialInstructions;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.foodId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    this.specialInstructions,
    required this.addedAt,
  });

  // Calculate total price for this item
  double get totalPrice => price * quantity;

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      if (specialInstructions != null) 'specialInstructions': specialInstructions,
      'addedAt': addedAt,
    };
  }

  // Create from Firestore document
  factory CartItem.fromJson(String id, Map<String, dynamic> json) {
    return CartItem(
      id: id,
      foodId: json['foodId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      quantity: json['quantity'] ?? 1,
      specialInstructions: json['specialInstructions'],
      addedAt: json['addedAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Create copy with updated fields
  CartItem copyWith({
    String? id,
    String? foodId,
    String? name,
    double? price,
    String? imageUrl,
    int? quantity,
    String? specialInstructions,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
