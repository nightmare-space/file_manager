import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:global_repository/global_repository.dart';
import 'view/file_manager_view.dart';
import 'server/file_server.dart';

Future<void> main() async {
  RuntimeEnvir.initEnvirWithPackageName('com.nightmare.file_manager');
  await Server.start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      defaultTransition: Transition.native,
      home: const FMView(),
    );
  }
}

String formatBytes(int bytes) {
  if (bytes <= 0) return "0B";
  const List<String> sizes = ["B", "K", "M", "G"];
  int i = 0;
  double size = bytes.toDouble();

  while (size >= 1024 && i < sizes.length - 1) {
    size /= 1024;
    i++;
  }

  return "${size.toStringAsFixed(2)}${sizes[i]}";
}
