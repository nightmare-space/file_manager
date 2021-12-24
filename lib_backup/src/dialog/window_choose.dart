import 'package:file_manager/src/page/file_manager_controller.dart';
import 'package:file_manager/src/page/file_manager_view.dart';
import 'package:flutter/material.dart';

typedef AddNewPageCall = Future<void> Function();
typedef DeletePageCall = Future<void> Function(int index);
typedef ChangePageCall = void Function(int index);

// 点击右上角页面弹起的窗口选择页面
class PageChoose extends StatefulWidget {
  const PageChoose({
    Key key,
    this.controllers,
    this.addNewPageCall,
    this.deletePageCall,
    this.changePageCall,
    this.initIndex,
  }) : super(key: key);
  final int initIndex;
  final List<FileManagerController> controllers;
  final AddNewPageCall addNewPageCall;
  final DeletePageCall deletePageCall;
  final ChangePageCall changePageCall;

  @override
  _PageChooseState createState() => _PageChooseState();
}

class _PageChooseState extends State<PageChoose> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // print('object');
          Navigator.pop(context);
        },
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Center(
              child: ListView.builder(
                cacheExtent: 9999,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 6,
                    right: MediaQuery.of(context).size.width / 6 - 20),
                // physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                // pageSnapping: false,
                controller: ScrollController(
                    initialScrollOffset: widget.initIndex *
                            2 /
                            3 *
                            MediaQuery.of(context).size.width +
                        20 * widget.initIndex),
                itemCount: widget.controllers.length,
                itemBuilder: (BuildContext context, int index) {
                  // bool isCur = index == popPage;
                  // print(popPage);
                  return Column(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 1.5,
                            height: MediaQuery.of(context).size.height / 2,
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                AbsorbPointer(
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: MediaQuery(
                                        data: MediaQueryData(
                                          size: Size(
                                            MediaQuery.of(context).size.width /
                                                1.5,
                                            MediaQuery.of(context).size.height /
                                                2,
                                          ),
                                        ),
                                        child: FileManagerView(
                                          controller: widget.controllers[index],
                                          chooseFile: true,
                                          key: GlobalObjectKey('FMZ$index'),
                                          // initpath: widget.paths[index],
                                        ),
                                      )),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.5,
                                  height:
                                      MediaQuery.of(context).size.height / 2,
                                  child: Material(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12.0),
                                      ),
                                    ),
                                    color: Colors.transparent,
                                    child: InkWell(
                                      highlightColor: const Color(0x88d9d9d9),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(12.0),
                                      ),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        widget.changePageCall(index);
                                      },
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: const Alignment(1, -1),
                                  child: SizedBox(
                                    width: 36.0,
                                    height: 36.0,
                                    child: Material(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20.0),
                                        ),
                                      ),
                                      color: Colors.transparent,
                                      child: InkWell(
                                        highlightColor: const Color(0xffd9d9d9),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(20.0),
                                        ),
                                        onTapDown: (_) {
                                          // Vibration.vibrate(
                                          //     duration: 40, amplitude: 255);
                                        },
                                        onTap: () {
                                          if (widget.controllers.length > 1) {
                                            final int tmp = index;
                                            widget.controllers.removeAt(tmp);
                                            widget.deletePageCall(tmp);
                                            setState(() {});
                                          } else {
                                            // showToast(
                                            //     context: context,
                                            //     message: '至少需要一个页面');
                                          }
                                        },
                                        child: const Icon(
                                          Icons.clear,
                                          size: 24.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Text(
                        widget.controllers[index].dirPath,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.8),
              child: SizedBox(
                width: 128.0,
                height: 36.0,
                child: Material(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  color: const Color(0xffededed),
                  child: InkWell(
                    highlightColor: const Color(0xffd9d9d9),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                    onTapDown: (_) {
                      // Vibration.vibrate(duration: 40, amplitude: 255);
                    },
                    onTap: () {
                      widget.addNewPageCall();
                    },
                    child: const Icon(
                      Icons.add,
                      size: 36.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
