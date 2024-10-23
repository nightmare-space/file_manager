import 'package:file_manager/controller/file_manager_controller.dart';
import 'package:file_manager/utils/ext_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'dart:io' as io;

import '../config/config.dart';

Widget getIconByExt(String path) {
  Widget? child;
  if (path.isVideo) {
    child = Image.asset(
      'assets/video.png',
      width: 36.w,
      height: 36.w,
      package: Config.package,
    );
  } else if (path.isPdf) {
    child = Image.asset(
      'assets/pdf.png',
      width: 36.w,
      height: 36.w,
      package: Config.package,
    );
  } else if (path.isDoc) {
    child = Image.asset(
      'assets/doc.png',
      width: 36.w,
      height: 36.w,
      package: Config.package,
    );
  } else if (path.isZip) {
    child = Image.asset(
      'assets/zip.png',
      width: 36.w,
      height: 36.w,
      package: Config.package,
    );
  } else if (path.isAudio) {
    child = Image.asset(
      'assets/mp3.png',
      width: 36.w,
      height: 36.w,
      package: Config.package,
    );
  } else if (path.isImg) {
    FMController controller = Get.find();
    // Directory dir = fileManagerController.dir;
    // if (dir is DirectoryBrowser && dir.addr != null) {
    //   Uri uri = Uri.tryParse((fileManagerController.dir as DirectoryBrowser).addr)!;
    //   String perfix = 'http://${uri.host}:${Config.port}';
    //   path = perfix + path;
    // }
    String url = controller.api.getFileUrl(path);
    // Log.i('url $url');
    return Hero(
      tag: path,
      child: Image(
        width: 36.w,
        height: 36.w,
        fit: BoxFit.cover,
        image: ResizeImage(
          NetworkImage(controller.api.getFileUrl(path)),
          width: 200,
        ),
      ),
    );
  }

  child ??= Image.asset(
    'assets/other.png',
    width: 36.w,
    height: 36.w,
    package: Config.package,
  );
  return child;
}
