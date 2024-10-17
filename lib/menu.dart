import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:url_launcher/url_launcher.dart';

import 'controller/file_manager_controller.dart';

class Menu extends StatefulWidget {
  const Menu({
    super.key,
    required this.entity,
    this.offset = const Offset(0, 0),
    this.prefix,
  });
  final FileEntity entity;
  final Offset offset;
  final String? prefix;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          top: min(
            widget.offset.dy,
            MediaQuery.of(context).size.height - 260.w,
          ),
          left: min(
            widget.offset.dx,
            MediaQuery.of(context).size.width - 200.w,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 0),
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16.w,
                    spreadRadius: 4.w,
                  )
                ],
              ),
              width: 200.w,
              child: Material(
                borderRadius: BorderRadius.circular(12.w),
                clipBehavior: Clip.antiAlias,
                color: Colors.white,
                elevation: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        // String url;
                        // FileManagerController fileManagerController = Get.find();
                        // String path = widget.entity.path;
                        // Directory dir = fileManagerController.dir;
                        // Uri uri;
                        // if (dir is DirectoryBrowser && dir.addr != null) {
                        //   uri = Uri.tryParse(dir.addr)!;
                        //   path = 'http://${uri.host}:${uri.port}$path';
                        // }
                        // await canLaunch(Uri.encodeFull(path)) ? await launch(Uri.encodeFull('$path' '?download=true')) : throw 'Could not launch $url';
                        // Navigator.of(context).pop();
                      },
                      child: SizedBox(
                        height: 48.w,
                        child: Align(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: const Text(
                              '下载',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        // FileManagerController fileManagerController = Get.find();
                        // String path = widget.entity.path;
                        // Directory dir = fileManagerController.dir;
                        // Uri uri;
                        // if (dir is DirectoryBrowser && dir.addr != null) {
                        //   uri = Uri.tryParse(dir.addr)!;
                        //   path = 'http://${uri.host}:${uri.port}$path';
                        // }
                        // await canLaunch(Uri.encodeFull(path)) ? await launch(Uri.encodeFull(path)) : throw 'Could not launch $url';
                        // Navigator.of(context).pop();
                      },
                      child: SizedBox(
                        height: 48.w,
                        child: Align(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: const Text(
                              '预览',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        Navigator.of(context).pop();
                        // Get.dialog(RenameFile(
                        //   entity: widget.entity,
                        // ));
                      },
                      child: SizedBox(
                        height: 48.w,
                        child: Align(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: const Text(
                              '重命名',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        Navigator.of(context).pop();
                        // Get.dialog(DeleteFile(
                        //   entity: widget.entity,
                        // ));
                      },
                      child: SizedBox(
                        height: 48.w,
                        child: Align(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: const Text(
                              '删除',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
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
        ),
      ],
    );
  }
}
