import 'dart:io';

import 'package:app_manager/controller/check_controller.dart';
import 'package:file_manager/main.dart';
import 'package:file_manager/server/file_server.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path_provider/path_provider.dart';

import 'controller/file_manager_controller.dart';
import 'view/file_manager_view.dart';
import 'file_app_select/file_select_page.dart';
export 'server/file_server.dart';
export 'file_manager_page.dart';
export 'controller/file_manager_controller.dart';

Future<String> _getExtenalStoragePath() async {
  Directory? directory = await getExternalStorageDirectory();
  Log.i('directory ${directory!.path}');
  String package = RuntimeEnvir.packageName!;
  String replace = '/Android/data/$package/files';
  String sdcardPath = directory.path.replaceAll(replace, '');
  return sdcardPath;
}

Future<void> requestPermission() async {
  await Permission.manageExternalStorage.request();
  await Permission.storage.request();
}

class FileManager {
  ///
  static Future<List<String>> selectFile({String? defaultPath}) async {
    int port = await Server.start();
    Get.put(CheckController());
    FMController fmController = FMController()..setPort(port);
    Get.replace(fmController);
    await requestPermission();
    FMController controller = Get.find();
    controller.enterDir(await _getExtenalStoragePath());
    bool? isSelect = await Get.to(const FileAppSelectPage());
    if (isSelect == null || !isSelect) {
      return [];
    }
    // TODO(lin): rename CheckController to AppSelectController
    CheckController checkController = Get.find();
    List<String> paths = checkController.check.map((e) => e?.sourceDir ?? '').toList();
    Log.i('checkController.check -> ${checkController.check}');
    if (controller.selectFiles.isNotEmpty) {
      List<String> list = controller.selectFiles.map((e) => '${e.parent!.path}/${e.name}').toList();
      paths.addAll(list);
    }
    Get.delete<CheckController>();
    return paths;
  }

  static Future<String?> selectDirectory({String? defaultPath}) async {
    // bool isSelect = await Get.to(const FileManagerSelectPage());
    // if (!isSelect) {
    //   return '';
    // }
    // FMController controller = Get.find();
    // return controller.currentPath;
    return '';
  }
}
