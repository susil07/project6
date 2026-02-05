import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String label; // e.g., 'Home', 'Work', 'Other'
  final String fullAddress;
  final String city;
  final String pincode;
  final String phone;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final DateTime createdAt;

  AddressModel({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.city,
    required this.pincode,
    required this.phone,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'fullAddress': fullAddress,
      'city': city,
      'pincode': pincode,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'createdAt': createdAt,
    };
  }

  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel(
      id: doc.id,
      label: data['label'] ?? 'Home',
      fullAddress: data['fullAddress'] ?? '',
      city: data['city'] ?? '',
      pincode: data['pincode'] ?? '',
      phone: data['phone'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      isDefault: data['isDefault'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  AddressModel copyWith({
    String? id,
    String? label,
    String? fullAddress,
    String? city,
    String? pincode,
    String? phone,
    double? latitude,
    double? longitude,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
