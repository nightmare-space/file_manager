import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'landscape_player_controls.dart';

class LandscapePlayer extends StatefulWidget {
  LandscapePlayer({
    Key? key,
    required this.url,
  }) : super(key: key);
  final String url;

  @override
  _LandscapePlayerState createState() => _LandscapePlayerState();
}

class _LandscapePlayerState extends State<LandscapePlayer> {
  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    VideoPlayerController videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url));

    flickManager = FlickManager(videoPlayerController: videoPlayerController);
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlickVideoPlayer(
        flickManager: flickManager,
        preferredDeviceOrientation: [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft],
        systemUIOverlay: [],
        flickVideoWithControls: FlickVideoWithControls(
          controls: LandscapePlayerControls(),
        ),
      ),
    );
  }
}
