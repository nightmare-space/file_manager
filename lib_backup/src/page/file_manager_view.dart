import 'dart:io';
import 'dart:ui';
import 'package:file_manager/src/config/global.dart';
import 'package:file_manager/src/io/file_io.dart';
import 'package:file_manager/src/page/file_manager_controller.dart';
import 'package:file_manager/src/widgets/item_imgheader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:global_repository/global_repository.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:file_manager/src/io/src/file.dart';
import 'package:file_manager/src/io/src/file_entity.dart';
import 'package:file_manager/src/provider/file_manager_notifier.dart';
import 'package:flutter/material.dart';
import '../io/src/file.dart';
import 'utils/gesture_handler.dart';
import 'widget/file_item_suffix.dart';

import 'package:path/path.dart' as path;

Directory appDocDir;

typedef PathCallback = Future<void> Function(String path);

class FileManagerView extends StatefulWidget {
  const FileManagerView({
    Key key,
    @required this.controller,
    // 这个值为真，单机item的时候会直接返回item的路径
    this.chooseFile = false,
    this.pathCallBack,
  }) : super(key: key);
  final FileManagerController controller;
  final bool chooseFile; //是用这个页面选择文件
  final PathCallback pathCallBack;

  @override
  _FileManagerViewState createState() => _FileManagerViewState();
}

class _FileManagerViewState extends State<FileManagerView>
    with TickerProviderStateMixin {
  FileManagerController _controller;
  //列表滑动控制器
  final ScrollController _scrollController = ScrollController();
  //动画控制器，用来控制文件夹进入时的透明度
  AnimationController _animationController;
  //透明度动画补间值
  Animation<double> _opacityTween;
  //记录每一次的浏览位置，key 是路径，value是offset

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    initAnimation();
    initFMPage();
  }

  @override
  void didUpdateWidget(FileManagerView oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: IconThemeData(
          color: Theme.of(context).accentColor,
        ),
      ),
      child: buldHome(context),
    );
  }

  void initAnimation() {
    //初始化动画，这是切换文件路径时的透明度动画
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 200,
      ),
    );
    final Animation<double> curve = CurvedAnimation(
      parent: _animationController,
      curve: Curves.ease,
    );
    _opacityTween = Tween<double>(begin: 0.0, end: 1.0)
        .animate(curve); //初始化这个动画的值始终为一，那么第一次打开就不会有透明度的变化
    _opacityTween.addListener(() {
      setState(() {});
    });
    _animationController.forward();
  }

  void _onAfterRendering(Duration timeStamp) {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> initFMPage() async {
    //页面启动的时候的初始化

    _controller.addListener(controllerCallback);
    print('初始化的路径 -> ${_controller.dirPath}');
    if (_controller.fileNodes.isEmpty) {
      _controller.updateFileNodes();
    }
  }

  void controllerCallback() {
    if (mounted) {
      setState(() {});
      getNodeFullArgs();
      if (historyOffset.keys.contains(_controller.dirPath)) {
        _scrollController.jumpTo(historyOffset[_controller.dirPath]);
        historyOffset.remove(_controller.dirPath);
      } else {
        _scrollController.jumpTo(0);
      }
    }
  }

  void repeatAnima() {
    //重复播放动画
    _animationController.reset();
    _animationController.forward();
  }

  // 这是一个异步方法，来获得文件节点的其他参数

  Future<void> getNodeFullArgs() async {
    for (final FileEntity fileNode in _controller.fileNodes) {
      //将文件的ls输出详情以空格隔开分成列表
      if (fileNode.nodeName != '..') {
        final List<String> infos = fileNode.fullInfo.split(RegExp(r'\s{1,}'));
        fileNode.modified = '${infos[3]}  ${infos[4]}';
        if (fileNode.isFile) {
          fileNode.size = FileSizeUtils.getFileSizeFromStr(infos[2]);
          // print('fileNode.size ->${fileNode.size}');
        } else {
          fileNode.itemsNumber = '${infos[1]}项';
        }
        fileNode.mode = infos[0];
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  Future<bool> onWillPop() async {
    final Clipboards clipboards = Global.instance.clipboards;
    clipboards.clearCheck();
    if (Scaffold.of(context).isDrawerOpen) {
      return true;
    }
    if (widget.chooseFile) {
      //当在其他面直接唤起文件管理器的时候返回键直接pop
      return true;
    }
    if (_controller.dirPath == '/') {
      Navigator.pop(context);
    }
    final String backpath = parentOf(_controller.dirPath);
    _controller.updateFileNodes(backpath);

    return false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();

    widget.controller.removeListener(controllerCallback);
    super.dispose();
  }

  WillPopScope buldHome(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Material(
        color: Colors.white,
        elevation: 8.0,
        child: FadeTransition(
          opacity: _opacityTween,
          child: RefreshIndicator(
            onRefresh: () async {
              _controller.updateFileNodes();
            },
            displacement: 1,
            child: DraggableScrollbar.semicircle(
              controller: _scrollController,
              child: buildListView(),
            ),
          ),
        ),
      ),
    );
  }

  ListView buildListView() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      cacheExtent: 400,
      controller: _scrollController,
      itemCount: _controller.fileNodes.length,
      padding: EdgeInsets.zero,
      //不然会有一个距离上面的边距
      itemBuilder: (BuildContext context, int index) {
        final FileEntity entity = _controller.fileNodes[index];
        return FileItem(
          controller: _controller,
          onTap: () {
            if (widget.chooseFile && entity.isFile) {
              Navigator.pop(
                context,
                '${_controller.dirPath}/${entity.nodeName}',
              );
              return;
            }
            itemOnTap(
              entity: entity,
              controller: _controller,
              scrollController: _scrollController,
              context: context,
            );
          },
          onLongPress: () {
            if (widget.chooseFile) {
              return;
            }
            itemOnLongPress(
              context: context,
              entity: entity,
              controller: _controller,
            );
          },

          checkCall: (String path) {
            // if (fiMaPageNotifier.checkPath.contains(path)) {
            //   fiMaPageNotifier.removeCheck(path);
            // } else {
            //   fiMaPageNotifier.addCheck(path);
            // }
          },
          // isCheck: fiMaPageNotifier.checkPath.contains(_fileNodes[index].path),
          fileEntity: entity,
        );
      },
    );
  }
}

