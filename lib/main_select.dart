import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'file_manager.dart';
import 'file_app_select/file_select_page.dart';
import 'server/file_server.dart';

Future<void> main(List<String> args) async {
  RuntimeEnvir.initEnvirWithPackageName('com.nightmare.file_manager');
  await Server.start();
  runApp(const App());
  StatusBarUtil.transparent();
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  List<String> paths = [];
  String path = '';
  @override
  Widget build(BuildContext context) {
    bool isDark = window.platformBrightness == Brightness.dark;
    return LayoutBuilder(builder: (context, con) {
      return GetMaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: isDark ? Brightness.dark : Brightness.light,
          ),
          useMaterial3: true,
        ),
        builder: (context, child) {
          return ScreenQuery(
            uiWidth: 414,
            screenWidth: con.maxWidth,
            child: child!,
          );
        },
        home: Scaffold(
          appBar: AppBar(
            title: const Text('App'),
          ),
          body: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  paths = await FileManager.selectFile();
                  setState(() {});
                  Log.i(paths);
                },
                child: const Text('选择文件'),
              ),
              ElevatedButton(
                onPressed: () async {
                  path = await FileManager.selectDirectory();
                  setState(() {});
                  Log.i(paths);
                },
                child: const Text('选择文件夹'),
              ),
              Text(paths.join('\n')),
              Text(path),
            ],
          ),
        ),
      );
    });
  }
}
