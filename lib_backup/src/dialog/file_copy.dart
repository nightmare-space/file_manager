// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:flutter_toolkit/modules/file_manager/provider/file_manager_notifier.dart';
// import 'package:flutter_toolkit/utils/global_function.dart';
// import 'package:flutter_toolkit/utils/global_repository.dart';
// import 'package:provider/provider.dart';

// class Copy extends StatefulWidget {
//   const Copy({Key key, this.targetPath, this.sourcePaths}) : super(key: key);
//   final String targetPath;
//   final List<String> sourcePaths;
//   @override
//   _CopyState createState() => _CopyState();
// }

// class _CopyState extends State<Copy> {
//   String curCpFile = ''; //当前复制的文件为
//   String text = '';
//   int fullByte = 0;
//   int alreadyCpByte = 0;
//   int sum;
//   double curProgress = 0.0;
//   int cpFilePreByte = 0;
//   bool isComplete = false;
//   List<String> queue = <String>[];
//   List<String> sourcePaths = <String>[];
//   String tmp1 = '';
//   String tmp2 = '';
//   String speed = '';
//   @override
//   void initState() {
//     super.initState();
//     initCopy();
//     // getCurrentProgess();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
//   }

//   @override
//   void didUpdateWidget(Copy oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
//   }

//   void _onAfterRendering(Duration timeStamp) {
//     // if (mounted) setState(() {});
//   }

//   Future<void> getCurrentProgess() async {
//     while (sourcePaths.isEmpty) {
//       await Future<void>.delayed(const Duration(milliseconds: 100));
//     }
//     while (sourcePaths.isNotEmpty && mounted) {
//       curCpFile = sourcePaths.first;
//       final String targetPath =
//           '${widget.targetPath}${sourcePaths.first.replaceAll(FileSystemEntity.parentOf(widget.sourcePaths[0]), '')}';
//       while (true) {
//         if (await Directory(targetPath).exists() ||
//             await File(targetPath).exists()) {
//           break;
//         }
//         await Future<void>.delayed(const Duration(microseconds: 0));
//       }
//       if (await Directory(targetPath).exists()) {
//         curProgress = 1.0;
//         speed = '';
//         cpFilePreByte = 0;
//         alreadyCpByte += 4096;
//         if (mounted) {
//           setState(() {});
//         }
//       } else if (await File(targetPath).exists() &&
//           await File(sourcePaths[0]).length() ==
//               await File(targetPath).length()) {
//         curProgress = 1.0;
//         speed = '';
//         cpFilePreByte = 0;
//         alreadyCpByte += await File(targetPath).length();
//         if (mounted) {
//           setState(() {});
//         }
//       } else if (await File(targetPath).exists()) {
//         curProgress = await File(targetPath).length() /
//             await File(sourcePaths[0]).length();
//         setState(() {});
//         DateTime dateTime = DateTime.now();
//         while (true) {
//           if (DateTime.now().difference(dateTime).inMilliseconds >= 200) {
//             dateTime = DateTime.now();
//             final int size = await File(targetPath).length() - cpFilePreByte;
//             alreadyCpByte += size;
//             speed = '${getFileSize(size * 5)}/s';
//             cpFilePreByte = await File(targetPath).length();
//           }
//           curProgress = await File(targetPath).length() /
//               await File(sourcePaths[0]).length();
//           if (mounted) {
//             setState(() {});
//           }
//           if (curProgress == 1.0) {
//             break;
//           }
//           const Duration duration = Duration(milliseconds: 1);
//           await Future<void>.delayed(duration);
//         }
//         // completeNumber++;
//       }
//       while (true) {
//         if (curCpFile != sourcePaths.first) {
//           break;
//         }
//         await Future<void>.delayed(const Duration(microseconds: 0));
//       }
//     }

