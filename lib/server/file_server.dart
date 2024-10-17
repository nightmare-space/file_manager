import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_manager/config/config.dart';
import 'package:get/utils.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path/path.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';

var app = Router();
final corsHeader = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': '*',
  'Access-Control-Allow-Methods': '*',
  'Access-Control-Allow-Credentials': 'true',
};

class Server {
  static List<String> routes = [
    '/rename',
    '/delete',
    '/getdir',
    '/token',
    '/file_upload',
  ];
  // 启动文件管理器服务端
  static Future<void> start() async {
    Router fileRouter = getFileServerHandler();
    final cross = const Pipeline().addMiddleware((innerHandler) {
      return (request) async {
        final response = await innerHandler(request);
        // Log.w(request.headers);
        // Log.i(request.requestedUri);
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: corsHeader);
        }
        return response;
      };
    }).addHandler(fileRouter);
    // TODO(lin): 14000-14010 这两个端口统一管理
    int port = (await getSafePort(14000, 14010))!;
    HttpServer server = await io.serve(
      cross,
      InternetAddress.anyIPv4,
      port,
      shared: true,
    );
    Config.port = port;
    print('File Serer start with ${server.address.address}:${server.port}');
  }

  // 启动文件管理器服务端
  static Router getFileServerHandler() {
    var handler = createStaticHandler(
      GetPlatform.isMacOS ? '/Users' : '/',
      listDirectories: true,
    );
    app.get('/rename', (Request request) async {
      Log.i(request.requestedUri.queryParameters);
      String path = request.requestedUri.queryParameters['path']!;
      String name = request.requestedUri.queryParameters['name']!;
      await File(path).rename(dirname(path) + '/' + name);
      corsHeader[HttpHeaders.contentTypeHeader] = ContentType.text.toString();
      return Response.ok(
        "success",
        headers: corsHeader,
      );
    });
    app.get('/delete', (Request request) async {
      Log.i(request.requestedUri.queryParameters);
      String path = request.requestedUri.queryParameters['path']!;
      await File(path).delete();
      corsHeader[HttpHeaders.contentTypeHeader] = ContentType.text.toString();
      return Response.ok(
        "success",
        headers: corsHeader,
      );
    });
    app.get('/getdir', (Request request) async {
      Log.i(request.requestedUri.queryParameters);
      String path = request.requestedUri.queryParameters['path']!;
      corsHeader[HttpHeaders.contentTypeHeader] = ContentType.json.toString();
      List<String> full;
      if (Platform.isIOS) {
        full = await getIOSFullMessage(path);
      } else {
        full = await getFullMessage(path);
      }
      return Response.ok(
        jsonEncode(full),
        headers: corsHeader,
      );
    });
    app.get('/token', (Request request) async {
      Log.i(request.requestedUri.queryParameters);
      return Response.ok(
        'success',
        headers: corsHeader,
      );
    });
    // ignore: unused_local_variable
    app.post('/file_upload', (Request request) async {
      // return Response.ok(
      //   "success",
      //   headers: corsHeader,
      // );
      Log.w(request.headers);
      String? fileName = request.headers['filename'];
      String? path = request.headers['path'];
      if (fileName != null && path != null) {
        // fileName = utf8.decode(base64Decode(fileName));
        RandomAccessFile randomAccessFile = await File('$path/$fileName').open(
          mode: FileMode.write,
        );
        int? fullLength = int.tryParse(request.headers['content-length']!);
        Log.d('fullLength -> $fullLength');
        Completer<bool> lock = Completer();
        // 已经下载的字节长度
        int count = 0;
        request.read().listen(
          (event) async {
            count += event.length;
            // Log.d(event);
            // dateBytes.addAll(event);
            // progressCall?.call(
            //   dateBytes.length / request.headers.contentLength,
            //   dateBytes.length,
            // );
            randomAccessFile.writeFromSync(event);
            double progress = count / fullLength!;
            if (progress == 1.0) {
              lock.complete(true);
            }
          },
          onDone: () {},
        );
        await lock.future;
        randomAccessFile.close();
        Log.v('success');
      }
      return Response.ok(
        "success",
        headers: corsHeader,
      );
    });

    app.mount('/', (request) => handler(request));
    return app;
  }
}

Future<int?> getSafePort(int rangeStart, int rangeEnd) async {
  if (rangeStart == rangeEnd) {
    // 说明都失败了
    return null;
  }
  try {
    await ServerSocket.bind(
      '0.0.0.0',
      rangeStart,
      shared: true,
    );
    return rangeStart;
  } catch (e) {
    return await getSafePort(rangeStart + 1, rangeEnd);
  }
}

String _twoDigits(int n) {
  if (n >= 10) return "$n";
  return "0$n";
}

String wrapSpace(String itemNumber, String size) {
  return ('$itemNumber $size').padRight(10);
}

extension TimeExt on DateTime {
  String fmTime() {
    StringBuffer buffer = StringBuffer();
    buffer.write('$year-${_twoDigits(month)}-${_twoDigits(day)} ');
    buffer.write('${_twoDigits(hour)}:${_twoDigits(minute)}');
    return buffer.toString();
  }
}

