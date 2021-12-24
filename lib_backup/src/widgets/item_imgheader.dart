import 'dart:io';
import 'dart:typed_data';

import 'dart:ui' as ui;
import 'package:file_manager/src/config/config.dart';
import 'package:file_manager/src/io/src/file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../io/src/file.dart';

class ItemImgHeader extends StatefulWidget {
  const ItemImgHeader({Key key, this.fileNode}) : super(key: key);
  final AbstractNiFile fileNode;

  @override
  _ItemImgHeaderState createState() => _ItemImgHeaderState();
}

class _ItemImgHeaderState extends State<ItemImgHeader> {
  GlobalKey rootWidgetKey = GlobalKey();
  bool prepare = false;
  String imgPath;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    // if (!await Directory('${Config.filesPath}/FileManager/img_cache')
    //     .exists()) {
    //   Directory('${Config.filesPath}/FileManager/img_cache')
    //       .createSync(recursive: true);
    // }
    final String cacheName = widget.fileNode.path.replaceAll('/', '_');
    final bool cacheExist =
        await File('${Config.filesPath}/FileManager/img_cache/$cacheName')
            .exists();
    if (cacheExist) {
      imgPath = '${Config.filesPath}/FileManager/img_cache/$cacheName';
      prepare = true;
      setState(() {});
      saveCacheImg();
    } else {
      imgPath = widget.fileNode.path;
      prepare = true;
      setState(() {});
      // saveCacheImg();
    }
  }

  void saveCacheImg() {
    final String cacheName = widget.fileNode.path.replaceAll('/', '_');
    Future<void>.delayed(const Duration(milliseconds: 300), () async {
      final Uint8List uint8list = await _capturePng(rootWidgetKey);
      if (uint8list == null) {
        imgPath = widget.fileNode.path;
        prepare = true;
        setState(() {});
        saveCacheImg();
        return;
      }
      File('${Config.filesPath}/FileManager/img_cache/$cacheName')
          .writeAsBytesSync(uint8list);
    });
  }

  Future<Uint8List> _capturePng(GlobalKey globalKey) async {
    if (globalKey.currentContext != null) {
      return null;
    }
    final RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image =
        await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
    final ByteData byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List picBytes = byteData.buffer.asUint8List();
    return picBytes;
  }

  @override
  Widget build(BuildContext context) {
    return prepare
        ? RepaintBoundary(
            key: rootWidgetKey,
            child: Hero(
              tag: widget.fileNode.path,
              child: Image.file(File(imgPath)),
            ))
        : const SizedBox();
  }
}
