import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _initialized = true;
  }

  static Future<Box> openBox(String name) async {
    await init();
    return Hive.openBox(name);
  }
}
