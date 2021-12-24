import 'dart:io';

import 'package:file_manager/src/config/config.dart';

class BookMarks {
  static Future<void> addMarks(String path) async {
    List<String> tmpMarks = <String>[];
    final File marksFile = File('${Config.filesPath}/FileManager/bookmarks');
    if (await marksFile.exists()) {
      tmpMarks = await marksFile.readAsLines();
    }
    tmpMarks.add(path);
    await marksFile.writeAsString(tmpMarks.join('\n'));
  }

  static Future<void> removeMarks(String path) async {
    List<String> tmpMarks = <String>[];
    final File marksFile = File('${Config.filesPath}/FileManager/bookmarks');
    if (await marksFile.exists()) {
      tmpMarks = await marksFile.readAsLines();
    }
    tmpMarks.removeAt(tmpMarks.indexOf(path));
    await marksFile.writeAsString(tmpMarks.join('\n'));
  }

  static Future<List<String>> getBookMarks() async {
    List<String> tmpMarks = <String>[];
    final File marksFile = File('${Config.filesPath}/FileManager/bookmarks');
    if (await marksFile.exists()) {
      tmpMarks = await marksFile.readAsLines();
    }
    return tmpMarks;
  }
}
