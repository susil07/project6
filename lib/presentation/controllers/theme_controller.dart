import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  final _isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _isDarkMode.value = _loadThemeFromBox();
  }

  ThemeMode get theme => _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  bool _loadThemeFromBox() => _box.read(_key) ?? false;

  void saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  void switchTheme() {
    final newValue = !_isDarkMode.value;
    Get.changeThemeMode(newValue ? ThemeMode.dark : ThemeMode.light);
    _isDarkMode.value = newValue;
    saveThemeToBox(newValue);
  }

  bool get isDarkMode => _isDarkMode.value;
}
