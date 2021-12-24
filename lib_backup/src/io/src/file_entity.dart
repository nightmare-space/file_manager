import 'package:file_manager/src/io/file_io.dart';
import 'package:global_repository/global_repository.dart';

import 'directory.dart';
import 'file.dart';

abstract class FileEntity {
  //这个名字可能带有->/x/x的字符
  String path;
  //完整信息
  String fullInfo;
  //文件创建日期

  String accessed = '';
  //文件修改日期
  String modified = '';
  //如果是文件夹才有该属性，表示它包含的项目数
  String itemsNumber = '';
  // 节点的权限信息
  String mode = '';
  // 文件的大小，isFile为true才赋值该属性
  String size = '';
  String uid = '';
  String gid = '';

  String get nodeName;
  String get parentPath => parentOf(path);
  bool get isFile => this is AbstractNiFile;
  bool get isDirectory => this is AbstractDirectory;
  static final List<String> imagetype = <String>['jpg', 'png']; //图片的所有扩展名
  static final List<String> textType = <String>[
    'smali',
    'txt',
    'xml',
    'py',
    'sh',
    'dart'
  ]; //文本的扩展名
  bool isText() {
    final String type = nodeName.replaceAll(RegExp('.*\\.'), '');
    return textType.contains(type);
  }

  bool isImg() {
    // Directory();
    // File
    final String type = nodeName.replaceAll(RegExp('.*\\.'), '');
    return imagetype.contains(type);
  }

  // 用在显示文件item的subtitle
  String get info => '$modified  $itemsNumber  $size  $mode';

  @override
  bool operator ==(dynamic other) {
    // 判断是否是非
    if (other is! FileEntity) {
      return false;
    }
    if (other is FileEntity) {
      final FileEntity entity = other;
      return path == entity.path;
    }
    return false;
  }

  @override
  int get hashCode => path.hashCode;
  Future<bool> delete() {
    throw UnimplementedError();
  }

  Future<bool> copy(AbstractNiFile to) {
    throw UnimplementedError();
  }

  Future<bool> cut(AbstractNiFile to) {
    throw UnimplementedError();
  }

  Future<bool> rename(String name) {
    throw UnimplementedError();
  }
}

mixin NiProcessBased on FileEntity {
  @override
  String get nodeName => path.split(' -> ').first.split('/').last;

  NiProcess niProcess;
}
