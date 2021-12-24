import 'dart:io';

import 'package:file_manager/src/config/config.dart';
import 'package:file_manager/src/config/global.dart';
import 'package:file_manager/src/io/src/file_entity.dart';
import 'package:file_manager/src/page/file_manager_controller.dart';
import 'package:file_manager/src/provider/file_manager_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:global_repository/global_repository.dart';
import 'package:provider/provider.dart';

import '../colors/file_colors.dart';

class LongPressDialog extends StatefulWidget {
  const LongPressDialog({
    Key key,
    this.fileNode,
    @required this.controller,
  }) : super(key: key);

  final FileManagerController controller;
  final FileEntity fileNode;

  @override
  _LongPressDialogState createState() => _LongPressDialogState();
}

class _LongPressDialogState extends State<LongPressDialog> {
  PageController _pageController;
  Widget dialog;
  String widgetKey = 'defaultWidget';
  String md5 = '';
  String sha1 = '';
  String crc32 = '';
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0)
      ..addListener(() {
        if (_pageController.page > 0.5) {
          DialogBuilder.changeHeight(80);
        }
        if (_pageController.page < 0.5) {
          DialogBuilder.changeHeight(440);
        }
      });
    getMoreDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getMoreDetails() async {
    final String a = await NiProcess.exec(
      "${PlatformUtil.getLsPath()} -ld '${widget.fileNode.path}'\n",
    );
    final List<String> infos = a.split(RegExp(r'\s{1,}'));
    widget.fileNode.uid = infos[2];
    widget.fileNode.gid = infos[3];
    if (mounted) {
      setState(() {});
    }
    md5 = await NiProcess.exec("md5sum '${widget.fileNode.path}'\n");
    md5 = md5.replaceAll(RegExp(' .*'), '');
    if (mounted) {
      setState(() {});
    }
    sha1 = await NiProcess.exec("sha1sum '${widget.fileNode.path}'\n");
    sha1 = sha1.replaceAll(RegExp(' .*'), '');
    if (mounted) {
      setState(() {});
    }
  }

  Widget detailsItem(String name, String details) {
    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: details));
        Feedback.forTap(context);
        showToast('已复制$name');
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              Text('$name:$details'),
              if (details == '')
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Text('获取中'),
                      SpinKitThreeBounce(
                        color: FileColors.fileAppColor,
                        size: 16.0,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget fileDetails() {
    // widget.fileNode.
    return FullHeightListView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Center(
            child: Text('详细属性'),
          ),
          detailsItem('名称', widget.fileNode.nodeName),
          detailsItem('节点类型', widget.fileNode.isFile ? '文件' : '文件夹'),
          detailsItem('所在目录', FileSystemEntity.parentOf(widget.fileNode.path)),
          detailsItem('修改时间', widget.fileNode.modified),
          detailsItem('权限', widget.fileNode.mode),
          detailsItem('所有者', widget.fileNode.uid),
          detailsItem('用户组', widget.fileNode.gid),
          if (widget.fileNode.isFile) detailsItem('MD5', md5),
          if (widget.fileNode.isFile) detailsItem('SHA1', sha1),
          Align(
            alignment: Alignment.bottomRight,
            child: FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('返回'),
            ),
          )
        ],
      ),
    );
  }

  Widget deleteWidget() {
    final Clipboards fiMaPageNotifier = Global().clipboards;
    List<FileEntity> _nodes = fiMaPageNotifier.checkNodes;
    if (_nodes.isEmpty) {
      _nodes = <FileEntity>[widget.fileNode];
    }
    return FullHeightListView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: SvgPicture.asset(
                  'packages/file_manager/assets/icon/alert.svg',
                  width: 20.0,
                  height: 20.0,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              Text(
                '删除文件${widget.fileNode.nodeName}？',
                style: const TextStyle(
                  color: Color(0xff000000),
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
          Material(
            color: Colors.white,
            child: Ink(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    child: const Text('返回'),
                    onPressed: () {
                      // dialogeventBus.fire(Height(0));
                      widgetKey = 'defaultWidget';
                      setState(() {});
                    },
                  ),
                  FlatButton(
                    child: const Text('确认'),
                    onPressed: () async {
                      for (final FileEntity node in _nodes) {
                        await NiProcess.exec('rm -rf ${node.path}\n');
                      }
                      showToast('已删除');
                      widget.controller.updateFileNodes();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget renameWidget() {
    final TextEditingController controller = TextEditingController(
      text: widget.fileNode.nodeName,
    );
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(2.0, 0.0, 0.0, 0.0),
              child: Text(
                '重命名',
                style: TextStyle(
                  color: Color(0xff000000),
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.mode_edit),
          ],
        ),
        TextField(
          autofocus: false,
          controller: controller,
          decoration: InputDecoration(
            isDense: true,
            helperText: '初始名称:${widget.fileNode.nodeName}',
            contentPadding: const EdgeInsets.only(top: 10.0),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
        ),
        Material(
          color: Colors.white,
          child: Ink(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  child: const Text(
                    '取消',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    dialogeventBus.fire(Height(440));
                    widgetKey = 'defaultWidget';
                    setState(() {});
                  },
                ),
                FlatButton(
                  child: Text(
                    '确认',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    await widget.fileNode.rename(controller.text);
                    widget.controller.updateFileNodes();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget openFileWidget() {
    return SizedBox.expand(
        child: PageView(
      controller: _pageController,
      children: <Widget>[
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ListBody(
            children: <Widget>[
              Center(
                child: Text(widget.fileNode.nodeName),
              ),
              item('文本编辑', Icons.check, () {}),
              item('图片查看', Icons.content_cut, () {}),
            ],
          ),
        ),
      ],
    ));
  }

  Widget item(String str, IconData _data, Function fun) {
    return Material(
      color: Colors.white,
      child: Ink(
        child: InkWell(
          onTap: () {
            fun();
          },
          child: SizedBox(
            height: 46,
            child: Row(
              children: <Widget>[
                Icon(_data),
                Padding(
                  padding: const EdgeInsets.fromLTRB(2.0, 0.0, 0.0, 0.0),
                  child: Text(
                    str,
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

  Widget defaultWidget() {
    final Clipboards clipboards = Global.instance.clipboards;
    List<FileEntity> _nodes = clipboards.checkNodes;
    if (_nodes.isEmpty) {
      _nodes = <FileEntity>[widget.fileNode];
    }
    return FullHeightListView(
      child: Column(
        children: <Widget>[
          // Center(
          //   child: Text(fiMaPageNotifier.checkNodes.isEmpty
          //       ? widget.fileNode.nodeName
          //       : '多个文件'),
          // ),
          item('打开方式', Icons.check, () {
            DialogBuilder.changeHeight(400.0);
            widgetKey = 'openFileWidget';
            setState(() {});
          }),
          // item('剪切', Icons.content_cut, () {
          //   for (final FileEntity node in _nodes) {
          //     fiMaPageNotifier.setClipBoard(ClipType.Cut, node.path);
          //   }
          //   Navigator.of(context).pop();
          //   // showToast2('已添加至剪切板');
          // }),
          item('复制', Icons.content_copy, () async {
            for (final FileEntity node in _nodes) {
              clipboards.addClipBoard(ClipType.Copy, node.path);
            }
            Navigator.of(context).pop();
            // showToast2('已添加至剪切板');
          }),
          item('重命名', Icons.mode_edit, () {
            DialogBuilder.changeHeight(128);
            widgetKey = 'renameWidget';
            setState(() {});
          }),
          item('删除', Icons.delete, () {
            dialogeventBus.fire(Height(64));
            widgetKey = 'deleteWidget';
            setState(() {});
          }),
          item('分享', Icons.send, () {}),
          item('链接到', Icons.link, () {}),
          item('压缩...', Icons.file_download, () {}),
          item('属性', Icons.sim_card_alert, () {
            if (widget.fileNode.isFile) {
              DialogBuilder.changeHeight(280);
            } else {
              DialogBuilder.changeHeight(232);
            }
            widgetKey = 'fileDetails';
            setState(() {});
          }),
        ],
      ),
    );
    // return SizedBox.expand(
    //     child: PageView(
    //   controller: _pageController,
    //   children: <Widget>[
    //     SingleChildScrollView(
    //       physics: BouncingScrollPhysics(),
    //       child: Column(
    //         children: <Widget>[
    //           Center(
    //             child: Text(widget.fileNode.nodeName),
    //           ),
    //           item('打开方式', Icons.check, () {
    //             dialogeventBus.fire(Height(140));
    //             widgetKey = 'openFileWidget';
    //             setState(() {});
    //           }),
    //           item('移动', Icons.content_cut, () {}),
    //           item('复制', Icons.content_copy, () async {
    //             await execShell(ToolkitInfo.isRoot,
    //                 '/system/bin/find '${widget.fileNode.path}' -type d'); //所有的文件夹数目
    //             String b = await execShell(ToolkitInfo.isRoot,
    //                 '/system/bin/find '${widget.fileNode.path}'');
    //             b.split('\n');
    //             // for()
    //             // Directory(widget.nodePath).
    //             // String b=await execShell(ToolkitInfo.isRoot,
    //             //     '/system/bin/cp '${widget.nodePath}' ${Directory(widget.nodePath).parent.path}/aaa');
    //           }),
    //           item('重命名', Icons.mode_edit, () {
    //             dialogeventBus.fire(Height(140));
    //             widgetKey = 'renameWidget';
    //             setState(() {});
    //           }),
    //           item('删除', Icons.delete, () {
    //             dialogeventBus.fire(Height(86));
    //             widgetKey = 'deleteWidget';
    //             setState(() {});
    //           }),
    //           item('分享', Icons.send, () {}),
    //           item('链接到', Icons.link, () {}),
    //           item('压缩...', Icons.file_download, () {}),
    //           item('属性', Icons.sim_card_alert, () {}),
    //         ],
    //       ),
    //     ),
    //     [
    //       SingleChildScrollView(
    //         physics: NeverScrollableScrollPhysics(),
    //         child: ListBody(
    //           children: <Widget>[
    //             Center(
    //               child: Text(widget.fileNode.nodeName),
    //             ),
    //             item('回编译dex', Icons.adb, () async {
    //               Navigator.of(context).pop();
    //               String name =
    //                   widget.fileNode.nodeName.replaceAll('_dex', '_new');
    //               PlatformChannel.Toast.invokeMethod<void>('回编译中');
    //               List args = [
    //                 'a',
    //                 // '${widget.nodePath}',
    //                 // '-o',
    //                 // '${widget.parentpath}/$name.dex'
    //               ];
    //               await PlatformChannel.Decompile.invokeMethod<void>('smali', args);
    //               PlatformChannel.Toast.invokeMethod<void>('编译结束');
    //               widget.callback();
    //             }),
    //           ],
    //         ),
    //       ),
    //       SingleChildScrollView(
    //         physics: NeverScrollableScrollPhysics(),
    //         child: ListBody(
    //           children: <Widget>[
    //             Center(
    //               child: Text(widget.fileNode.nodeName),
    //             ),
    //             item('回编译apk', Icons.adb, () async {
    //               Navigator.of(context).pop();
    //               String name =
    //                   widget.fileNode.nodeName.replaceAll('_src', '_new');
    //               String logpath =
    //                   '/data/data/com.nightmare/nodePaths/Apktool/apktool';
    //               for (int i = 0; File('$logpath').existsSync(); i++) {
    //                 logpath = '$logpath$i';
    //               }
    //               await PlatformChannel.Decompile.invokeMethod<void>(
    //                   'logout', logpath);
    //               File(logpath).writeAsStringSync('');
    //               showCustomDialog(
    //                   context,
    //                   const Duration(milliseconds: 400),
    //                   80,
    //                   Console(
    //                     title: Text(
    //                       '执行中',
    //                       style: TextStyle(color: Colors.black, fontSize: 16),
    //                     ),
    //                     color: Colors.transparent,
    //                     autoshell:
    //                         'echo 回编译apk中...\necho Nightmare_exit_true\n',
    //                     consoleCallback: () async {
    //                       List args = [
    //                         'b',
    //                         '-f',
    //                         // '${widget.nodePath}',
    //                         // '-o',
    //                         // '${widget.parentpath}/$name.apk',
    //                         '-p',
    //                         '/data/data/com.nightmare/nodePaths/Apktool/Framework',
    //                       ];
    //                       PlatformChannel.Decompile.invokeMethod<void>(
    //                               'apktool', args)
    //                           .whenComplete(() {
    //                         File(logpath).deleteSync();
    //                       });
    //                       String oldtxt = '';
    //                       String fulloutput = '';
    //                       Future<void>.delayed(Duration(milliseconds: 100), () async {
    //                         while (File(logpath).existsSync()) {
    //                           String _output =
    //                               await File(logpath).readAsString();
    //                           if (_output != oldtxt) {
    //                             fulloutput =
    //                                 fulloutput + _output.replaceAll(oldtxt, '');
    //                             mConsole.stdin.writeln(
    //                                 'echo \'${_output.replaceAll(oldtxt, '')}\'');
    //                           }
    //                           await Future<void>.delayed(Duration(microseconds: 100));
    //                           oldtxt = _output;
    //                         }
    //                         mConsole.stdin.writeln('echo \'执行结束。\'');
    //                         widget.callback();
    //                         //   if (GlobalObjectKey(logpath).currentContext == null)
    //                         //     showCustomDialog(
    //                         //         widget.context,
    //                         //         const Duration(milliseconds: 400),
    //                         //         80,
    //                         //         Console(
    //                         //           title: Text(
    //                         //             '执行结束',
    //                         //             style: TextStyle(
    //                         //                 color: Colors.black, fontSize: 16),
    //                         //           ),
    //                         //           color: Colors.transparent,
    //                         //           autoshell:
    //                         //               'echo \'$fulloutput\'\necho Nightmare_exit_true\n',
    //                         //           consoleCallback: () async {},
    //                         //         ),
    //                         //         false,
    //                         //         false);
    //                       });
    //                     },
    //                   ),
    //                   false,
    //                   false,
    //                   logpath);
    //             }),
    //           ],
    //         ),
    //       ),
    //     ][widget.initpage1]
    // ],
    // ));
  }

  Map<String, Widget> childMap = <String, Widget>{};

  @override
  Widget build(BuildContext context) {
    childMap = <String, Widget>{
      'deleteWidget': deleteWidget(),
      'renameWidget': renameWidget(),
      'openFileWidget': openFileWidget(),
      'defaultWidget': defaultWidget(),
      'fileDetails': fileDetails(),
    };
    return Theme(
      data: ThemeData(
        fontFamily: Platform.isLinux ? 'SourceHanSansSC-Light' : null,
      ),
      child: childMap[widgetKey],
    );
  }
}
