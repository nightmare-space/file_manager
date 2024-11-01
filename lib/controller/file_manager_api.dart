import 'package:dio/dio.dart';
import 'package:global_repository/global_repository.dart';

class FileManagerAPI {
  String baseUrl;
  FileManagerAPI(this.baseUrl);

  Future<List> getDirInfos(String path) async {
    Dio dio = Dio();
    Map<String, dynamic> params = {
      'path': path,
    };
    params['action'] = 'dir';
    Response response = await dio.get(baseUrl, queryParameters: params);
    return response.data;
  }

  Future<String> getHomePath() async {
    Dio dio = Dio();
    Map<String, dynamic> params = {};
    params['action'] = 'get_home_path';
    Response<Map<String, dynamic>> response = await dio.get(baseUrl, queryParameters: params);
    Log.w('response.data ${response.data}');
    return response.data!['path'];
  }

  String getFileUrl(String path) {
    return '$baseUrl?action=file&path=$path';
  }
}
