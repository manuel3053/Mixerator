// RICONVERTIRE PER IL SALVATAGGIO DEL PROGETTO
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class TrackRepository {
  // Getter for the ApplicationDocumentsDirectory
  static Future<Directory> get _storageDirectory async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  // Returns the path of the storage directory
  static Future<String> get storagePath async {
    final dir = await _storageDirectory;
    return "${dir.path}/notes";
  }

  // Returns a Future of all the contents in storagePath
  static Future<List<FileSystemEntity>> get allNotes async {
    final path = await storagePath; // Acquire path
    final dir =
        await Directory(path).create(); // Create directory if it doesn't exist
    final fileList =
        await dir
            .list()
            .toList(); // Put the contents of the directory in a List
    return fileList;
  }
}