//     if (sourcePaths.isEmpty) {
//       // showToast2('完成');
//       // await Future<void>.delayed(const Duration(milliseconds: 300));
//       // Navigator.of(globalContext).pop();
//     }
//   }

//   Future<void> initCopy() async {
//     // DateTime a = DateTime.now();
//     String allPaths = '';
//     for (final String path in widget.sourcePaths) {
//       allPaths += await NiProcess.exec('find $path -not -type l \n');
//       allPaths += '\n';
//       final String daxiao = await NiProcess.exec(
//           "find $path -not -type l |xargs busybox stat -c \'%s\'|awk '{sum1+= \$1}END{print sum1}'\n");
//       // print(daxiao);
//       fullByte += int.tryParse(daxiao.trim());
//       // print(int.tryParse(daxiao.replaceAll(RegExp('t.*'), '').trim()) * 1024);
//     }
//     fullByte = fullByte;
//     setState(() {});
//     // print('耗时=====>${DateTime.now().difference(a)}');
//     sourcePaths = allPaths.trim().split('\n');

//     // print('耗时=====>${DateTime.now().difference(a)}');
//     // for (int i = 0; i < sourcePaths.length; i++) {
//     //   sourcePaths[i] = sourcePaths[i]
//     //       .replaceFirst(FileSystemEntity.parentOf(sourcePaths[i]), '');
//     // }
//     // print('allPaths=====>$sourcePaths');
//     // print('allPaths=====>${sourcePaths.length}');
//     // print(widget.targetPath);
//     sum = sourcePaths.length;
//     setState(() {});
//     // print('cp -Lrv ${widget.sourcePath} ${widget.targetPath}\n');
//     bool isStart = false;
//     String tmp = '';
//     final RegExp lineRegExp = RegExp(".*' -> '.*'");
//     // Niterm.getOutPut((String output) async {
//     //   if (!mounted) {
//     //     return true;
//     //   }
//     //   output = tmp + output;
//     //   tmp = '';
//     //   // tmp2+=output;
//     //   // File('/sdcard/MToolkit/日志文件夹/文件复制.txt').writeAsString(tmp2);
//     //   // output=tmp+output;
//     //   // print('来自term的输出===>$output');
//     //   if (output.contains('\n')) {
//     //     for (final String pathLine in output.split('\n')) {
//     //       if (pathLine.startsWith("'")) {
//     //         isStart = true;
//     //       }
//     //       if (isStart) {
//     //         if (lineRegExp.hasMatch(pathLine)) {
//     //           // curProgress = 0.0;
//     //           if (sourcePaths.isNotEmpty) {
//     //             sourcePaths.removeAt(0);
//     //           }
//     //           setState(() {});
//     //           if (sourcePaths.isEmpty) {
//     //             fiMaPageNotifier.clearClipBoard();
//     //             Future<void>.delayed(const Duration(milliseconds: 200), () {
//     //               Navigator.of(context).pop();
//     //             });
//     //             break;
//     //           }
//     //           final String targetPath =
//     //               '${widget.targetPath}${sourcePaths.first.replaceAll(FileSystemEntity.parentOf(widget.sourcePaths[0]), '')}';
//     //           while (true) {
//     //             if (await Directory(targetPath).exists() ||
//     //                 await File(targetPath).exists()) {
//     //               break;
//     //             }
//     //             await Future<void>.delayed(const Duration(microseconds: 0));
//     //           }
//     //           if (await Directory(targetPath).exists()) {
//     //             curProgress = 1.0;
//     //             speed = '';
//     //             cpFilePreByte = 0;
//     //             alreadyCpByte += 4096;
//     //             if (mounted) {
//     //               setState(() {});
//     //             }
//     //           } else if (await File(targetPath).exists() &&
//     //               await File(sourcePaths[0]).length() ==
//     //                   await File(targetPath).length()) {
//     //             curProgress = 1.0;
//     //             speed = '';
//     //             cpFilePreByte = 0;
//     //             alreadyCpByte += await File(targetPath).length();
//     //             if (mounted) {
//     //               setState(() {});
//     //             }
//     //           } else if (await File(targetPath).exists()) {
//     //             curProgress = await File(targetPath).length() /
//     //                 await File(sourcePaths[0]).length();
//     //             setState(() {});
//     //             DateTime dateTime = DateTime.now();
//     //             while (true) {
//     //               if (DateTime.now().difference(dateTime).inMilliseconds >=
//     //                   200) {
//     //                 dateTime = DateTime.now();
//     //                 final int size = await File(targetPath).length() - cpFilePreByte;
//     //                 alreadyCpByte += size;
//     //                 speed = '${getFileSize(size * 5)}/s';
//     //                 cpFilePreByte = await File(targetPath).length();
//     //               }
//     //               curProgress = await File(targetPath).length() /
//     //                   await File(sourcePaths[0]).length();
//     //               if (curProgress == 1.0) {
//     //                 final int size = await File(targetPath).length() - cpFilePreByte;
//     //                 alreadyCpByte += size;
//     //                 break;
//     //               }
//     //               if (mounted) {
//     //                 setState(() {});
//     //               }
//     //               await Future<void>.delayed(const Duration(milliseconds: 1));
//     //             }
//     //             // completeNumber++;
//     //           }
//     //         } else
//     //           tmp = pathLine;
//     //       }
//     //       // List pathLineList =
//     //       //     pathLine.trim().replaceAll(RegExp('^cp ''), '').split(' -> ');
//     //       // String sourcePath = pathLineList[0].replaceAll(RegExp('^'|'\$'), '');
//     //       // String targetPath = pathLineList[1].replaceAll(RegExp('^'|'\$'), '');

