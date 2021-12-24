import 'dart:io';

import 'package:file_manager/src/config/global.dart';
import 'package:file_manager/src/page/file_manager_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path/path.dart' as p;

import '../colors/file_colors.dart';
import '../utils/bookmarks.dart';
import 'setting_page.dart';

class FileManagerDrawer extends StatefulWidget {
  const FileManagerDrawer({
    Key key,
    @required this.controller,
  }) : super(key: key);

  final FileManagerController controller;
  @override
  _FileManagerDrawerState createState() => _FileManagerDrawerState();
}

class _FileManagerDrawerState extends State<FileManagerDrawer>
    with SingleTickerProviderStateMixin {
  List<String> rootInfo = <String>[];
  List<String> sdcardInfo = <String>[];
  List<String> bookMarks = <String>[];
  AnimationController controller;
  // 根目录的大小动画
  Animation<double> rootAnima;
  // 根目录的大小动画
  Animation<double> sdcardAnima;
  @override
  void initState() {
    super.initState();
    init();
    initBookMarks();
  }

  Future<void> init() async {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (Platform.isWindows) {
      return;
    }
    print(await NiProcess.exec('id'));

    final String result = await NiProcess.exec('/system/bin/df -k');
    for (final String line in result.split('\n')) {
      print('line -> $line');
    }
    final List<String> infos = result.split('\n');
    for (final String line in infos) {
      if (line.endsWith('/')) {
        rootInfo = line.split(RegExp(r'\s{1,}'));
        rootAnima = Tween<double>(
          begin: 0,
          end: int.parse(rootInfo[2]) / int.parse(rootInfo[1]),
        ).animate(
          CurvedAnimation(
            curve: Curves.ease,
            parent: controller,
          ),
        );
        setState(() {});
      }
      if (line.endsWith('/storage/emulated')) {
        sdcardInfo = line.split(RegExp(r'\s{1,}'));
        sdcardAnima = Tween<double>(
          begin: 0,
          end: int.parse(sdcardInfo[2]) / int.parse(sdcardInfo[1]),
        ).animate(
          CurvedAnimation(
            curve: Curves.ease,
            parent: controller,
          ),
        );
        setState(() {});
      }
    }

    controller.forward();
    setState(() {});
  }

  Future<void> initBookMarks() async {
    bookMarks = await BookMarks.getBookMarks();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (rootInfo.isEmpty && Platform.isAndroid) {
      return const SpinKitThreeBounce(
        color: FileColors.fileAppColor,
        size: 16.0,
      );
    }
    double width;
    if (PlatformUtil.isDesktop()) {
      width = 300;
    } else {
      width = MediaQuery.of(context).size.width * 3 / 4;
    }
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          ),
        ),
        elevation: 8.0,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 100,
                    color: FileColors.fileAppColor,
                  ),
                  Material(
                    color: Colors.white,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 100.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0, top: 4.0),
                            child: Text(
                              '本地路径',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              widget.controller.updatePath('/');
                              Navigator.of(context).pop();
                            },
                            child: SizedBox(
                              height: 48.0,
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Text(
                                          '根目录',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (rootInfo.isNotEmpty)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(rootInfo[0]),
                                              Text(
                                                  '${FileSizeUtils.getFileSizeFromStr('${int.parse(rootInfo[2]) * 1024}')}/ ${FileSizeUtils.getFileSizeFromStr('${int.parse(rootInfo[1]) * 1024}')}')
                                            ],
                                          )
                                        else
                                          const SizedBox(),
                                        AnimatedBuilder(
                                          animation: controller,
                                          builder: (BuildContext context,
                                              Widget child) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                backgroundColor: Colors.grey,
                                                value: rootAnima.value,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                  Theme.of(context).accentColor,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (sdcardInfo.isNotEmpty)
                            InkWell(
                              onTap: () async {
                                widget.controller.updatePath(
                                  Global.instance.doucumentDir,
                                );
                                Navigator.of(context).pop();
                              },
                              child: SizedBox(
                                height: 48.0,
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          const Text(
                                            '外部储存',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (sdcardInfo.isNotEmpty)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(sdcardInfo[0]),
                                                Text(
                                                    '${FileSizeUtils.getFileSizeFromStr('${int.parse(sdcardInfo[2]) * 1024}')}/ ${FileSizeUtils.getFileSizeFromStr('${int.parse(sdcardInfo[1]) * 1024}')}')
                                              ],
                                            )
                                          else
                                            const SizedBox(),
                                          AnimatedBuilder(
                                            animation: controller,
                                            builder: (BuildContext context,
                                                Widget child) {
                                              return ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: LinearProgressIndicator(
                                                  backgroundColor: Colors.grey,
                                                  value: sdcardAnima.value,
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                    Theme.of(context)
                                                        .accentColor,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0, top: 4.0),
                            child: Text(
                              '书签',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          if (bookMarks.isNotEmpty)
                            SizedBox(
                              height: bookMarks.length * 48.0,
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(0.0),
                                itemCount: bookMarks.length,
                                itemBuilder: (BuildContext c, int i) {
                                  return InkWell(
                                    onTap: () {
                                      widget.controller.updatePath(
                                        bookMarks[i],
                                      );

                                      Navigator.pop(context);
                                    },
                                    onLongPress: () {
                                      onLongPress(i);
                                    },
                                    child: MarksItem(
                                      marksPath: bookMarks[i],
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.only(left: 4.0, top: 4.0),
                  //   child: Text(
                  //     '其他',
                  //     style: TextStyle(
                  //       color: Colors.grey,
                  //       fontSize: 16.0,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.only(left: 12.0, top: 4.0),
                  //   child: Text(
                  //     'Img镜像比较功能',
                  //     style: TextStyle(
                  //       color: Colors.black,
                  //       fontSize: 16.0,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              Align(
                alignment: const Alignment(1, 1),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<Setting>(
                            builder: (_) {
                              return Theme(
                                data: Theme.of(context),
                                child: Setting(),
                              );
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onLongPress(int i) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return Center(
          child: SizedBox(
            height: 36.0,
            width: MediaQuery.of(context).size.width - 100,
            child: Material(
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () async {
                  await BookMarks.removeMarks(bookMarks[i]);
                  Navigator.pop(context);
                  initBookMarks();
                },
                child: const Center(
                  child: Text(
                    '删除该书签',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MarksItem extends StatefulWidget {
  const MarksItem({Key key, this.marksPath}) : super(key: key);
  final String marksPath;

  @override
  _MarksItemState createState() => _MarksItemState();
}

class _MarksItemState extends State<MarksItem>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController; //动画控制器
  Animation<double> curvedAnimation;
  Animation<double> tweenPadding; //边距动画补间值
  double _tmp;

  double dx = 0.0;

  @override
  void initState() {
    super.initState();
    initAnimation();
  }

  void initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    curvedAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.bounceOut);
    tweenPadding = Tween<double>(
      begin: dx,
      end: 0,
    ).animate(curvedAnimation);
  }

  void _handleDragStart(DragStartDetails details) {
    //控件点击的回调
    _tmp = details.globalPosition.dx;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // print(details.globalPosition);
    // if (dx >= 40.0) {
    //   if (dx != (details.globalPosition.dx - _tmp)) {
    //     Feedback.forLongPress(context);
    //   }
    // } else
    dx = details.globalPosition.dx - _tmp;
    if (dx <= -40) {
      dx = -40.0;
    }
    if (dx >= 0) {
      dx = 0;
    }
    // print(dx);
    setState(() {});
  }

  void _handleDragEnd(DragEndDetails details) {
    if (dx == 40.0) {
      Feedback.forLongPress(context);

      setState(() {});
    }
    // tweenPadding = Tween<double>(
    //   begin: dx,
    //   end: 0,
    // ).animate(curvedAnimation);
    // tweenPadding.addListener(() {
    //   setState(() {
    //     dx = tweenPadding.value;
    //   });
    // });
    // _animationController.reset();
    // _animationController.forward().whenComplete(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: <Widget>[
          Transform(
            transform: Matrix4.identity()..translate(dx),
            child: SizedBox(
              height: 48.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SvgPicture.asset(
                    'packages/file_manager/assets/icon/directory.svg',
                    width: 30.0,
                    height: 30.0,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(p.basename(widget.marksPath)),
                      SizedBox(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            widget.marksPath,
                            // softWrap: true,
                            maxLines: 2,
                            // overflow: TextOverflow.visible,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          // Transform(
          //   transform: Matrix4.identity()..translate(dx),
          //   child: SizedBox(
          //     height: 40.0,
          //     child: Text(widget.marksPath),
          //   ),
          // ),
        ],
      ),
    );
  }
}
