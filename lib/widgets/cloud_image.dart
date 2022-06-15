import 'dart:io';
import 'dart:typed_data';

import 'package:ZeeU/utils/constants.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/utils/upload.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';

class CloudImage extends StatefulWidget {
  final String image;
  final String folder;
  final String? notDeleteable;
  final double radius;
  final Function(String)? onChanged;
  final bool readOnly;
  final bool showLoadingStatus;
  final bool showBorder;
  const CloudImage(
      {Key? key,
      required this.image,
      this.folder = 'uploads',
      this.notDeleteable,
      this.onChanged,
      this.radius = 120.0,
      this.readOnly = false,
      this.showLoadingStatus = true,
      this.showBorder = false})
      : super(key: key);

  @override
  State<CloudImage> createState() => _CloudImageState();
}

class _CloudImageState extends State<CloudImage> {
  late Future<String?> imageURL;

  Future<String?> _getImageURL() async {
    return Future.value(await FirebaseStorage.instance
        .refFromURL(widget.image)
        .getDownloadURL());
  }

  Future<void> _deletePreviousImage(String? previousImage) async {
    /***
     * Delete previousImage if not in /dummy folder
     */
    print('deleting $previousImage');
    if (widget.readOnly || previousImage == widget.notDeleteable) return;
    if (previousImage != null && previousImage.split('/')[3] != 'dummy') {
      FirebaseStorage.instance.refFromURL(previousImage).delete();
    }
  }

  @override
  void initState() {
    super.initState();
    imageURL = _getImageURL();
  }

  @override
  void didUpdateWidget(covariant CloudImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image.isNotEmpty && widget.image != oldWidget.image) {
      _deletePreviousImage(oldWidget.image);
    }
    imageURL = _getImageURL();
  }

  @override
  void deactivate() {
    widget.onChanged?.call('');
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    double position =
        widget.radius * 0.70710678118; // equals radius * sin(pi/4)
    double size = position + widget.radius / 3;

    return SizedBox(
      width: size,
      height: size,
      child: FutureBuilder(
          future: imageURL,
          builder: (context, snapshot) {
            final bool isLoaded = snapshot.hasData;
            final String? imageURL = snapshot.data as String?;
            return Stack(children: [
              CircleAvatar(
                radius: widget.radius,
                backgroundColor: Palette.jet.shade50,
                child: CircleAvatar(
                    backgroundImage:
                        isLoaded ? NetworkImage('$imageURL') : null,
                    child: isLoaded || !widget.showLoadingStatus
                        ? null
                        : const CircularProgressIndicator(),
                    backgroundColor: Palette.jet.shade50,
                    radius: widget.radius - 2),
              ),
              widget.readOnly
                  ? Container()
                  : Positioned(
                      top: position,
                      left: position,
                      child: Container(
                          height: widget.radius / 3,
                          width: widget.radius / 3,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Palette.aquamarine,
                          ),
                          child: Center(
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt),
                              iconSize: widget.radius / 6,
                              onPressed: () => Upload.pickImage(
                                folder: widget.folder,
                                onSuccess: widget.onChanged
                              ),
                              color: Palette.white,
                            ),
                          ))),
            ]);
          }),
    );
  }
}
