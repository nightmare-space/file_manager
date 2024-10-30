import 'dart:io';

void main() async {
  // 执行命令获取盘符
  ProcessResult result = await Process.run('wmic', ['logicaldisk', 'get', 'name']);

  // 解析结果
  if (result.exitCode == 0) {
    // 按行分割输出
    List<String> lines = result.stdout.split('\n');
    // 去掉第一行标题和空行
    List<String> drives = lines.skip(1).where((line) => line.trim().isNotEmpty).toList();
    print('当前系统中的盘符有:');
    for (var drive in drives) {
      print(drive.trim());
    }
  } else {
    print('获取盘符失败: ${result.stderr}');
  }
}
