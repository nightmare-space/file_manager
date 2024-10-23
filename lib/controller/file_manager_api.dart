import 'package:dio/dio.dart';

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

  String getFileUrl(String path) {
    return '$baseUrl?action=file&path=$path';
  }
}
