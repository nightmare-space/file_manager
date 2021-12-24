import 'dart:io';
import 'dart:ui';
import 'package:event_bus/event_bus.dart';
import 'package:file_manager/src/config/global.dart';
import 'package:file_manager/src/page/file_manager_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:global_repository/global_repository.dart';
import 'package:provider/provider.dart';
import 'colors/file_colors.dart';
import 'config/config.dart';
import 'dialog/add_entity_page.dart';
import 'dialog/window_choose.dart';
import 'home_page.dart';
import 'page/center_drawer.dart';
import 'page/file_manager_drawer.dart';
import 'page/file_manager_view.dart';
import 'provider/file_manager_notifier.dart';
import 'utils/bookmarks.dart';

Directory appDocDir;

enum FileState {
  checkWindow,
  fileDefault,
}

class FileManager extends StatelessWidget {
  FileManager() {
    Global.instance.initGlobal();
  }
  // TODO
  static Future<String> chooseFile({
    @required BuildContext context,
    String pickPath,
  }) async {
    final String documentDir = await PlatformUtil.getDocumentDirectory();
    Global.instance.clipboards = Clipboards();
    return await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          // SafeArea;
          return Theme(
            data: Theme.of(context).copyWith(
              appBarTheme: const AppBarTheme(
                color: Colors.white,
                elevation: 0.0,
              ),
            ),
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text('选择文件'),
              ),
              body: FileManagerView(
                chooseFile: true,
                controller: FileManagerController(
                  pickPath ?? '$documentDir/YanTool/Rom',
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Global.instance.clipboards = Clipboards();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Clipboards>.value(
          value: Global.instance.clipboards,
        )
      ],
      child: Theme(
        data: ThemeData(
          textTheme: const TextTheme(
            bodyText2: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconTheme: const IconThemeData(
            color: Color(
              0xff213349,
            ),
          ),
          brightness: Brightness.light,
          primaryColorBrightness: Brightness.dark,
          backgroundColor: Colors.white,
          accentColor: const Color(0xff213349),
          primaryColor: const Color(0xff213349),
        ),
        child: const FileManagerHomePage(),
      ),
    );
  }
}