//     //     }
//     //   } else
//     //     tmp = output;
//     //   return false;
//     // });
//     String script = '';
//     for (final String path in widget.sourcePaths) {
//       script += 'cp -Lrv $path ${widget.targetPath}\n';
//     }
//     // Niterm.exec('sh -c \'$script\'\n');
//   }

// //TODO 很多Niterm部分被删了
//   @override
//   void dispose() {
//     // Niterm.exec(String.fromCharCode(3));
//     super.dispose();
//   }

//   FiMaPageNotifier fiMaPageNotifier;
//   @override
//   Widget build(BuildContext context) {
//     fiMaPageNotifier = Provider.of<FiMaPageNotifier>(context, listen: false);

//     return SizedBox(
//       height: 140.0,
//       child: ListView(
//         physics: const NeverScrollableScrollPhysics(),
//         children: <Widget>[
//           Row(
//             children: <Widget>[
//               const Text('剩余项：'),
//               if (sum == null)
//                 SpinKitThreeBounce(
//                   color: Theme.of(context).accentColor,
//                   size: 16.0,
//                 )
//               else
//                 Text('${sourcePaths.length}'),
//             ],
//           ),
//           SizedBox(
//             height: 64.0,
//             child: sourcePaths.isNotEmpty
//                 ? Text(
//                     '复制文件${sourcePaths.first}',
//                     maxLines: 4,
//                   )
//                 : const Text('复制结束'),
//           ),
//           Text('当前进度:$speed'),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10.0),
//             child: SizedBox(
//               height: 4.0,
//               child: LinearProgressIndicator(
//                 value: curProgress,
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                     Theme.of(context).accentColor),
//                 backgroundColor: Colors.grey,
//               ),
//             ),
//           ),
//           Text('总进度:(${getFileSize(alreadyCpByte)}/${getFileSize(fullByte)})'),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10.0),
//             child: SizedBox(
//               height: 4.0,
//               child: LinearProgressIndicator(
//                 value: sum == null
//                     ? 0.0
//                     : (sum - sourcePaths.length) / sum.toDouble(),
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                     Theme.of(context).accentColor),
//                 backgroundColor: Colors.grey,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
