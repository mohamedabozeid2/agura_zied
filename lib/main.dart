import 'package:again/core/api/agora_dio_helper.dart';
import 'package:again/core/hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Constants.directory = await getApplicationDocumentsDirectory();
  await HiveHelper.init(path: Constants.directory!.path);
  await AgoraDiohelper.init();
  runApp(
    const MyApp(),
  );
}
