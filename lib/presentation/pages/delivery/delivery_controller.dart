import 'package:get/get.dart';
import 'package:tasty_go/data/services/auth_service.dart';
import 'package:tasty_go/presentation/navigation/app_routes.dart';

class DeliveryController extends GetxController {
  final AuthService _authService = AuthService();
  
  // Track current route for sidebar highlighting
  var currentRoute = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Use Get.currentRoute, but if it's splash, default to deliveryHome
    final route = Get.currentRoute;
    currentRoute.value = (route == '/' || route == '' || route == Routes.splash) 
        ? Routes.deliveryHome 
        : route;
  }

  void logout() async {
    await _authService.signOut();
    Get.offAllNamed(Routes.welcome);
  }
}
