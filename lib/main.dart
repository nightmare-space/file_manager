import 'dart:io';

import 'package:file_manager/controller/file_manager_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:global_repository/global_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'config/config.dart';
import 'controller/file_manager_api.dart';
import 'file_manager_page.dart';
import 'view/file_manager_view.dart';
import 'server/file_server.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = (await getApplicationSupportDirectory()).path;
  Log.d('ApplicationSupportDirectory: $dir');
  RuntimeEnvir.initEnvirWithPackageName('com.nightmare.file_manager', appSupportDirectory: dir);
  int port = await Server.start();
  FMController controller = FMController();
  controller.setPort(port, isRemote: true);
  Get.put<FMController>(controller);
  runApp(const MyApp());
  StatusBarUtil.transparent();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    Directory? directory;
    if (GetPlatform.isAndroid) {
      await Permission.manageExternalStorage.request();
      await Permission.storage.request();
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getDownloadsDirectory();
    }
    Log.i('directory ${directory!.path}');
    String package = RuntimeEnvir.packageName!;
    String replace = '/Android/data/$package/files';
    String sdcardPath = directory.path.replaceAll(replace, '');
    FMController controller = Get.find();
    controller.enterDir(sdcardPath);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      defaultTransition: Transition.native,
      home: const FileManagerPage(),
    );
  }
}

String formatBytes(int bytes) {
  if (bytes <= 0) return "0B";
  const List<String> sizes = ["B", "K", "M", "G"];
  int i = 0;
  double size = bytes.toDouble();

  while (size >= 1024 && i < sizes.length - 1) {
    size /= 1024;
    i++;
  }

  return "${size.toStringAsFixed(2)}${sizes[i]}";
}
