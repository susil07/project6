import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasty_go/data/models/address_model.dart';

class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference _getAddressesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('addresses');
  }

  // Get stream of addresses
  Stream<List<AddressModel>> getAddressesStream(String userId) {
    return _getAddressesCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AddressModel.fromFirestore(doc)).toList();
    });
  }

  // Add new address
  Future<void> addAddress(String userId, AddressModel address) async {
    // If this is the first address or set as default, handle defaults
    if (address.isDefault) {
      await _clearDefaultAddress(userId);
    }
    
    // Check if it's the only address, make it default automatically
    final snapshot = await _getAddressesCollection(userId).get();
    final bool shouldBeDefault = snapshot.docs.isEmpty || address.isDefault;

    await _getAddressesCollection(userId).add({
      ...address.toJson(),
      'isDefault': shouldBeDefault,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update address
  Future<void> updateAddress(String userId, AddressModel address) async {
    if (address.isDefault) {
      await _clearDefaultAddress(userId);
    }
    await _getAddressesCollection(userId).doc(address.id).update(address.toJson());
  }

  // Delete address
  Future<void> deleteAddress(String userId, String addressId) async {
    await _getAddressesCollection(userId).doc(addressId).delete();
  }

  // Set specific address as default
  Future<void> setDefaultAddress(String userId, String addressId) async {
    await _clearDefaultAddress(userId);
    await _getAddressesCollection(userId).doc(addressId).update({'isDefault': true});
  }

  // Helper to clear default flag from all addresses
  Future<void> _clearDefaultAddress(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _getAddressesCollection(userId)
        .where('isDefault', isEqualTo: true)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }
}
