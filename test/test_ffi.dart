import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';

typedef GetLogicalDrivesC = Uint32 Function();
typedef GetLogicalDrivesDart = int Function();

void main() {
  final DynamicLibrary kernel32 = DynamicLibrary.open('kernel32.dll');
  final GetLogicalDrivesDart getLogicalDrives = kernel32.lookup<NativeFunction<GetLogicalDrivesC>>('GetLogicalDrives').asFunction();

  int drivesBitMask = getLogicalDrives();
  List<String> drives = [];

  for (int i = 0; i < 26; i++) {
    if ((drivesBitMask & (1 << i)) != 0) {
      drives.add(String.fromCharCode(65 + i) + ':\\');
    }
  }

  print('当前系统中的盘符有:');
  for (var drive in drives) {
    print(drive);
  }
}
