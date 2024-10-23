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

class FileManager {
  ///
  static Future<List<String>> selectFile({String? defaultPath}) async {
    int port = await Server.start();
    Get.put(CheckController());
    Get.put(FMController()..setPort(port));
    await Permission.manageExternalStorage.request();
    await Permission.storage.request();
    Directory? directory = await getExternalStorageDirectory();
    Log.i('directory ${directory!.path}');
    String package = RuntimeEnvir.packageName!;
    String replace = '/Android/data/$package/files';
    String sdcardPath = directory.path.replaceAll(replace, '');
    FMController controller = Get.find();
    controller.enterDir(sdcardPath);
    bool? isSelect = await Get.to(const FileAppSelectPage());
    if (isSelect == null || !isSelect) {
      return [];
    }
    List<String> paths = [];
    CheckController checkController = Get.find();
    Log.i(checkController.check);
    for (final item in checkController.check) {
      paths.add(item?.sourceDir ?? '');
    }
    if (controller.selectFiles.isNotEmpty) {
      List<String> list = controller.selectFiles.map((e) => '${e.parent!.path}/${e.name}').toList();
      paths.addAll(list);
    }
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
