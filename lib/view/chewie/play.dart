import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:video_player/video_player.dart';

class PlayWidget extends StatefulWidget {
  const PlayWidget({super.key, required this.url});
  final String url;

  @override
  State<PlayWidget> createState() => _PlayWidgetState();
}

class _PlayWidgetState extends State<PlayWidget> {
  late final videoPlayerController = VideoPlayerController.networkUrl(
    Uri.parse(widget.url),
    closedCaptionFile: _loadCaptions(),
  );

  late final SubtitleController subtitleController;
  ChewieController? chewieController;
  @override
  void initState() {
    super.initState();
    String srtUrl = widget.url.replaceAll(RegExp(r'\.\w+$'), '.srt');
    subtitleController = SubtitleController(
      subtitleUrl: srtUrl,
      subtitleDecoder: SubtitleDecoder.utf8,
      subtitleType: SubtitleType.srt,
    );
    init();
  }

  void init() async {
    await videoPlayerController.initialize();

    chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: true,
        customControls: CupertinoControls(
          backgroundColor: Color.fromRGBO(41, 41, 41, 0.7),
          iconColor: Color.fromARGB(255, 200, 200, 200),
        ));
    setState(() {});

    // 切换到横屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  Future<ClosedCaptionFile> _loadCaptions() async {
    String srtUrl = widget.url.replaceAll(RegExp(r'\.\w+$'), '.srt');
    print('srtUrl $srtUrl');
    Response? response;
    try {
      response = await Dio().get(srtUrl);
      showToast('发现同名字幕文件，加载中...');
      final String fileContents = response.data ?? '';
      SubRipCaptionFile file = SubRipCaptionFile(fileContents);
      Log.i(file.captions);
      return file;
    } catch (e) {
      showToast('未发现同名字幕文件');
      Log.w('get srt file error $e');
    }
    return SubRipCaptionFile('');
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    // 切换到竖屏

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (chewieController == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final playerWidget = Chewie(
      controller: chewieController!,
    );
    return Scaffold(
      body: SubtitleWrapper(
        videoPlayerController: chewieController!.videoPlayerController,
        subtitleController: subtitleController,
        subtitleStyle: const SubtitleStyle(
          textColor: Colors.white,
          hasBorder: true,
        ),
        videoChild: playerWidget,
      ),
    );
  }
}
