import 'package:app_manager/app_manager.dart';
import 'package:app_manager/controller/app_manager_controller.dart';
import 'package:app_manager/controller/check_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class AppSelect extends StatefulWidget {
  const AppSelect({super.key});

  @override
  State createState() => _AppSelectState();
}

class _AppSelectState extends State<AppSelect> {
  AppManagerController appManagerController = Get.put(AppManagerController());
  String filter = '';

  @override
  void initState() {
    super.initState();
    Get.put(CheckController());
    appManagerController.getUserApp();
  }

  @override
  void dispose() {
    Get.delete<CheckController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
          child: SearchBox(
            onInput: (data) {
              filter = data;
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: GetBuilder<AppManagerController>(
            init: AppManagerController(),
            autoRemove: false,
            builder: (context) {
              return AppListPage(filter: filter, appInfos: context.userApps);
            },
          ),
        ),
      ],
    );
  }
}
