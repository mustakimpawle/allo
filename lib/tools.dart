import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class Tools {
  static ImagePicker imagePicker = ImagePicker();
  static Future<void> shareImage(String url) async {
    try {
      // var request = await HttpClient().getUrl(Uri.parse(url));
      // var response = await request.close();
      // Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      // final tempDir = await getTemporaryDirectory();
      // final file =
      //     await new File('${tempDir.path}/${product.name}.png').create();
      // file.writeAsBytesSync(bytes);
      // await Share.shareFiles([file.path],
      //     mimeTypes: [mime(file.path)],
      //     subject: 'MandiApp'.tr,
      //     text: 'ProductName'.tr +
      //         ': ' +
      //         product.name +
      //         '\n' +
      //         'shortDescription'.tr +
      //         ': ' +
      //         product.shortDescription);
    } catch (e) {}
  }

  static Future<File?> chooseOptionPopup(BuildContext context,
      {bool showFileOption = true}) async {
    File? file;
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          'Choose Options',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        message: Text(
          'You can select either Camera or Gallery',
          style: TextStyle(),
        ),
        actions: <Widget>[
          showFileOption
              ? CupertinoActionSheetAction(
                  child: Text('File'),
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    file = await getFile();
                    Navigator.of(context).pop();
                  },
                )
              : Offstage(),
          CupertinoActionSheetAction(
            child: Text('Gallery'),
            onPressed: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              file = await getImage(imageSource: ImageSource.gallery);
              Navigator.of(context).pop();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Camera'),
            onPressed: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              file = await getImage(imageSource: ImageSource.camera);
              Navigator.of(context).pop();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
    return file;
  }

  static Future<File?> getImage({ImageSource? imageSource}) async {
    XFile? image = await imagePicker.pickImage(
      source: imageSource!,
      imageQuality: 70,
    );
    if (image!.path.isNotEmpty) {
      return await cropImage(image.path);
    }
    return null;
  }

  static Future<File?> cropImage(String path) async {
    File? croppedImage = await ImageCropper.cropImage(
      sourcePath: path,
      // aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      // aspectRatioPresets: [CropAspectRatioPreset.square],
      cropStyle: CropStyle.rectangle,
      // compressQuality: 70,
    );
    // File croppedImage = await Get.to(() => Cropper(imageFile: File(path)));
    if (croppedImage!.path.isNotEmpty) {
      return croppedImage;
    }
    return null;
  }

  static Future<File?> getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowCompression: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpeg', 'jpg'],
    );
    if (result != null) {
      return await cropImage(result.files.single.path!);
    }
    return null;
  }
}