class FileItem extends StatefulWidget {
  const FileItem({
    Key key,
    this.fileEntity,
    this.isCheck = false,
    this.checkCall,
    this.apkTool,
    this.controller,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);
  final FileManagerController controller;
  final FileEntity fileEntity;
  final Function apkTool;
  final bool isCheck;
  final Function(String path) checkCall;
  final void Function() onTap;
  final void Function() onLongPress;

  @override
  _FileItemState createState() => _FileItemState();
}

class _FileItemState extends State<FileItem>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController; //动画控制器
  Animation<double> curvedAnimation;
  Animation<double> tweenPadding; //边距动画补间值
  FileEntity fileEntity;
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
    curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceOut,
    );
    tweenPadding = Tween<double>(
      begin: dx,
      end: 0,
    ).animate(curvedAnimation);
  }

  double dx = 0.0;
  void _handleDragStart(DragStartDetails details) {
    //控件点击的回调
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // print(details.globalPosition);
    // if (dx >= 40.0) {
    //   if (dx != (details.globalPosition.dx - _tmp)) {
    //     Feedback.forLongPress(context);
    //   }
    // } else
    dx += details.delta.dx;
    if (dx >= 40) {
      dx = 40.0;
    }
    if (dx <= 0) {
      dx = 0;
    }
    // print(dx);
    setState(() {});
  }

  void _handleDragEnd(DragEndDetails details) {
    if (dx == 40.0) {
      Feedback.forLongPress(context);
      clipboards.addCheck(fileEntity);
      setState(() {});
    }
    tweenPadding = Tween<double>(
      begin: dx,
      end: 0,
    ).animate(curvedAnimation);
    tweenPadding.addListener(() {
      setState(() {
        dx = tweenPadding.value;
      });
    });
    _animationController.reset();
    _animationController.forward().whenComplete(() {});
  }

  Clipboards clipboards;
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fileEntity = widget.fileEntity;
    clipboards = Global.instance.clipboards;
    final List<String> _tmp = fileEntity.path.split(' -> '); //有的有符号链接
    final String currentFileName = _tmp.first.split('/').last; //取前面那个就没错
    // Log.d(fileEntity);
    final Widget _iconData = getWidgetFromExtension(
      fileEntity,
      context,
      fileEntity.isFile,
    ); //显示的头部件
    return Container(
      height: 54,
      child: Stack(
        children: <Widget>[
          if (clipboards.checkNodes.contains(fileEntity))
            Container(
              color: Colors.grey.withOpacity(0.6),
            ),
          InkWell(
            splashColor: Colors.transparent,
            onLongPress: () {
              widget.onLongPress();
            },
            onTap: () {
              widget.onTap();
            },
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: _handleDragStart,
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
              child: Transform(
                transform: Matrix4.identity()..translate(dx),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  child: Stack(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          // header icon
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: _iconData,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  // width: MediaQuery.of(context).size.width,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      currentFileName,
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .fontFamily,
                                      ),
                                    ),
                                  ),
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width -
                                        8 -
                                        30,
                                    child: Text(
                                      fileEntity.info,
                                      maxLines: 1,
                                      style: TextStyle(
                                        // fontSize: 12,
                                        fontFamily: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .fontFamily,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      FileItemSuffix(
                        fileNode: fileEntity,
                      ),
                      if (_tmp.length == 2)
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '->    ',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 通过判断文件节点的扩展名来显示对应的icon
Widget getWidgetFromExtension(FileEntity fileNode, BuildContext context,
    [bool isFile = true]) {
  if (isFile) {
    if (fileNode.nodeName.endsWith('.zip'))
      return SvgPicture.asset(
        'packages/file_manager/assets/icon/zip.svg',
        width: 20.0,
        height: 20.0,
        color: Theme.of(context).iconTheme.color,
      );
    else if (fileNode.nodeName.endsWith('.apk'))
      return const Icon(
        Icons.android,
      );
    else if (fileNode.nodeName.endsWith('.mp4'))
      return const Icon(
        Icons.video_library,
      );
    else if (fileNode.nodeName.endsWith('.jpg') ||
        fileNode.nodeName.endsWith('.png')) {
      return ItemImgHeader(
        fileNode: fileNode as AbstractNiFile,
      );
    } else
      return SvgPicture.asset(
        'packages/file_manager/assets/icon/file.svg',
        width: 20.0,
        height: 20.0,
      );
  } else {
    return SvgPicture.asset(
      'packages/file_manager/assets/icon/directory.svg',
      width: 20.0,
      height: 20.0,
      color: Theme.of(context).iconTheme.color,
    );
  }
}
