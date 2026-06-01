import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<void> saveFileBytes(Uint8List bytes, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final imagePath = '${directory.path}/steganography/$fileName';
  final imageFile = File(imagePath);
  await imageFile.create(recursive: true);
  await imageFile.writeAsBytes(bytes);
}
