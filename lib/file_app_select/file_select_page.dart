import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'app_select.dart';
import '../view/file_manager_view.dart';

class FileAppSelectPage extends StatefulWidget {
  const FileAppSelectPage({super.key, this.path});
  final String? path;

  @override
  State createState() => _FileAppSelectPageState();
}

class _FileAppSelectPageState extends State<FileAppSelectPage> {
  PageController pageController = PageController();
  int page = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: NiIconButton(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        title: Text(
          '选择文件',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 6.w),
              child: SelectTab(
                value: page,
                controller: pageController,
                onChange: (value) {
                  page = value;
                  setState(() {});
                  pageController.animateToPage(
                    page,
                    duration: const Duration(
                      milliseconds: 200,
                    ),
                    curve: Curves.ease,
                  );
                },
              ),
            ),
            SizedBox(height: 8.w),
            Expanded(
              child: PageView(
                controller: pageController,
                children: [
                  FMView(mode: FMMode.selectFile),
                  AppSelect(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.w),
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {
                          Get.back(result: false);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 120,
                          height: 48,
                          child: Center(
                            child: Text(
                              '取消',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 60),
                    Material(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () {
                          Get.back(result: true);
                        },
                        child: SizedBox(
                          width: 120,
                          height: 48,
                          child: Center(
                            child: Text(
                              '确认',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }
}

final List<String> tabs = [
  '文件选择',
  '应用选择',
];

class SelectTab extends StatefulWidget {
  const SelectTab({
    super.key,
    this.value,
    this.onChange,
    this.controller,
  });
  final int? value;
  final void Function(int value)? onChange;
  final PageController? controller;

  @override
  State createState() => _SelectTabState();
}

class _SelectTabState extends State<SelectTab> {
  int? _value;
  @override
  void initState() {
    super.initState();
    _value = widget.value;
    widget.controller!.addListener(() {
      if (widget.controller!.page!.round() != _value) {
        _value = widget.controller!.page!.round();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Color accent = colorScheme.primary;

    List<Widget> children = [];
    for (int i = 0; i < tabs.length; i++) {
      bool isCheck = _value == i;
      children.add(
        GestureDetector(
          onTap: () {
            widget.onChange!(i);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isCheck ? accent : accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            margin: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: Text(
              tabs[i],
              style: TextStyle(
                color: isCheck ? colorScheme.onPrimary : accent,
                fontSize: 16.w,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: children,
      ),
    );
  }
}
