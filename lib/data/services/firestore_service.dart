import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get foodItems => _firestore.collection('food_items');
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get orders => _firestore.collection('orders');

  // Get Firestore instance
  FirebaseFirestore get firestore => _firestore;

  // Helper method to enable offline persistence
  Future<void> enablePersistence() async {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
