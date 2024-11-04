import 'package:dio/dio.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';
import 'package:video_player/video_player.dart';

import 'landscape_player_controls.dart';

// TODO 研究各个视频播放器
class LandscapePlayer extends StatefulWidget {
  LandscapePlayer({
    Key? key,
    required this.url,
  }) : super(key: key);
  final String url;

  @override
  State createState() => _LandscapePlayerState();
}

class _LandscapePlayerState extends State<LandscapePlayer> {
  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    print('widget.url ${widget.url}');
    // http://localhost:14001/Users/nightmare/Downloads/Aquaman.V2.2018.ULTRAHD.Blu-ray.2160p.HEVC.Atmos.TrueHD7.1-sGn.mkv
    // get srt file
    VideoPlayerController videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      closedCaptionFile: _loadCaptions(),
    );
    flickManager = FlickManager(videoPlayerController: videoPlayerController);
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  ///If you have subtitle assets

  Future<ClosedCaptionFile> _loadCaptions() async {
    String srtUrl = widget.url.replaceAll(RegExp(r'\.\w+$'), '.srt');
    print('srtUrl $srtUrl');
    Response? response;
    try {
      response = await Dio().get(srtUrl);
      showToast('发现同名字幕文件，加载中...');
      final String fileContents = response.data ?? '';
      flickManager.flickControlManager!.showSubtitle();
      Log.i('fileContents $fileContents');
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
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        SystemChrome.setPreferredOrientations(
          [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
        );
      },
      child: Scaffold(
        body: FlickVideoPlayer(
          flickManager: flickManager,
          preferredDeviceOrientation: [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft],
          systemUIOverlay: [],
          flickVideoWithControls: FlickVideoWithControls(
            controls: LandscapePlayerControls(),
          ),
        ),
      ),
    );
  }
}
