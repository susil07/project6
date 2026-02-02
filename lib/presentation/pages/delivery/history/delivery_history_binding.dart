import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/delivery/history/delivery_history_controller.dart';

class DeliveryHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryHistoryController>(() => DeliveryHistoryController());
  }
}
