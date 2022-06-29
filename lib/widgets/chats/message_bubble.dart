import 'package:ZeeU/models/appointment.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/cloud_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {Key? key,
      required this.content,
      required this.type,
      required this.time,
      required this.align,
      this.onFirstBuild})
      : super(key: key);

  final String content;
  final String type;
  final String time;
  final String align;
  final Function()? onFirstBuild;

  final _bubbleBuilder = {
    'text': (text) => Text(
          text,
          style: GoogleFonts.roboto(
              color: Palette.jet, fontSize: 16, fontWeight: FontWeight.w400),
        ),
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
          return Image(image: NetworkImage(data!));
        }),
    'appointment': (id) => FutureBuilder<DocumentSnapshot<Appointment>>(
        future: FirebaseFirestore.instance
            .collection('appointments')
            .withConverter<Appointment>(
                fromFirestore: (snapshots, _) =>
                    Appointment.fromJson(snapshots.data()!),
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
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 13),
            child: Text(
              "Appointment on ${DateFormat('yMMMd').add_Hm().format(data.start)}",
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 16,
              ),
            ),
          );
        })
  };

  bool didMounted = false;

  @override
  Widget build(BuildContext context) {
    if (!didMounted) {
      onFirstBuild?.call();
      didMounted = true;
    }
    return Row(
        mainAxisAlignment:
            align == 'left' ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Container(
                padding: type == 'text'
                    ? const EdgeInsets.symmetric(vertical: 8, horizontal: 13)
                    : null,
                decoration: BoxDecoration(
                  color: align == 'left'
                      ? Palette.white.withOpacity(0.5)
                      : Palette.aquamarine,
                  borderRadius: align == 'left'
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(0),
                        ),
                  boxShadow: [
                    BoxShadow(
                        color: align != 'left' && type != 'image'
                            ? const Color.fromRGBO(130, 245, 195, 0.3)
                            : const Color.fromRGBO(53, 53, 53, 0.05),
                        offset: align == 'left'
                            ? const Offset(2, 3)
                            : const Offset(-2, 3),
                        blurRadius: 5)
                  ],
                ),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.5),
                child: _bubbleBuilder[type]!(content)),
          )
        ]);
  }
}
