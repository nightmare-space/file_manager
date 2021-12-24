import 'dart:io';
import 'dart:ui';
import 'package:file_manager/src/page/file_manager_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:global_repository/global_repository.dart';
import 'colors/file_colors.dart';
import 'config/global.dart';
import 'dialog/add_entity_page.dart';
import 'dialog/window_choose.dart';
import 'file_manager.dart';
import 'page/center_drawer.dart';
import 'page/file_manager_drawer.dart';
import 'page/file_manager_view.dart';
import 'provider/file_manager_notifier.dart';
import 'utils/bookmarks.dart';

class FileManagerHomePage extends StatefulWidget {
  const FileManagerHomePage({
    Key key,
  }) : super(key: key);
  @override
  _FileManagerHomePageState createState() => _FileManagerHomePageState();
}

class _FileManagerHomePageState extends State<FileManagerHomePage>
    with TickerProviderStateMixin {
  final List<FileManagerController> _controllers = [];

  final PageController _commonController = PageController(
    initialPage: 0,
    viewportFraction: 0.5,
  ); //主页面切换的页面切换控制器
  final PageController _titlePageController = PageController(
    initialPage: 0,
  ); //头部是一个可以滑动的PageView
  int currentPage = 0; //当前页面
  FileState fileState = FileState.fileDefault;
  // 多个页面在缩放时用到的四阶矩阵
  Matrix4 matrix4;
  AnimationController pastIconAnimaController;
  // 是否有储存权限
  bool hasPermission = false;
  bool pageIsInit = false;
  Clipboards clipboards = Global.instance.clipboards;
  @override
  void initState() {
    super.initState();
    clipboards.addListener(() {
      setState(() {});
    });
    initAnimation();
    initHomePage();
    test();
  }

  Future<void> test() async {
    // print(await NiProcess.exec('env'));
  }

  @override
  void dispose() {
    _titlePageController.dispose();
    _commonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FileManagerController curController;

    if (_controllers.isEmpty)
      return const SpinKitThreeBounce(
        color: FileColors.fileAppColor,
        size: 16.0,
      );
    if (_commonController.hasClients) {
      curController = _controllers[_commonController.page.toInt()];
    } else {
      curController = _controllers.first;
    }
    return Scaffold(
      drawer: FileManagerDrawer(controller: curController),
      backgroundColor: Colors.white,
      body: Builder(
        builder: (BuildContext context) {
          return Row(
            children: [
              // if (PlatformUtil.isDesktop())
              //   FileManagerDrawer(
              //     controller: curController,
              //   ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: <Widget>[
                    buildBody(context),
                    // 最下面的透明的 widget
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SizedBox(
        height: 48,
        child: Material(
          elevation: 8,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  final int curPage = _commonController.page.toInt();
                  if (curPage == 0) {
                    return;
                  }
                  changePage(curPage - 1);
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
              IconButton(
                onPressed: () async {
                  await showCustomDialog<void>(
                    context: context,
                    child: Theme(
                      data: Theme.of(context),
                      child: AddEntity(
                        controller:
                            _controllers[_commonController.page.toInt()],
                      ),
                    ),
                  );
                  _controllers[_commonController.page.toInt()]
                      .notifyListeners();
                },
                icon: const Icon(Icons.add),
              ),
              IconButton(
                onPressed: () {
                  final int curPage = _commonController.page.toInt();
                  if (curPage == _controllers.length - 1) {
                    return;
                  }
                  changePage(curPage + 1);
                },
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: <Widget>[
      //     Padding(
      //       padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      //       child: ScaleTransition(
      //         scale:
      //             _rotated.drive(Tween<double>(begin: 0.0, end: 1.0 / 0.125)),
      //         child: FloatingActionButton(
      //           onPressed: () async {
      //             showCustomDialog2<void>(
      //               child: FullHeightListView(
      //                 child: AddFileNode(
      //                   currentPath: _dirPaths[_titlePageController.page.toInt()],
      //                   isAddFile: false,
      //                 ),
      //               ),
      //             );
      //           },
      //           child: Icon(
      //             Octicons.getIconData('file-directory'),
      //             size: 24.0,
      //           ),
      //         ),
      //       ),
      //     ),
      //     Padding(
      //       padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      //       child: ScaleTransition(
      //         scale:
      //             _rotated.drive(Tween<double>(begin: 0.0, end: 1.0 / 0.125)),
      //         child: FloatingActionButton(
      //           onPressed: () async {
      //             showCustomDialog2<void>(
      //               child: FullHeightListView(
      //                 child: AddFileNode(
      //                   currentPath: _dirPaths[_titlePageController.page.toInt()],
      //                   isAddFile: true,
      //                 ),
      //               ),
      //             );
      //           },
      //           child: Icon(
      //             Octicons.getIconData('file'),
      //             size: 24.0,
      //           ),
      //         ),
      //       ),
      //     ),
      //     Padding(
      //       padding: EdgeInsets.all(8.0),
      //       child: FloatingActionButton(
      //         onPressed: () async {
      //           if (animationController.isDismissed) {
      //             await animationController.forward();
      //           } else if (animationController.isCompleted) {
      //             await animationController.reverse();
      //           }
      //           // animationController.reverse();
      //         },
      //         child: RotationTransition(
      //           turns: _rotated,
      //           child: Icon(
      //             Icons.add,
      //             size: 36.0,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Stack buildBody(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        buildAppBar(context),
        Padding(
          padding: EdgeInsets.only(
            top: MediaQueryData.fromWindow(window).padding.top + kToolbarHeight,
          ),
          child: Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                controller: _commonController,
                itemCount: _controllers.length,
                itemBuilder: (BuildContext context, int index) {
                  double scale = 1.0;
                  // if (pageIsInit && _commonController.hasClients) {
                  //   if (index - currentPage == 0)
                  //     scale = 1 - 0.2 * (_pageController.page - currentPage);
                  //   if (index - currentPage == 1)
                  //     scale = 0.8 + 0.2 * (_pageController.page - currentPage);
                  // }
                  matrix4 = Matrix4.identity()..scale(scale);
                  return SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Transform(
                      transform: matrix4,
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: FileManagerView(
                          pathCallBack: (String path) async {
                            // TODO
                            // _dirPaths[index] = path;
                            // setState(() {});
                            // setStatePathFile();
                          },
                          controller: _controllers[index],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        CenterDrawer(),
      ],
    );
  }

  void initAnimation() {
    //初始化动画
    pastIconAnimaController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
    pastIconAnimaController.addListener(() {
      setState(() {});
    });
  }

  Future<void> initHomePage() async {
    // 先初始化配置文件，因为要用很多平台路径
    if (!kIsWeb && Platform.isAndroid) {
      // 头部的pageview跟随
      // 滑动底栏即可滑动主页
      // _pageController.addListener(() {
      //   _commonController.jumpTo(_pageController.offset);
      //   currentPage = _pageController.page.toInt();
      //   _titlePageController.animateToPage(
      //     _pageController.page.round(),
      //     duration: const Duration(milliseconds: 200),
      //     curve: Curves.linear,
      //   ); //title的文件夹路径动画
      //   setState(() {});
      // });
    }
    getHistoryPaths();
    // print(appDocDir);
  }

  //软件将页面路径的列表以换行符分割保存进了储存
  Future<void> getHistoryPaths() async {
    // if (kIsWeb) {
    //   return;
    // }
    String temp = '';
    // final File historyFile = File(
    //   '${Config.filesPath}/FileManager/History_Path',
    // );
    // if (historyFile.existsSync()) {
    //   try {
    //     temp = await historyFile.readAsString();
    //   } catch (e) {
    //     print(e);
    //   }
    // } else {
    if (kIsWeb || Platform.isAndroid)
      temp = '/storage/emulated/0\n/storage/emulated/0';
    else {
      temp = Global.instance.doucumentDir;
    }
    // }
    temp.trim().split('\n').forEach((element) {
      _controllers.add(FileManagerController(element));
    });
    await Future<void>.delayed(const Duration(milliseconds: 600));
    //这个值为真才会启动左右滑动的效果
    pageIsInit = true;
    setState(() {});
  }

  void addNewPage(String path) {
    //添加一个页面
    _controllers.add(FileManagerController(path));
    setState(() {});
    // TODO
    // setStatePathFile();
    changePage(_controllers.length - 1);
  }

  Future<void> deletePage(int index) async {
    // 删除一个页面
    // _dirPaths.removeAt(index);
    setState(() {});
    // TODO
    // setStatePathFile();
  }

  void changePage(int page) {
    _commonController.animateToPage(
      page,
      duration: const Duration(milliseconds: 600),
      curve: Curves.ease,
    );
  }

  PreferredSize buildAppBar(BuildContext context) {
    if (clipboards.checkNodes.isNotEmpty && pastIconAnimaController.isDismissed)
      pastIconAnimaController.forward();
    else if (clipboards.clipboard.isEmpty &&
        pastIconAnimaController.isCompleted) {
      pastIconAnimaController.reverse();
    }
    //Appbar
    return PreferredSize(
      child: AppBar(
        elevation: 0.0,
        titleSpacing: 0,
        title: InkWell(
          onTap: () async {
            await Clipboard.setData(ClipboardData(
              text: _controllers[_titlePageController.page.toInt()].dirPath,
            ));
            Feedback.forLongPress(context);
            showToast('已复制路径');
          },
          child: SizedBox(
            height: 24.0,
            child: PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: _titlePageController,
              itemCount: _controllers.length,
              itemBuilder: (BuildContext context, int index) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _commonController.hasClients
                          ? _controllers[index].dirPath
                          : _controllers[index].dirPath,
                      style: const TextStyle(fontSize: 12.0),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        backgroundColor: FileColors.fileAppColor,
        leading: Align(
          alignment: Alignment.center,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            onLongPress: () {
              // Scaffold.of(pushContext).openDrawer();
            },
            child: const SizedBox(
              height: 36.0,
              width: 36.0,
              child: Icon(Icons.menu, size: 24.0),
            ),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Align(
              alignment: Alignment.center,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () async {
                  // if (fiMaPageNotifier.clipType == ClipType.Copy)
                  // showCustomDialog2<void>(
                  //   context: context,
                  //   child: FullHeightListView(
                  //     child: Copy(
                  //       targetPath: _dirPaths[_titlePageController.page.toInt()],
                  //       sourcePaths: fiMaPageNotifier.clipboard,
                  //     ),
                  //   ),
                  // );
                  // else {
                  //   for (final String path in fiMaPageNotifier.clipboard) {
                  //     await NiProcess.exec(
                  //         'mv $path ${_dirPaths[_titlePageController.page.toInt()]}\n');
                  //   }

                  //   // showToast2('粘贴完成');
                  //   fiMaPageNotifier.clearClipBoard();
                  //   eventBus.fire('');
                  // }
                  // fiMaPageNotifier.clearClipBoard();
                },
                child: SizedBox(
                  height: 36.0,
                  width: 36.0,
                  child: ScaleTransition(
                    scale: pastIconAnimaController,
                    child: const Icon(Icons.content_paste, size: 24.0),
                  ),
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
          //   child: ScaleTransition(
          //     scale: pastIconAnimaController,
          //     child: FloatingActionButton(
          //       mini: true,
          //       // materialTapTargetSize: MaterialTapTargetSize.padded,
          //       onPressed: () async {
          //       },
          //       child: Icon(
          //         Icons.content_paste,
          //         size: 18.0,
          //       ),
          //     ),
          //   ),
          // ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 24.0,
              height: 24.0,
              child: InkWell(
                borderRadius: BorderRadius.circular(8.0),
                onTap: () {
                  // return;

                  showDialog<void>(
                    context: context,
                    builder: (_) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          textTheme: TextTheme(
                            bodyText2: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(fontSize: 10.0),
                          ),
                        ),
                        child: PageChoose(
                          controllers: _controllers,
                          initIndex: currentPage,
                          changePageCall: changePage,
                          deletePageCall: deletePage,
                          addNewPageCall: () async {
                            Navigator.of(context).pop();
                            // print(
                            //     'PlatformUtil.documentsDir->${Global.instance.doucumentDir}');
                            addNewPage(Global.instance.doucumentDir);
                          },
                        ),
                      );
                    },
                  );
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                        style: BorderStyle.solid),
                  ),
                  child: Center(
                    child: Text('${_controllers.length}'),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Builder(
            builder: (BuildContext context) {
              return Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 36.0,
                  width: 36.0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    child: const Icon(Icons.more_vert, size: 22.0),
                    onTapDown: (TapDownDetails detials) {},
                    onTap: () {
                      // NiToast.showToast('已复制');
                      Future<void> showButtonMenu() async {
                        final RenderBox button =
                            context.findRenderObject() as RenderBox;
                        final RenderBox overlay = Overlay.of(context)
                            .context
                            .findRenderObject() as RenderBox;
                        final RelativeRect position = RelativeRect.fromRect(
                          Rect.fromPoints(
                            button.localToGlobal(Offset(button.size.width, 0.0),
                                ancestor: overlay),
                            button.localToGlobal(
                                button.size.bottomRight(Offset.zero),
                                ancestor: overlay),
                          ),
                          Offset.zero & overlay.size,
                        );
                        final int choose = await showMenu<int>(
                          context: context,
                          elevation: 1,

                          items: const <PopupMenuItem<int>>[
                            PopupMenuItem<int>(
                              value: 0,
                              child: Text('添加书签'),
                            ),
                            PopupMenuItem<int>(
                              child: Text('设为首页'),
                            ),
                            PopupMenuItem<int>(
                              child: Text('查看模式'),
                            ),
                            PopupMenuItem<int>(
                              value: 3,
                              child: Text('退出'),
                            ),
                          ],
                          // initialValue: 0,
                          position: position,
                        );
                        if (choose == 0) {
                          BookMarks.addMarks(
                            _controllers[_titlePageController.page.toInt()]
                                .dirPath,
                          );
                          showToast('已添加');
                          // showToast2('已添加');
                        }
                        if (choose == 3) {
                          Navigator.pop(context);
                          // SystemNavigator.pop(animated: false);
                        }
                        // PlatformChannel.Drawer.invokeMethod<void>('Exit');
                      }

                      showButtonMenu();
                      // Overlay.of(context).insert(weixinOverlayEntry);
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(
            width: 10.0,
          )
        ],
      ),
      preferredSize: const Size.fromHeight(50),
    );
  }
}