Future<List<String>> getIOSFullMessage(String path) async {
  List<String> message = [];
  for (final FileSystemEntity fileSystemEntity in Directory(path).listSync()) {
    print('fileSystemEntity -> $fileSystemEntity');
    if (fileSystemEntity is Directory) {
      StringBuffer buffer = StringBuffer();
      FileStat stat = fileSystemEntity.statSync();
      buffer.write('d${stat.modeString()} ');
      buffer.write(wrapSpace('0', stat.size.toString()));
      buffer.write('${stat.modified.fmTime()} ');
      buffer.write('${basename(fileSystemEntity.path)}');
      message.add(buffer.toString());
      // message.add('value')
    } else {
      StringBuffer buffer = StringBuffer();
      FileStat stat = fileSystemEntity.statSync();
      buffer.write('-${stat.modeString()} ');
      // buffer.write('0 ');
      // buffer.write('${stat.size} ');
      buffer.write(wrapSpace('0', stat.size.toString()));
      buffer.write('${stat.modified.fmTime()} ');
      buffer.write('${basename(fileSystemEntity.path)}');
      message.add(buffer.toString());
    }
  }
  return message;
}

Future<List<String>> getFullMessage(String path) async {
  // --------------------------------------
  String lsPath = 'ls';
  if (Platform.isAndroid) {
    lsPath = '/system/bin/ls';
  }
  // --------------------------------------
  List<String> fullmessage = <String>[];

  path = path.replaceAll('//', '/');
  // 获得ls命令的输出
  final String lsOut = await exec(
    '$lsPath -aog "$path"\n',
  );
  lsOut.split('\n').forEach((element) {
    // Log.d(element);
  });
  // 删除第一行 -> total xxx
  fullmessage = lsOut.split('\n')..removeAt(0);
  // ------------------------------------------------------------------------
  // ------------------------- 不要动这段代码，阿弥陀佛。-------------------------
  // linkFileNode 是当前文件节点有符号链接的情况。
  String linkFileNode = '';
  for (int i = 0; i < fullmessage.length; i++) {
    if (fullmessage[i].startsWith('l')) {
      //说明这个节点是符号链接
      if (fullmessage[i].split(' -> ').last.startsWith('/')) {
        //首先以 -> 符号分割开，last拿到的是该节点链接到的那个元素
        //如果这个元素不是以/开始，则该符号链接使用的是相对链接
        linkFileNode += fullmessage[i].split(' -> ').last + '\n';
      } else {
        linkFileNode += '$path/${fullmessage[i].split(' -> ').last}\n';
      }
    }
  }
  linkFileNode.split('\n').forEach((element) {});

  //
  if (linkFileNode.isNotEmpty) {
    // 当当前文件夹存在包含符号链接的节点时
    //-g取消打印owner  -0取消打印group   -L不跟随符号链接，会指向整个符号链接最后指向的那个
    final String lsOut = await exec(
      'echo "$linkFileNode"|xargs $lsPath -ALdog\n',
    );
    final List<String> linkFileNodes = lsOut.replaceAll('//', '/').split('\n');

    Log.i('====>$linkFileNodes');

    // 文件名到文件类型的 map
    // 例如 tmp:d
    // 类型是tag，'d'->文件夹，'l'->符号链接，'-'->普通文件
    final Map<String, String> map = <String, String>{};
    for (final String str in linkFileNodes) {
      // print(str);
      final String key = str.replaceAll(RegExp('^.*[0-9] /'), '/');
      Log.i('key->$key');
      map[key] = str.substring(0, 1);
    }
    Log.i('====>$map');

    for (int i = 0; i < fullmessage.length; i++) {
      final String linkFromFile = fullmessage[i].split(' -> ').last;

      Log.i('linkFromFile====>$linkFromFile');

      Log.i('map.keys->${map.keys}');
      Log.i('map.keys->${map.keys.contains(linkFromFile)}');
      if (map.keys.contains(linkFromFile)) {
        fullmessage[i] = fullmessage[i].replaceAll(RegExp('^l'), map[fullmessage[i].split(' -> ').last]!);
        // f.remove(f.first);r
      }
    }
  }
  return fullmessage;
  // ------------------------------------------------------------------------
  // ------------------------------------------------------------------------
}

Future<String> execCmd(
  String cmd, {
  bool throwException = true,
}) async {
  final List<String> args = cmd.split(' ');
  ProcessResult execResult;
  if (Platform.isWindows) {
    execResult = await Process.run(
      RuntimeEnvir.binPath! + Platform.pathSeparator + args[0],
      args.sublist(1),
      environment: RuntimeEnvir.envir(),
      includeParentEnvironment: true,
      runInShell: false,
    );
  } else {
    execResult = await Process.run(
      args[0],
      args.sublist(1),
      environment: RuntimeEnvir.envir(),
      includeParentEnvironment: true,
      runInShell: false,
    );
  }
  if ('${execResult.stderr}'.isNotEmpty) {
    if (throwException) {
      Log.w('adb stderr -> ${execResult.stderr}');
      throw Exception(execResult.stderr);
    }
  }
  // Log.e('adb stdout -> ${execResult.stdout}');
  return execResult.stdout.toString().trim();
}
