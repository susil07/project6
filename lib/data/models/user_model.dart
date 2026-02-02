class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'user', 'delivery_partner', 'admin'
  final String status; // 'pending', 'approved', 'rejected', 'blocked'
  final String? statusNote; // Optional reason for rejection/blocking
  final String? approvedBy; // Admin UID who approved
  final DateTime? approvedAt; // Approval timestamp
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> favorites;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.status = 'pending',
    this.statusNote,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    this.updatedAt,
    this.favorites = const [],
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'status': status,
      if (statusNote != null) 'statusNote': statusNote,
      if (approvedBy != null) 'approvedBy': approvedBy,
      if (approvedAt != null) 'approvedAt': approvedAt,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      'favorites': favorites,
    };
  }

  // Create from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      role: json['role'] ?? 'user',
      status: json['status'] ?? 'pending',
      statusNote: json['statusNote'],
      approvedBy: json['approvedBy'],
      approvedAt: json['approvedAt']?.toDate(),
      createdAt: json['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: json['updatedAt']?.toDate(),
      favorites: List<String>.from(json['favorites'] ?? []),
    );
  }

  // Create copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? role,
    String? status,
    String? statusNote,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? favorites,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      status: status ?? this.status,
      statusNote: statusNote ?? this.statusNote,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      favorites: favorites ?? this.favorites,
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isBlocked => status == 'blocked';
  bool get isAdmin => role == 'admin';
}
