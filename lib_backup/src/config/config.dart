import 'global.dart';

// 要改，获取路径的唯一变量是包名，根据平台返回路径
class Config {
  Config._();
  static String baseURL =
      inProduction ? 'http://nightmare.fun:9000' : 'http://nightmare.fun:9000';
  static String apiKey = 'Y29tLm5pZ2h0bWFyZQ==';
  static String basicAuth =
      'Basic Y29tLm5pZ2h0bWFyZS50ZXJtYXJlOmNvbS5uaWdodG1hcmU=';
  static String dataBasePath = '$dataPath/databases';
  static String dbPath = '$dataPath/databases/user.db';
  static String binPath = '$usrPath/bin';
  static String filesPath = '$dataPath/files';
  static String initFilePath = '$dataPath/files/init';
  static String usrPath = '$dataPath/files/usr';
  static String homePath = '$dataPath/files/home';
  static String tmpPath = '$usrPath/tmp';
  static String busyboxPath = '$binPath/busybox';
  static String bashPath = '$binPath/bash';
  static const String appName = 'YanTool';
  static String dataPath = '/data/data/$packageName';

  /// debug开关，上线需要关闭
  /// App运行在Release环境时，inProduction为true；当App运行在Debug和Profile环境时，inProduction为false
  static const bool inProduction = bool.fromEnvironment('dart.vm.product');

  static const String packageName = 'com.nightmare.file_manager_example';

  static String aaptPath = '$dataPath/aapt';
  static String frameworkPath = dataPath + '/Framework';
}
