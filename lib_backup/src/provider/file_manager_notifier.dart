import 'package:file_manager/src/io/src/file_entity.dart';
import 'package:flutter/material.dart';

enum ClipType {
  Cut,
  Copy,
}

// 用来存剪切板
class Clipboards extends ChangeNotifier {
  List<FileEntity> checkNodes = <FileEntity>[];
  final List<String> _clipboard = <String>[];
  ClipType _clipType;
  ClipType get clipType => _clipType;
  List<String> get clipboard => _clipboard;
  void addCheck(FileEntity fileNode) {
    // print('$this addCheck');
    if (!checkNodes.contains(fileNode)) {
      checkNodes.add(fileNode);
    }
    // print(checkNodes);
  }

  void removeCheck(FileEntity fileNode) {
    checkNodes.remove(fileNode);
  }

  void clearCheck() {
    checkNodes.clear();
    notifyListeners();
  }

  void addClipBoard(ClipType clipType, String path) {
    print('添加$path到剪切板');
    _clipType = clipType;
    if (!clipboard.contains(path)) {
      _clipboard.add(path);
    }
    notifyListeners();
  }

  void clearClipBoard() {
    _clipboard.clear();
    notifyListeners();
  }
}
