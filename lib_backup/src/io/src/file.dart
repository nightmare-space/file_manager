import 'package:global_repository/global_repository.dart';

import 'file_entity.dart';

abstract class AbstractNiFile extends FileEntity {
  AbstractNiFile(this._path, this._fullInfo);

  factory AbstractNiFile.getPlatformFile(String _path, String _fullInfo) {
    // TODO: 根据平台返回
    return NiFileLinux(_path, _fullInfo ?? '');
  }

  final String _path;
  @override
  String get path => _path;

  final String _fullInfo;
  @override
  String get fullInfo => _fullInfo;
}

class NiFileLinux extends AbstractNiFile with NiProcessBased {
  NiFileLinux(String path, String fullInfo) : super(path, fullInfo);
  @override
  Future<bool> rename(String name) async {
    await NiProcess.exec('mv $path $parentPath/$name');
    return true;
  }
  // @override
  // Future<bool> delete() async {
  //   return true;
  // }
}
