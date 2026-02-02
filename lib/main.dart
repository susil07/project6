import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tasty_go/core/theme/app_theme.dart';
import 'package:tasty_go/presentation/navigation/app_pages.dart';
import 'package:tasty_go/presentation/navigation/app_routes.dart';
import 'package:tasty_go/presentation/controllers/theme_controller.dart';
import 'package:tasty_go/presentation/controllers/initial_binding.dart';
import 'package:tasty_go/presentation/controllers/cart_binding.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(ThemeController());
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️  Firebase initialization error: $e');
    print('   Run: ./scripts/firebase_setup.sh to configure Firebase');
  }
  
  runApp(const TastyGoApp());
}

class TastyGoApp extends StatelessWidget {
  const TastyGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamic design size based on current window width
        final bool isLargeScreen = constraints.maxWidth > 800;
        final Size designSize = isLargeScreen 
            ? const Size(1440, 1024) 
            : const Size(375, 812);

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            final themeController = Get.find<ThemeController>();
            return GetMaterialApp(
              title: 'TastyGo',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeController.theme,
              initialBinding: InitialBinding(),
              initialRoute: Routes.splash,
              getPages: AppPages.pages,
            );
          },
        );
      },
    );
  }
}
