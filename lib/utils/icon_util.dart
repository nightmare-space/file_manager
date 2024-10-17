import 'package:file_manager/utils/ext_util.dart';
import 'package:flutter/material.dart';
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
    // Directory dir = fileManagerController.dir;
    // if (dir is DirectoryBrowser && dir.addr != null) {
    //   Uri uri = Uri.tryParse((fileManagerController.dir as DirectoryBrowser).addr)!;
    //   String perfix = 'http://${uri.host}:${Config.port}';
    //   path = perfix + path;
    // }
    // return Hero(
    //   tag: path,
    //   child: path.startsWith('http')
    //       ? Image(
    //           width: 36.w,
    //           height: 36.w,
    //           fit: BoxFit.cover,
    //           image: ResizeImage(
    //             NetworkImage(path),
    //             width: 36,
    //           ),
    //         )
    //       : Image(
    //           image: ResizeImage(
    //             FileImage(io.File(path)),
    //             width: 36,
    //           ),
    //           width: 36.w,
    //           height: 36.w,
    //           fit: BoxFit.cover,
    //         ),
    // );
  }

  child ??= Image.asset(
    'assets/other.png',
    width: 36.w,
    height: 36.w,
    package: Config.package,
  );
  return child;
}
