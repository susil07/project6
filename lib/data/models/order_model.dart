import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String foodId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.foodId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    var rawPrice = json['price'];
    double priceValue = 0.0;
    if (rawPrice is num) {
      priceValue = rawPrice.toDouble();
    } else if (rawPrice is String) {
      priceValue = double.tryParse(rawPrice.replaceAll(RegExp(r'[N₦,₹]'), '').trim()) ?? 0.0;
    }

    return OrderItem(
      foodId: json['foodId'] ?? '',
      name: json['name'] ?? '',
      price: priceValue,
      quantity: json['quantity'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class FoodOrder {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String paymentMethod;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final double? restaurantLatitude;
  final double? restaurantLongitude;
  final String? restaurantName;
  final String? restaurantAddress;
  final String status; // pending, confirmed, preparing, out_for_delivery, delivered, cancelled
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? deliveryPartnerId;
  final DeliveryLocation? deliveryPartnerLocation;
  final double? estimatedDeliveryMinutes;

  FoodOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.paymentMethod,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    this.restaurantLatitude,
    this.restaurantLongitude,
    this.restaurantName,
    this.restaurantAddress,
    this.status = 'pending',
    required this.createdAt,
    this.deliveredAt,
    this.deliveryPartnerId,
    this.deliveryPartnerLocation,
    this.estimatedDeliveryMinutes,
  });

  // Status helpers
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isPreparing => status == 'preparing';
  bool get isOutForDelivery => status == 'out_for_delivery';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';

  // Helper getters
  String get userName => deliveryAddress.split(',').first;
  double get totalPrice => total;
  String get address => deliveryAddress;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'deliveryAddress': deliveryAddress,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'tax': tax,
      'deliveryFee': deliveryFee,
      'total': total,
      if (restaurantLatitude != null) 'restaurantLatitude': restaurantLatitude,
      if (restaurantLongitude != null) 'restaurantLongitude': restaurantLongitude,
      if (restaurantName != null) 'restaurantName': restaurantName,
      if (restaurantAddress != null) 'restaurantAddress': restaurantAddress,
      'status': status,
      'createdAt': createdAt,
      if (deliveredAt != null) 'deliveredAt': deliveredAt,
      if (deliveryPartnerId != null) 'deliveryPartnerId': deliveryPartnerId,
      if (deliveryPartnerLocation != null) 'deliveryPartnerLocation': deliveryPartnerLocation?.toJson(),
      if (estimatedDeliveryMinutes != null) 'estimatedDeliveryMinutes': estimatedDeliveryMinutes,
    };
  }

  factory FoodOrder.fromJson(String id, Map<String, dynamic> json) {
    return FoodOrder(
      id: id,
      userId: json['userId'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      deliveryAddress: json['deliveryAddress'] ?? '',
      deliveryLatitude: (json['deliveryLatitude'] ?? 0).toDouble(),
      deliveryLongitude: (json['deliveryLongitude'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      restaurantLatitude: (json['restaurantLatitude'] ?? 0).toDouble(),
      restaurantLongitude: (json['restaurantLongitude'] ?? 0).toDouble(),
      restaurantName: json['restaurantName'],
      restaurantAddress: json['restaurantAddress'],
      status: json['status'] ?? 'pending',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveredAt: (json['deliveredAt'] as Timestamp?)?.toDate(),
      deliveryPartnerId: json['deliveryPartnerId'],
      deliveryPartnerLocation: json['deliveryPartnerLocation'] != null
          ? DeliveryLocation.fromJson(json['deliveryPartnerLocation'])
          : null,
      estimatedDeliveryMinutes: (json['estimatedDeliveryMinutes'] ?? 0).toDouble(),
    );
  }
}

class DeliveryLocation {
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  DeliveryLocation({
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': updatedAt,
    };
  }

  factory DeliveryLocation.fromJson(Map<String, dynamic> json) {
    return DeliveryLocation(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
