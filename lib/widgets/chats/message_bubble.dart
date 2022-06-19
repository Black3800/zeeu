import 'package:ZeeU/models/appointment.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/cloud_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    ),
    'appointment': (id) => FutureBuilder<DocumentSnapshot<Appointment>>(
      future: FirebaseFirestore.instance
                .collection('appointments')
                .withConverter<Appointment>(
                    fromFirestore: (snapshots, _) => Appointment.fromJson(snapshots.data()!),
                    toFirestore: (appointment, _) => appointment.toJson())
                .doc(id)
                .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.requireData.data()!;
        return Text(
          "Appointment on ${DateFormat('yMMMd').add_Hm().format(data.start)}",
          style: const TextStyle(fontStyle: FontStyle.italic),
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