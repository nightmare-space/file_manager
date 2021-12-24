import 'dart:io';
import 'dart:ui';

import 'package:file_manager/src/config/config.dart';
import 'package:file_manager/src/io/src/directory.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

import '../io/src/directory.dart';
import 'adb_install_page.dart';
import 'apktool_exec_page.dart';

class ApktoolEncodeDialog extends StatefulWidget {
  const ApktoolEncodeDialog({Key key, this.directory}) : super(key: key);
  final AbstractDirectory directory;

  @override
  _ApktoolEncodeDialogState createState() => _ApktoolEncodeDialogState();
}

class _ApktoolEncodeDialogState extends State<ApktoolEncodeDialog> {
  Widget child;
  @override
  Widget build(BuildContext context) {
    child ??= FullHeightListView(
      child: InkWell(
        onTap: () async {
          if (!Directory(Config.aaptPath).existsSync()) {
            await Navigator.push(context,
                MaterialPageRoute<AdbInstallPage>(builder: (_) {
              return AdbInstallPage();
            }));
          }
          final String prifex = widget.directory.nodeName.replaceAll(
            '_src',
            '',
          );
          // return;
          DialogBuilder.changeHeight(0);
          child = ApktoolExecPage(
            cmd: 'apktool build -f ${widget.directory.path} -o '
                '${widget.directory.parent.path}/$prifex\_new.apk '
                '-p ${Config.frameworkPath} '
                '-a ${Config.aaptPath}',
          );
          setState(() {});
        },
        child: const SizedBox(
          height: 32,
          child: Center(
            child: Text(
              '回编译',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
    return child;
  }
}
