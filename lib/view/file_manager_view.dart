import 'package:file_manager/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import '../controller/file_manager_controller.dart';
import '../utils/icon_util.dart';
import '../main.dart';
import '../menu.dart';

enum FMMode {
  selectFile,
  selectDir,
  normal,
}

class FMView extends StatefulWidget {
  const FMView({
    super.key,
    this.mode = FMMode.normal,
    this.controller,
  });
  final FMMode mode;
  final FMController? controller;

  @override
  State<FMView> createState() => _FMViewState();
}

class _FMViewState extends State<FMView> {
  _FMViewState() {
    if (RuntimeEnvir.packageName != Config.packageName) {
      Config.package = Config.flutterPackage;
    }
  }
  bool isGrid = true;

  late FMController controller = widget.controller ?? Get.put(FMController());

  @override
  void initState() {
    super.initState();
  }

  Offset tapPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<FMController>(
        builder: (controller) {
          var files = controller.files;
          Color primaryColor = Theme.of(context).colorScheme.primary;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                header(),
                Expanded(
                  child: ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      FileEntity file = files[index];
                      bool isSelect = controller.selectFiles.contains(file);
                      return Material(
                        color: isSelect ? primaryColor.withOpacity(0.15) : Colors.transparent,
                        child: InkWell(
                          onTapDown: (details) {
                            tapPosition = details.globalPosition;
                          },
                          onTap: () async {
                            if (file is DirEntity) {
                              controller.enterDir('${controller.currentPath}/${file.name}');
                              return;
                            }
                            if (widget.mode == FMMode.selectFile) {
                              controller.selectFile(file);
                            } else {
                              controller.openFile(file);
                            }
                          },
                          onLongPress: () {
                            Get.dialog(
                              Menu(entity: file, offset: tapPosition),
                              barrierColor: Colors.transparent,
                            );
                          },
                          child: Builder(builder: (_) {
                            FileEntity file = files[index];
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 8.w,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.w),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40.w,
                                    height: 40.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.w),
                                    ),
                                    child: file is DirEntity
                                        ? SvgPicture.asset(
                                            'assets/dir.svg',
                                            color: Theme.of(context).colorScheme.primary,
                                            package: Config.package,
                                          )
                                        : getIconByExt(file.path),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          file.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          file.time,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface,
                                            fontSize: 12.w,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    formatBytes(file.size),
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.w,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  SizedBox header() {
    ScrollController scrollController = ScrollController();
    FMController controller = Get.find();
    String currentPath = controller.currentPath;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 48.w,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Row(
          children: [
            Material(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.w),
              child: InkWell(
                onTap: () {
                  controller.enterParentDir();
                },
                borderRadius: BorderRadius.circular(12.w),
                child: SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Container(
                height: 40.w,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12.w),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Builder(
                      builder: (_) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (scrollController.hasListeners) {
                            scrollController.jumpTo(
                              scrollController.position.maxScrollExtent,
                            );
                          }
                        });
                        if (currentPath == '/') {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 2.w,
                              horizontal: 6.w,
                            ),
                            child: Text(
                              '/',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          );
                        }
                        List<String> dir = currentPath.split('/');
                        // Log.w(dir);
                        dir[0] = '/';
                        List<Widget> children = [];
                        for (int i = 0; i < dir.length; i++) {
                          // Log.i(i.toString() + dir.take(i + 1).join('/'));
                          if (i == dir.length - 1) {
                            children.add(
                              Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8.w),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 2.w,
                                  horizontal: 6.w,
                                ),
                                child: Text(
                                  dir[i],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            );
                            break;
                          }
                          children.add(
                            GestureDetector(
                              onTap: () {
                                // FileManagerController controller = Get.find();
                                String path = dir.take(i + 1).join('/').replaceAll('//', '/');
                                controller.enterDir(path);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 2.w,
                                  horizontal: 6.w,
                                ),
                                child: Text(
                                  dir[i],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return SingleChildScrollView(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(children: children),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Material(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.w),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: const BoxDecoration(),
                child: InkWell(
                  onTap: () {
                    isGrid = !isGrid;
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(12.w),
                  child: Icon(
                    isGrid ? Icons.more_vert : Icons.apps,
                    color: colorScheme.onSurface,
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
