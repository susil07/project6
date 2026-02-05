import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasty_go/data/models/address_model.dart';
import 'package:tasty_go/data/services/address_service.dart';

class AddressManagementController extends GetxController {
  final AddressService _addressService = AddressService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  var addresses = <AddressModel>[].obs;
  var isLoading = true.obs;
  var isAddingAddress = false.obs;
  var isMapLoading = true.obs;
  var isGeocoding = false.obs;
  
  // Google Map Controller
  GoogleMapController? mapController;
  final initialCameraPosition = const CameraPosition(
    target: LatLng(17.3850, 78.4867), // Default Hyderabad
    zoom: 15,
  );
  
  // Form Controllers
  final labelController = TextEditingController();
  final houseNoController = TextEditingController();
  final landmarkController = TextEditingController(); // Optional
  final streetController = TextEditingController(); // Auto-filled
  final cityController = TextEditingController(); // Auto-filled
  final pincodeController = TextEditingController(); // Auto-filled
  final phoneController = TextEditingController();
  
  var selectedLatitude = 0.0.obs;
  var selectedLongitude = 0.0.obs;
  var selectedLabel = 'Home'.obs; // Default label

  @override
  void onInit() {
    super.onInit();
    _loadAddresses();
    _initLocation();
  }

  void _loadAddresses() {
    final user = _auth.currentUser;
    if (user != null) {
      addresses.bindStream(_addressService.getAddressesStream(user.uid));
      isLoading.value = false;
    }
  }

  Future<void> _initLocation() async {
    // If we have saved addresses, use the default one as initial or current location
    var status = await Permission.location.request();
    if (status.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
        );
        selectedLatitude.value = position.latitude;
        selectedLongitude.value = position.longitude;
        isMapLoading.value = false;
        
        // Move camera if map is ready
        mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
        
        // Initial reverse geocode
        _reverseGeocode(position.latitude, position.longitude);
      } catch (e) {
        isMapLoading.value = false;
      }
    } else {
      isMapLoading.value = false;
    }
  }

  void onCameraIdle() {
    // When user stops dragging map
    if (selectedLatitude.value != 0 && selectedLongitude.value != 0) {
      _reverseGeocode(selectedLatitude.value, selectedLongitude.value);
    }
  }

  void onCameraMove(CameraPosition position) {
    selectedLatitude.value = position.target.latitude;
    selectedLongitude.value = position.target.longitude;
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      isGeocoding.value = true;
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        
        // Fill form fields
        streetController.text = '${place.thoroughfare ?? ''} ${place.subThoroughfare ?? ''}'.trim();
        if (streetController.text.isEmpty) {
             streetController.text = place.street ?? '';
        }

        cityController.text = place.locality ?? place.subLocality ?? '';
        pincodeController.text = place.postalCode ?? '';
        
        // If street is still empty, try name
        if (streetController.text.isEmpty) {
          streetController.text = place.name ?? '';
        }
      }
    } catch (e) {
      print('Reverse geocoding failed: $e');
    } finally {
      isGeocoding.value = false;
    }
  }
  
  Future<void> locateMe() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      final position = await Geolocator.getCurrentPosition();
      mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
      // Camera move listener will update lat/long and trigger geocode
    }
  }

  Future<void> saveAddress({bool isDefault = false}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (labelController.text.isEmpty || 
        streetController.text.isEmpty || 
        houseNoController.text.isEmpty ||
        phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all mandatory fields');
      return;
    }

    isAddingAddress.value = true;
    try {
      final fullAddr = '${houseNoController.text}, ${streetController.text}, ${landmarkController.text}';
      
      final newAddress = AddressModel(
        id: '', // Generated by Firestore
        label: labelController.text,
        fullAddress: fullAddr,
        city: cityController.text,
        pincode: pincodeController.text,
        phone: phoneController.text,
        latitude: selectedLatitude.value,
        longitude: selectedLongitude.value,
        isDefault: isDefault,
        createdAt: DateTime.now(),
      );

      await _addressService.addAddress(user.uid, newAddress);
      Get.back(); // Close page
      Get.snackbar('Success', 'Address saved successfully');
      _clearForm();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save address: $e');
    } finally {
      isAddingAddress.value = false;
    }
  }

  // ... Previous delete/default methods maintained ...
  Future<void> deleteAddress(String id) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _addressService.deleteAddress(user.uid, id);
    }
  }
  
  Future<void> setDefault(String id) async {
      final user = _auth.currentUser;
      if (user != null) {
        await _addressService.setDefaultAddress(user.uid, id);
      }
    }

  void _clearForm() {
    labelController.clear();
    houseNoController.clear();
    landmarkController.clear();
    streetController.clear();
    cityController.clear();
    pincodeController.clear();
    phoneController.clear();
    selectedLatitude.value = 0.0;
    selectedLongitude.value = 0.0;
    selectedLabel.value = 'Home';
  }
  
  @override
  void onClose() {
    mapController?.dispose();
    labelController.dispose();
    houseNoController.dispose();
    landmarkController.dispose();
    streetController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
