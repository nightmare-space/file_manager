import 'package:file_manager/server/file_server.dart';

Future<void> main() async {
  int port = await Server.start();
}
