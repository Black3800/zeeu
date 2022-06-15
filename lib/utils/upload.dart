import 'dart:io';
import 'dart:typed_data';

import 'package:ZeeU/utils/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';

class Upload {
  static Future<bool> image(Uint8List bytes, { String folder = 'uploads', Function(String)? onSuccess }) async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android) {
        bytes = await FlutterImageCompress.compressWithList(
          bytes,
          minHeight: 1920,
          minWidth: 1080,
        );
      }
      const uuid = Uuid();
      while (true) {
        String fileName = uuid.v1();
        String path = '${Constants.storageBucketBaseUrl}/$folder/$fileName';
        try {
          await FirebaseStorage.instance.refFromURL(path).getDownloadURL();
          debugPrint('duplicate filename exists, getting a new name...');
        } on FirebaseException catch (e) {
          if (e.code == 'object-not-found') {
            await FirebaseStorage.instance.refFromURL(path).putData(bytes);
            onSuccess?.call(path);
            break;
          }
        }
      }
    } on Exception catch (e) {
      return false;
    }
    return true;
  }

  static Future<void> pickImage({ String folder = 'uploads', Function(String)? onSuccess }) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      File file = File(result.files.single.path!);
      Uint8List fileBytes = await file.readAsBytes();
      await image(
        fileBytes,
        folder: folder,
        onSuccess: onSuccess
      );
    }
  }
}