import 'package:flutter/services.dart';

class ApktoolUtils {
  static const MethodChannel _channel = MethodChannel('file_manager');
  // void decodeApk({String apkPath, List<String> args}) {
  //   const MethodChannel _channel = MethodChannel('file_manager');
  //   _channel.invokeMethod<void>('apktool', args);
  // }

  // void encodeApk({String apkPath, List<String> args}) {
  //   const MethodChannel _channel = MethodChannel('file_manager');
  //   _channel.invokeMethod<void>('apktool', args);
  // }
  void execCmd({List<String> args}) {
    _channel.invokeMethod<void>('apktool', args);
  }
}
