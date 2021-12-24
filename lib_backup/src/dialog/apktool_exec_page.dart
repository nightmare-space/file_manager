import 'dart:io';
import 'package:file_manager/src/config/config.dart';
import 'package:file_manager/src/io/src/file.dart';
import 'package:file_manager/src/utils/client2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

import '../io/src/file.dart';

class ApktoolExecPage extends StatefulWidget {
  const ApktoolExecPage({
    Key key,
    this.fileNode,
    this.cmd,
  }) : super(key: key);
  final AbstractNiFile fileNode;
  final String cmd;

  @override
  _ApktoolExecPageState createState() => _ApktoolExecPageState();
}

class _ApktoolExecPageState extends State<ApktoolExecPage> {
  final ScrollController _scrollController = ScrollController();
  String output = '';
  bool completed = false;
  @override
  void initState() {
    super.initState();
    exec();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ApktoolExecPage oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _onAfterRendering(Duration timeStamp) async {
    // print(maxScrollExtent);
    // print(_scrollController.position.viewportDimension +
    //     _scrollController.position.maxScrollExtent);
    // print(_scrollController.position.viewportDimension + maxScrollExtent * 2);
    // print('刷新了');
    // print(_scrollController.position.viewportDimension +
    //     _scrollController.position.maxScrollExtent);
    // height = _scrollController.position.viewportDimension +
    //     _scrollController.position.maxScrollExtent;
    // dialogeventBus.fire(Height(_scrollController.position.viewportDimension +

    //     _scrollController.position.maxScrollExtent));
    // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }
  void expandView() {
    Future.delayed(const Duration(milliseconds: 100), () {
      dialogeventBus.fire(
        Height(
          _scrollController.position.viewportDimension +
              _scrollController.position.maxScrollExtent,
        ),
      );
    });
  }

  final String lockFilePath =
      '/data/data/${Config.packageName}/files/Apktool/apktool_pipe';
  Future<void> exec() async {
    await NetworkManager.startServer((data) {
      output += data;
      setState(() {});
      expandView();
    });
    const MethodChannel _channel = MethodChannel('file_manager');
    final String result = await _channel.invokeMethod<String>(
      'logoutToSocket',
    );
    final String line = widget.cmd;
    final RegExp regExp = RegExp('apktool|baksmali|smali');
    final String argsStr = line.replaceAll(regExp, '');
    final List<String> args = argsStr.trim().split(' ');
    print(args);
    // return;

    if (line.startsWith('apktool')) {
      await _channel.invokeMethod<String>(
        'apktool',
        args,
      );
    }
    if (line.startsWith('baksmali')) {
      print('startsWith baksmali');
      await _channel.invokeMethod<String>(
        'baksmali',
        args,
      );
    }
    if (line.startsWith('smali')) {
      print('startsWith smali');
      await _channel.invokeMethod<String>(
        'smali',
        args,
      );
    }
    await Process.run('rm', ['-rf', lockFilePath]);
    // output += '完成';
    completed = true;
    setState(() {});
    expandView();
  }

  @override
  void dispose() {
    NetworkManager.stopServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.center,
            child: Text(
              '执行中',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(output.trim()),
          if (completed)
            Align(
              alignment: Alignment.centerRight,
              child: FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  '关闭',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
