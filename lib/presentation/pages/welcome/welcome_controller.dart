import 'package:get/get.dart';
import '../../navigation/app_routes.dart';

class WelcomeController extends GetxController {
  void onGetStarted() {
    Get.offNamed(Routes.login);
  }
}
