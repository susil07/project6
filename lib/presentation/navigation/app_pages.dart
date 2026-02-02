import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/splash/splash_page.dart';
import 'package:tasty_go/presentation/pages/splash/splash_binding.dart';
import 'package:tasty_go/presentation/pages/welcome/welcome_page.dart';
import 'package:tasty_go/presentation/pages/welcome/welcome_binding.dart';
import 'package:tasty_go/presentation/pages/auth/auth_page.dart';
import 'package:tasty_go/presentation/pages/auth/auth_binding.dart';
import 'package:tasty_go/presentation/pages/auth/pending_approval_page.dart';
import 'package:tasty_go/presentation/pages/home/home_page.dart';
import 'package:tasty_go/presentation/pages/home/home_binding.dart';
import 'package:tasty_go/presentation/pages/admin/admin_binding.dart';
import 'package:tasty_go/presentation/pages/admin/home/admin_home_page.dart';
import 'package:tasty_go/presentation/pages/admin/home/admin_home_binding.dart';
import 'package:tasty_go/presentation/pages/admin/users/user_management_page.dart';
import 'package:tasty_go/presentation/pages/admin/users/user_management_binding.dart';
import 'package:tasty_go/presentation/pages/cart/cart_page.dart';
import 'package:tasty_go/presentation/controllers/cart_binding.dart';
import 'package:tasty_go/presentation/pages/checkout/checkout_page.dart';
import 'package:tasty_go/presentation/pages/checkout/checkout_binding.dart';
import 'package:tasty_go/presentation/pages/checkout/order_confirmation_page.dart';
import 'package:tasty_go/presentation/pages/orders/orders_page.dart';
import 'package:tasty_go/presentation/pages/orders/orders_binding.dart';
import 'package:tasty_go/presentation/pages/orders/tracking/order_tracking_page.dart';
import 'package:tasty_go/presentation/pages/orders/tracking/order_tracking_binding.dart';
import 'package:tasty_go/presentation/pages/delivery/delivery_binding.dart';
import 'package:tasty_go/presentation/pages/delivery/home/delivery_home_page.dart';
import 'package:tasty_go/presentation/pages/delivery/home/delivery_home_binding.dart';
import 'package:tasty_go/presentation/pages/delivery/profile/delivery_profile_page.dart';
import 'package:tasty_go/presentation/pages/delivery/profile/delivery_profile_binding.dart';
import 'package:tasty_go/presentation/pages/admin/food/admin_food_page.dart';
import 'package:tasty_go/presentation/pages/admin/food/admin_food_binding.dart';
import 'package:tasty_go/presentation/pages/admin/orders/admin_orders_page.dart';
import 'package:tasty_go/presentation/pages/admin/orders/admin_orders_binding.dart';
import 'package:tasty_go/presentation/pages/delivery/active/delivery_active_orders_page.dart';
import 'package:tasty_go/presentation/pages/delivery/active/delivery_active_orders_binding.dart';
import 'package:tasty_go/presentation/pages/delivery/history/delivery_history_page.dart';
import 'package:tasty_go/presentation/pages/delivery/history/delivery_history_binding.dart';
import 'package:tasty_go/presentation/pages/profile/user_profile_page.dart';
import 'package:tasty_go/presentation/pages/profile/user_profile_binding.dart';
import 'package:tasty_go/presentation/pages/favorites/favorites_page.dart';
import 'package:tasty_go/presentation/pages/favorites/favorites_binding.dart';
import 'package:tasty_go/presentation/navigation/app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.welcome,
      page: () => const WelcomePage(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const AuthPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      bindings: [AuthBinding(), HomeBinding(), CartBinding()],
    ),
    GetPage(
      name: Routes.pendingApproval,
      page: () => const PendingApprovalPage(),
    ),
    GetPage(
      name: Routes.adminHome,
      page: () => const AdminHomePage(),
      bindings: [AuthBinding(), AdminBinding(), AdminHomeBinding()],
    ),
    GetPage(
      name: Routes.adminUsers,
      page: () => const UserManagementPage(),
      bindings: [AuthBinding(), AdminBinding(), UserManagementBinding()],
    ),
    GetPage(
      name: Routes.adminFood,
      page: () => const AdminFoodPage(),
      bindings: [AuthBinding(), AdminBinding(), AdminFoodBinding()],
    ),
    GetPage(
      name: Routes.adminOrders,
      page: () => const AdminOrdersPage(),
      bindings: [AuthBinding(), AdminBinding(), AdminOrdersBinding()],
    ),
    GetPage(
      name: Routes.cart,
      page: () => const CartPage(),
      binding: CartBinding(),
    ),
    GetPage(
      name: Routes.checkout,
      page: () => const CheckoutPage(),
      bindings: [CheckoutBinding(), CartBinding()],
    ),
    GetPage(
      name: Routes.orderConfirmation,
      page: () => const OrderConfirmationPage(),
    ),
    GetPage(
      name: Routes.orderHistory,
      page: () => const OrdersPage(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: Routes.orderTracking,
      page: () => const OrderTrackingPage(),
      binding: OrderTrackingBinding(),
    ),
    GetPage(
      name: Routes.deliveryHome,
      page: () => const DeliveryHomePage(),
      bindings: [
        AuthBinding(),
        DeliveryBinding(),
        DeliveryHomeBinding(),
      ],
    ),
    GetPage(
      name: Routes.deliveryActive,
      page: () => const DeliveryActiveOrdersPage(),
      bindings: [
        AuthBinding(),
        DeliveryBinding(),
        DeliveryActiveOrdersBinding(),
      ],
    ),
    GetPage(
      name: Routes.deliveryHistory,
      page: () => const DeliveryHistoryPage(),
      bindings: [
        AuthBinding(),
        DeliveryBinding(),
        DeliveryHistoryBinding(),
      ],
    ),
    GetPage(
      name: Routes.deliveryProfile,
      page: () => const DeliveryProfilePage(),
      bindings: [
        AuthBinding(),
        DeliveryBinding(),
        DeliveryProfileBinding(),
      ],
    ),
    GetPage(
      name: Routes.profile,
      page: () => const UserProfilePage(),
      binding: UserProfileBinding(),
    ),
    GetPage(
      name: Routes.favorites,
      page: () => const FavoritesPage(),
      binding: FavoritesBinding(),
    ),
  ];
}
