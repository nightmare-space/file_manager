// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:global_repository/global_repository.dart';

// // Make sure to add following packages to pubspec.yaml:
// // * media_kit
// // * media_kit_video
// // * media_kit_libs_video
// import 'package:media_kit/media_kit.dart'; // Provides [Player], [Media], [Playlist] etc.
// import 'package:media_kit_video/media_kit_video.dart'; // Provides [VideoController] & [Video] etc.

// class MyScreen extends StatefulWidget {
//   const MyScreen({Key? key, required this.url}) : super(key: key);
//   final String url;
//   @override
//   State<MyScreen> createState() => MyScreenState();
// }

// class MyScreenState extends State<MyScreen> {
//   // Create a [Player] to control playback.
//   late final player = Player();
//   // Create a [VideoController] to handle video output from [Player].
//   late final controller = VideoController(player);

//   @override
//   void initState() {
//     super.initState();

//     MediaKit.ensureInitialized();
//     init();
//   }

//   init() async {
//     player.open(Media(widget.url));
//     String srtUrl = widget.url.replaceAll(RegExp(r'\.\w+$'), '.srt');
//     Response? response;
//     try {
//       response = await Dio().get(srtUrl);
//       showToast('发现同名字幕文件，加载中...');
//       final String fileContents = response.data ?? '';
//       await player.setSubtitleTrack(SubtitleTrack.data(fileContents));
//     } catch (e) {
//       showToast('未发现同名字幕文件');
//       Log.w('get srt file error $e');
//     }
//   }

//   @override
//   void dispose() {
//     player.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: SizedBox(
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.width * 9.0 / 16.0,
//         // Use [Video] widget to display video output.
//         child: Video(
//           controller: controller,
//           // controls: CupertinoVideoControls,
//         ),
//       ),
//     );
//   }
// }
