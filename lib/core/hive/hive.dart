import 'package:hive_flutter/adapters.dart';
import 'hive_keys.dart';
class HiveHelper {
  static late Box<int> uid;

  static Future<void> init({
    required String path,
  }) async {
    await Hive.initFlutter(path);

    uid = await Hive.openBox<int>(HiveKeys.uid);
  }

  static Future<void> putInBox({
    required Box box,
    required String key,
    required dynamic data,
  }) async {
    return await box.put(key, data);
  }
  
    static dynamic getBoxData({
    required Box box,
    required String key,
  }) {
    return box.get(key, defaultValue: 0);
  }

    static void removeData({
    required Box box,
    required String key,
  }) {
    box.put(key, false);
  }
}
