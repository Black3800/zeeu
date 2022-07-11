import 'package:ZeeU/models/appointment.dart';
import 'package:ZeeU/services/api_socket.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble(
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

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  _bubbleBuilder(type, value) {
    if (type == 'text') {
      return Text(
          value,
          style: GoogleFonts.roboto(
              color: Palette.jet, fontSize: 16, fontWeight: FontWeight.w400),
        );
    } else if (type == 'image') {
      return FutureBuilder<String>(
        future: FirebaseStorage.instance.refFromURL(value).getDownloadURL(),
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
        });
    } else if (type == 'appointment') {
      return Consumer<ApiSocket>(
        builder: (context, api, child) =>
          FutureBuilder<Appointment>(
            future: api.appointments.withId(value),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.requireData;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 13),
                child: Column(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: Palette.ultramarine),
                    Text(
                      "Appointment on ${DateFormat('yMMMd').add_Hm().format(data.start)}",
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            })
      );
    }
  }

  bool didMounted = false;

  @override
  Widget build(BuildContext context) {
    if (!didMounted) {
      WidgetsBinding.instance?.addPostFrameCallback((_) => widget.onFirstBuild?.call());
      didMounted = true;
    }
    return Row(
        mainAxisAlignment:
            widget.align == 'left' ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Container(
                padding: widget.type == 'text'
                    ? const EdgeInsets.symmetric(vertical: 8, horizontal: 13)
                    : null,
                decoration: BoxDecoration(
                  color: widget.align == 'left'
                      ? Palette.white.withOpacity(0.5)
                      : Palette.aquamarine,
                  borderRadius: widget.align == 'left'
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
                        color: widget.align != 'left' && widget.type != 'image'
                            ? const Color.fromRGBO(130, 245, 195, 0.3)
                            : const Color.fromRGBO(53, 53, 53, 0.05),
                        offset: widget.align == 'left'
                            ? const Offset(2, 3)
                            : const Offset(-2, 3),
                        blurRadius: 5)
                  ],
                ),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.5),
                child: _bubbleBuilder(widget.type, widget.content)),
          )
        ]);
  }
}
