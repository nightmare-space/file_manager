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
  // TODO(lin) 支持 windows 的盘符
  static Future<int> start() async {
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
    print('File Serer start with ${server.address.address}:${server.port}');
    return port;
  }

  static Response handleRename(Request request) {
    Log.i(request.requestedUri.queryParameters);
    String path = request.requestedUri.queryParameters['path']!;
    String name = request.requestedUri.queryParameters['name']!;
    File(path).renameSync(dirname(path) + '/' + name);
    corsHeader[HttpHeaders.contentTypeHeader] = ContentType.text.toString();
    return Response.ok(
      "success",
      headers: corsHeader,
    );
  }

  static Response handleDelete(Request request) {
    Log.i(request.requestedUri.queryParameters);
    String path = request.requestedUri.queryParameters['path']!;
    File(path).deleteSync();
    corsHeader[HttpHeaders.contentTypeHeader] = ContentType.text.toString();
    return Response.ok(
      "success",
      headers: corsHeader,
    );
  }

  static Future<Response> handleDir(Request request) async {
    Log.i(request.requestedUri.queryParameters);
    String path = request.requestedUri.queryParameters['path']!;
    corsHeader[HttpHeaders.contentTypeHeader] = ContentType.json.toString();
    List dirInfos = await getDirInfos(path);
    return Response.ok(
      jsonEncode(dirInfos),
      headers: corsHeader,
    );
  }

  // 启动文件管理器服务端
  static Router getFileServerHandler() {
    var handler = createStaticHandler(
      GetPlatform.isMacOS ? '/' : '/',
      listDirectories: true,
    );
    // app.get('/rename', handleRename);
    // app.get('/delete', handleDelete);
    // app.get('/dir', handleDir);
    app.get('/file', (Request request) async {
      Log.i('file -> ${request.requestedUri.queryParameters}');
      String action = request.requestedUri.queryParameters['action']!;
      switch (action) {
        case 'get_home_path':
          Log.i('get_home_path');
          final map = {};
          Log.i('map -> $map');
          map['path'] = '';
          if (GetPlatform.isMacOS) {
            map['path'] = Platform.environment['HOME'];
          }
          Log.e('map -> $map');
          corsHeader[HttpHeaders.contentTypeHeader] = ContentType.json.toString();
          return Response.ok(jsonEncode(map), headers: corsHeader);
        case 'rename':
          return handleRename(request);
        case 'delete':
          return handleDelete(request);
        case 'dir':
          return handleDir(request);
        case 'file':
          String path = request.requestedUri.queryParameters['path']!;
          // Log.i(request.requestedUri);
          // Log.i(request.requestedUri.replace(path: path, queryParameters: {}));
          Uri newUri = Uri.parse('${request.requestedUri.scheme}://${request.requestedUri.host}:${request.requestedUri.port}$path');
          Log.i(newUri);
          Request newRequest = Request('GET', newUri);
          return handler(newRequest);
        default:
          return Response.ok(
            'success',
            headers: corsHeader,
          );
      }
    });
    // app.get('/token', (Request request) async {
    //   Log.i(request.requestedUri.queryParameters);
    //   return Response.ok(
    //     'success',
    //     headers: corsHeader,
    //   );
    // });
    // // ignore: unused_local_variable
    // app.post('/file_upload', (Request request) async {
    //   // return Response.ok(
    //   //   "success",
    //   //   headers: corsHeader,
    //   // );
    //   Log.w(request.headers);
    //   String? fileName = request.headers['filename'];
    //   String? path = request.headers['path'];
    //   if (fileName != null && path != null) {
    //     // fileName = utf8.decode(base64Decode(fileName));
    //     RandomAccessFile randomAccessFile = await File('$path/$fileName').open(
    //       mode: FileMode.write,
    //     );
    //     int? fullLength = int.tryParse(request.headers['content-length']!);
    //     Log.d('fullLength -> $fullLength');
    //     Completer<bool> lock = Completer();
    //     // 已经下载的字节长度
    //     int count = 0;
    //     request.read().listen(
    //       (event) async {
    //         count += event.length;
    //         // Log.d(event);
    //         // dateBytes.addAll(event);
    //         // progressCall?.call(
    //         //   dateBytes.length / request.headers.contentLength,
    //         //   dateBytes.length,
    //         // );
    //         randomAccessFile.writeFromSync(event);
    //         double progress = count / fullLength!;
    //         if (progress == 1.0) {
    //           lock.complete(true);
    //         }
    //       },
    //       onDone: () {},
    //     );
    //     await lock.future;
    //     randomAccessFile.close();
    //     Log.v('success');
    //   }
    //   return Response.ok(
    //     "success",
    //     headers: corsHeader,
    //   );
    // });

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

Future<List> getDirInfos(String path) async {
  Directory directory = Directory(path);
  List infos = [];
  await for (FileSystemEntity entity in directory.list()) {
    List<dynamic> info = [];
    // print('entity -> $entity');
    String entityPath = entity.path;
    FileStat fileStat = await FileStat.stat(entity.path);
    String modeString = fileStat.modeString();
    DateTime time = fileStat.modified;
    int size = fileStat.size;
    // Log.i('File mode: $modeString');
    // Log.i('File mode: $size');
    // Log.i('Accessed at: ${time.fmTime()}');
    info.add(entityPath);
    info.add(modeString);
    info.add(size);
    info.add(time.fmTime());
    info.add(fileStat.type.toString());
    infos.add(info);
  }
  return infos;
}
