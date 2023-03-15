import 'package:file/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart' as c;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class NoCachedImageManager extends c.CacheManager {
  NoCachedImageManager() : super(c.Config('NoCachedImageManager'));

  // // @override
  // // Future<String> getFilePath() async {
  // //   var directory = await getTemporaryDirectory();
  // //   return p.join(directory.path, 'NoCachedImageManager');
  // // }

  // @override
  // Future<File> getSingleFile(
  //   String url, {
  //   String? key,
  //   Map<String, String>? headers,
  // }) async {
  //   return (await downloadFile(url, authHeaders: headers)).file;
  // }
}
