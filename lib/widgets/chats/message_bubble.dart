import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/cloud_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble({
    Key? key,
    required this.content,
    required this.type,
    required this.time,
    required this.align,
    this.onFirstBuild
  }) : super(key: key);

  final String content;
  final String type;
  final String time;
  final String align;
  final Function()? onFirstBuild;

  final _bubbleBuilder = {
    'text': (text) => Text(text),
    'image': (path) => FutureBuilder<String>(
      future: FirebaseStorage.instance.refFromURL(path).getDownloadURL(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data;
        return Image(
          image: NetworkImage(data!)
        );
      }
    )
  };

  bool didMounted = false;

  @override
  Widget build(BuildContext context) {
    if (!didMounted) {
      onFirstBuild?.call();
      didMounted = true;
    }
    return Row(
      mainAxisAlignment: align == 'left' ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.5
            ),
            color: align == 'left' ? Palette.white : Palette.aquamarine,
            child: _bubbleBuilder[type]!(content)
          ),
        )
      ]
    );
  }
}