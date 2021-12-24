import 'dart:io';

import 'package:file_manager/src/config/config.dart';
import 'package:file_manager/src/io/src/file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

import '../io/src/file.dart';
import '../io/src/file.dart';
import 'apktool_exec_page.dart';

class ApkToolDialog extends StatefulWidget {
  const ApkToolDialog({Key key, @required this.fileNode}) : super(key: key);
  final AbstractNiFile fileNode;

  @override
  _ApkToolDialogState createState() => _ApkToolDialogState(fileNode);
}

class _ApkToolDialogState extends State<ApkToolDialog> {
  _ApkToolDialogState(this._fileNode);
  final AbstractNiFile _fileNode;

  Widget apkToolItem(String title, void Function() onTap) {
    return Material(
      color: Colors.white,
      child: Ink(
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 46,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xff000000),
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget child;
  @override
  Widget build(BuildContext context) {
    child ??= FullHeightListView(
      child: Column(
        children: <Widget>[
          Text(_fileNode.nodeName),
          apkToolItem(
            '反编译全部',
            () {
              final String _name = widget.fileNode.path.replaceAll(
                RegExp('.*/|\\..*'),
                '',
              );
              DialogBuilder.changeHeight(0);
              child = ApktoolExecPage(
                fileNode: widget.fileNode,
                cmd:
                    'apktool d ${widget.fileNode.path} -f -o ${FileSystemEntity.parentOf(widget.fileNode.path)}/$_name\_src '
                    '-p ${Config.filesPath}/Apktool/Framework',
              );
              setState(() {});
              // Navigator.pop(context);
              // showCustomDialog<void>(
              //   height: 600.0,
              //   child: Niterm(
              //     showOnDialog: true,
              //     script: 'apktool  d ${widget.fileNode.path} '
              //         "-f -o ${FileSystemEntity.parentOf(widget.fileNode.path)}/${widget.fileNode.nodeName.replaceAll(".apk", "")}_src "
              //         '-p /data/data/com.nightmare/files/Apktool/Framework/',
              //   ),
              // );
            },
          ),
          apkToolItem('反编译dex', () {
            final String _name = widget.fileNode.path.replaceAll(
              RegExp('.*/|\\..*'),
              '',
            );
            DialogBuilder.changeHeight(0);
            child = ApktoolExecPage(
              fileNode: widget.fileNode,
              cmd:
                  'apktool d ${widget.fileNode.path} -f -r -o ${FileSystemEntity.parentOf(widget.fileNode.path)}/$_name\_src '
                  '-p ${Config.filesPath}/Apktool/Framework',
            );
            setState(() {});
            // Navigator.pop(context);
            // showCustomDialog<void>(
            //   isPadding: false,
            //   height: 600.0,
            //   child: Niterm(
            //     showOnDialog: true,
            //     script: 'apktool  d ${widget.fileNode.path} '
            //         "-f -r -o ${FileSystemEntity.parentOf(widget.fileNode.path)}/${widget.fileNode.nodeName.replaceAll(".apk", "")}_src "
            //         '-p /data/data/com.nightmare/files/Apktool/Framework/',
            //   ),
            // );
          }),
          apkToolItem('反编译res', () {
            final String _name = widget.fileNode.path.replaceAll(
              RegExp('.*/|\\..*'),
              '',
            );
            DialogBuilder.changeHeight(0);
            child = ApktoolExecPage(
              fileNode: widget.fileNode,
              cmd:
                  'apktool d ${widget.fileNode.path} -f -s -o ${FileSystemEntity.parentOf(widget.fileNode.path)}/$_name\_src '
                  '-p ${Config.filesPath}/Apktool/Framework',
            );
            setState(() {});
            // Navigator.pop(context);
            // showCustomDialog2<void>(
            //   isPadding: false,
            //   height: 600.0,
            //   child: Niterm(
            //     showOnDialog: true,
            //     script: 'apktool  d ${widget.fileNode.path} '
            //         "-f -s -o ${FileSystemEntity.parentOf(widget.fileNode.path)}/${widget.fileNode.nodeName.replaceAll(".apk", "")}_src "
            //         '-p /data/data/com.nightmare/files/Apktool/Framework/',
            //   ),
            // );
          }),
          apkToolItem('签名', () {}),
          apkToolItem('Zipalign', () {}),
          apkToolItem('解压出META-INF', () {
            DialogBuilder.changeHeight(0);
            child = ApktoolExecPage(
              fileNode: widget.fileNode,
              cmd:
                  '7z x ${widget.fileNode.path} -o${FileSystemEntity.parentOf(widget.fileNode.path)} META-INF',
            );
            setState(() {});
          }),
          apkToolItem('添加META-INF', () {
            DialogBuilder.changeHeight(0);
            child = ApktoolExecPage(
              fileNode: widget.fileNode,
              cmd:
                  '7z a ${widget.fileNode.path} ${FileSystemEntity.parentOf(widget.fileNode.path)}/META-INF',
            );
            setState(() {});
          }),
          apkToolItem('删除dex', () {}),
          apkToolItem('删除META-INF', () {
            DialogBuilder.changeHeight(0);
            child = ApktoolExecPage(
              fileNode: widget.fileNode,
              cmd: '7z d ${widget.fileNode.path} META-INF',
            );
            setState(() {});
          }),
          apkToolItem('导入框架', () {
            DialogBuilder.changeHeight(0);
            child = ApktoolExecPage(
              fileNode: widget.fileNode,
              cmd: 'apktool if ${widget.fileNode.path} '
                  '-p ${Config.frameworkPath}',
            );
            setState(() {});
          }),
        ],
      ),
    );
    return child;
  }
}
