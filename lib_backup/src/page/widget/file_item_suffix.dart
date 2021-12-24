import 'package:file_manager/src/dialog/apktool_dialog.dart';
import 'package:file_manager/src/dialog/apktool_encode_dialog.dart';
import 'package:file_manager/src/io/src/directory.dart';
import 'package:file_manager/src/io/src/file.dart';
import 'package:file_manager/src/io/src/file_entity.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

import '../../io/src/directory.dart';
import '../../io/src/file.dart';

class FileItemSuffix extends StatelessWidget {
  const FileItemSuffix({Key key, this.fileNode}) : super(key: key);

  final FileEntity fileNode;

  @override
  Widget build(BuildContext context) {
    if (fileNode.nodeName.endsWith('_src') && fileNode.isDirectory)
      return Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          icon: const Icon(Icons.build),
          onPressed: () {
            showCustomDialog<void>(
              context: context,
              duration: const Duration(milliseconds: 200),
              child: ApktoolEncodeDialog(
                directory: fileNode as AbstractDirectory,
              ),
            );
          },
        ),
      );
    if (fileNode.nodeName.endsWith('apk'))
      return Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          icon: const Icon(Icons.build),
          onPressed: () {
            showCustomDialog<void>(
              context: context,
              duration: const Duration(milliseconds: 200),
              child: ApkToolDialog(
                fileNode: fileNode as AbstractNiFile,
              ),
            );
          },
        ),
      );
    return const SizedBox();
  }
}
