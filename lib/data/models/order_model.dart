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
    return OrderItem(
      foodId: json['foodId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
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
  final String paymentMethod;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
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
    required this.paymentMethod,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
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
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'tax': tax,
      'deliveryFee': deliveryFee,
      'total': total,
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
      paymentMethod: json['paymentMethod'] ?? '',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
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
