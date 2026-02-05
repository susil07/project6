import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItemModel {
  final String id;
  final String name;
  final String price;
  final String imageUrl;
  final String category;
  final String description;
  final double? rating;
  final DateTime? createdAt;

  FoodItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.description,
    this.rating,
    this.createdAt,
  });

  // Convert from Firestore document
  factory FoodItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    String rawPrice = data['price']?.toString() ?? '';
    // Clean price: remove 'N', '₦', and commas to get a clean number string
    String cleanPrice = rawPrice.replaceAll(RegExp(r'[N₦,]'), '').trim();
    
    return FoodItemModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: cleanPrice,
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      rating: data['rating']?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert from JSON
  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    String rawPrice = json['price']?.toString() ?? '';
    String cleanPrice = rawPrice.replaceAll(RegExp(r'[N₦,]'), '').trim();
    
    return FoodItemModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: cleanPrice,
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      rating: json['rating']?.toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  // Convert to JSON (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'description': description,
      'rating': rating,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  // Convert to Map (without Firestore-specific types)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'description': description,
      'rating': rating,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
