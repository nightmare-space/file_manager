import 'package:app_manager/controller/check_controller.dart';
import 'package:file_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'controller/file_manager_controller.dart';
import 'view/file_manager_view.dart';
import 'file_app_select/file_select_page.dart';
export 'server/file_server.dart';
export 'file_manager_page.dart';
export 'controller/file_manager_controller.dart';

class FileManager {
  ///
  static Future<List<String>> selectFile({String? defaultPath}) async {
    Get.put(CheckController());
    bool? isSelect = await Get.to(FileAppSelectPage());
    if (isSelect == null || !isSelect) {
      return [];
    }
    List<String> paths = [];
    CheckController checkController = Get.find();
    Log.i(checkController.check);
    for (final item in checkController.check) {
      paths.add(item?.sourceDir ?? '');
    }
    FMController controller = Get.find();
    if (controller.selectFiles.isNotEmpty) {
      List<String> list = controller.selectFiles.map((e) => '${e.parent!.path}${e.name}').toList();
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
