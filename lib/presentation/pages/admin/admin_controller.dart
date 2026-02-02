import 'package:get/get.dart';
import 'package:tasty_go/data/services/auth_service.dart';

class AdminController extends GetxController {
  final AuthService _authService = AuthService();
  
  var currentRoute = '/admin'.obs;

  void setCurrentRoute(String route) {
    currentRoute.value = route;
  }

  Future<void> logout() async {
    await _authService.signOut();
    Get.offAllNamed('/welcome');
  }
}
