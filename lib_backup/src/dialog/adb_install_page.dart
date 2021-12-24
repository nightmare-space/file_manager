import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_manager/src/config/config.dart';
import 'package:file_manager/src/page/widget/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path/path.dart' as p;

class AdbInstallPage extends StatefulWidget {
  @override
  _AdbInstallPageState createState() => _AdbInstallPageState();
}

class _AdbInstallPageState extends State<AdbInstallPage> {
  @override
  void initState() {
    super.initState();
    // init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          '未找到Adb',
          style: TextStyle(
            height: 1.0,
            color: Theme.of(context).textTheme.bodyText2.color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          _DownloadFile(),
        ],
      ),
    );
  }
}

class _DownloadFile extends StatefulWidget {
  const _DownloadFile({Key key, this.callback}) : super(key: key);
  final void Function() callback;
  @override
  _DownloadFileState createState() => _DownloadFileState();
}

class _DownloadFileState extends State<_DownloadFile> {
  final Dio dio = Dio();
  Response<String> response;
  final String filesPath = Config.dataPath;
  List<String> androidAdbFiles = [
    'http://nightmare.fun/File/MToolkit/android/aapt',
  ];
  List<String> macAdbFiles = [
    'https://nightmare.fun/File/MToolkit/mac/adb.zip',
  ];
  List<String> winAdbFiles = [
    'https://nightmare.fun/File/MToolkit/windows/adb.exe',
    'https://nightmare.fun/File/MToolkit/windows/AdbWinUsbApi.dll',
    'https://nightmare.fun/File/MToolkit/windows/AdbWinApi.dll',
  ];
  double fileDownratio = 0.0;
  String downloadName = '';
  Future<void> downloadFile(String urlPath) async {
    print(urlPath);
    response = await dio.head<String>(urlPath);
    final int fullByte = int.tryParse(
      response.headers.value('content-length'),
    ); //得到服务器文件返回的字节大小
    // final String _human = getFileSize(_fullByte); //拿到可读的文件大小返回给用户
    print('fullByte======$fullByte');
    final String savePath =
        filesPath + Platform.pathSeparator + p.basename(urlPath);
    // updateBusyboxProgress(fullByte, savePath);
    await dio.download(
      urlPath,
      savePath,
      onReceiveProgress: (count, total) {
        final double process = count / total;
        fileDownratio = process;
        setState(() {});
        // );
      },
    );
    Process.runSync('chmod', <String>[
      '0777',
      savePath,
    ]);
  }

  @override
  void initState() {
    super.initState();
    execDownload();
  }

  Future<void> execDownload() async {
    List<String> needDownloadFile;
    if (Platform.isWindows) {
      needDownloadFile = winAdbFiles;
    } else if (Platform.isMacOS) {
      needDownloadFile = macAdbFiles;
    }
    if (Platform.isAndroid) {
      needDownloadFile = androidAdbFiles;
    }
    for (final String urlPath in needDownloadFile) {
      downloadName = p.basename(urlPath);
      setState(() {});
      await downloadFile(urlPath);
    }
    Navigator.of(context).pop();
    widget.callback?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        8,
      ),
      child: NiCard(
        child: Padding(
          padding: EdgeInsets.all(
            12,
          ),
          child: Column(
            children: [
              Text(
                '下载 $downloadName 中',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '进度',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                child: LinearProgressIndicator(
                  value: fileDownratio,
                ),
              ),
              SizedBox(
                child: Text(
                  '下载到的目录为 $filesPath',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
