import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/file_manager_controller.dart';
import 'view/file_manager_view.dart';

class FileManagerPage extends StatefulWidget {
  const FileManagerPage({super.key});

  @override
  State<FileManagerPage> createState() => _FileManagerPageState();
}

class _FileManagerPageState extends State<FileManagerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FMView(
          controller: Get.find<FMController>(),
        ),
      ),
    );
  }
}
