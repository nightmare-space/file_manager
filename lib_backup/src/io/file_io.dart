library file_io;

export 'src/directory.dart';
export 'src/file.dart';
export 'src/file_entity.dart';

bool enableIOVerbose = false;

final RegExp _parentRegExp = RegExp(r'[^/]/+[^/]');
String parentOf(String path) {
  int rootEnd = -1;
  if (path.startsWith('/')) {
    rootEnd = 0;
  }
  // Ignore trailing slashes.
  // All non-trivial cases have separators between two non-separators.
  int pos = path.lastIndexOf(_parentRegExp);
  if (pos > rootEnd) {
    return path.substring(0, pos + 1);
  } else if (rootEnd > -1) {
    return path.substring(0, rootEnd + 1);
  } else {
    return '.';
  }
}
