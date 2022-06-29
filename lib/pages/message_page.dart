import 'package:ZeeU/models/app_user.dart';
import 'package:ZeeU/models/chat.dart';
import 'package:ZeeU/models/message.dart';
import 'package:ZeeU/models/user_state.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/chats/message_bar.dart';
import 'package:ZeeU/widgets/chats/message_bubble.dart';
import 'package:ZeeU/widgets/cloud_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'search_page.dart';

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

class MessagePage extends StatefulWidget {
  const MessagePage(
      {Key? key, required this.chat, required this.notifyRouteChange})
      : super(key: key);

  final Chat chat;
  final Function(String, String) notifyRouteChange;

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final userRef = FirebaseFirestore.instance
      .collection('users')
      .withConverter<AppUser>(
          fromFirestore: (snapshots, _) =>
              AppUser.fromJson(snapshots.data()!, uid: snapshots.reference.id),
          toFirestore: (user, _) => user.toJson());
  final controller = TextEditingController();
  late CollectionReference<Message> messageRef;

  Future<void> _showInfo(AppUser doctor) async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: Column(children: [
                  const Text('Institute:'),
                  Text(doctor.institute!),
                  const Text('Contact:'),
                  Text(doctor.contact!),
                  const Text('Short bio:'),
                  Text(doctor.bio ?? '-')
                ]),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'))
              ],
            ));
  }

  Future<void> _sendText({required String text, required String sendAs}) async {
    if (text.isEmpty) return;
    final msgTime = DateTime.now();
    await messageRef.add(Message(
        isFromDoctor: sendAs == 'doctor',
        type: 'text',
        content: text,
        time: msgTime));
    _updateLatestMessage(text: text, time: msgTime);
  }

  Future<void> _sendImage(
      {required String path, required String sendAs}) async {
    if (path.isEmpty) return;
    final msgTime = DateTime.now();
    await messageRef.add(Message(
        isFromDoctor: sendAs == 'doctor',
        type: 'image',
        content: path,
        time: msgTime));
    _updateLatestMessage(text: 'Photo', time: msgTime);
  }

  Future<void> _makeAppointment(
      {required DateTime start,
      required DateTime end,
      required String doctorUid,
      required String patientUid}) async {
    final msgTime = DateTime.now();
    final appointment =
        await FirebaseFirestore.instance.collection('appointments').add({
      'doctor': doctorUid,
      'patient': patientUid,
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end)
    });
    await messageRef.add(Message(
        isFromDoctor: true,
        type: 'appointment',
        content: appointment.id,
        time: msgTime));
    _updateLatestMessage(
        text: "Appointment on ${DateFormat('yMMMd').add_Hm().format(start)}",
        time: msgTime);
  }

  void _updateLatestMessage({required String text, required DateTime time}) {
    FirebaseFirestore.instance.collection('chats').doc(widget.chat.id).update({
      'latest_message_text': text,
      'latest_message_time': Timestamp.fromDate(time),
      'latest_message_seen_doctor': false,
      'latest_message_seen_patient': false
    });
  }

  void _seenLatestMessage(String userType) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chat.id)
        .update({'latest_message_seen_$userType': true});
  }

  @override
  void initState() {
    super.initState();
    messageRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chat.id)
        .collection('messages')
        .withConverter<Message>(
            fromFirestore: (snapshots, _) =>
                Message.fromJson(snapshots.data()!),
            toFirestore: (msg, _) => msg.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserState>(
        builder: (context, user, child) => WillPopScope(
              onWillPop: () async {
                widget.notifyRouteChange('pop', '/messages');
                return true;
              },
              child: SafeArea(
                child: Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                        backgroundColor: Colors.white,
                        foregroundColor: Palette.jet,
                        elevation: 0),
                    body: Column(
                      children: [
                        StreamBuilder<DocumentSnapshot<AppUser>>(
                          stream: userRef
                              .doc(user.userType == 'patient'
                                  ? widget.chat.doctor.uid
                                  : widget.chat.patient.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(snapshot.error.toString()),
                              );
                            }

                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final data = snapshot.requireData.data()!;

                            return Stack(
                              children: [
                                ClipPath(
                                  clipper: GreenClipper(),
                                  child: Container(
                                    color: Palette.honeydew,
                                    height: 115,
                                  ),
                                ),
                                ClipPath(
                                  clipper: WhiteClipper(),
                                  child: Container(
                                    color: Palette.white,
                                    height: 110,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 0,
                                          right: 20,
                                          left: 20,
                                          bottom: 20),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Color.fromRGBO(
                                                        53, 53, 53, 0.25),
                                                    offset: Offset(1, 2),
                                                    blurRadius: 10)
                                              ],
                                            ),
                                            child: CloudImage(
                                                radius: 65,
                                                image: data.img!,
                                                readOnly: true),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${data.firstName} ${data.lastName}',
                                                  style: GoogleFonts.roboto(
                                                      color: Palette.jet,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => _showInfo(data),
                                            icon: const Icon(
                                                Icons.more_vert_outlined,
                                                size: 24),
                                            iconSize: 24,
                                            color: Palette.gray.shade300,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        Expanded(
                            child: StreamBuilder<QuerySnapshot<Message>>(
                          stream: messageRef.orderBy('time').snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(snapshot.error.toString()),
                              );
                            }

                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final data = snapshot.requireData.docs;
                            final messages = [];
                            for (final m in data) {
                              messages.add(m.data());
                            }

                            if (messages.isEmpty) {
                              return const Center(child: Text('Empty'));
                            }

                            return ListView.builder(
                              itemBuilder: (context, index) => MessageBubble(
                                  content: messages[index].content,
                                  type: messages[index].type,
                                  time: DateFormat('Hm')
                                      .format(messages[index].time),
                                  align: messages[index].isFromDoctor
                                      ? user.userType == 'doctor'
                                          ? 'right'
                                          : 'left'
                                      : user.userType == 'patient'
                                          ? 'right'
                                          : 'left',
                                  onFirstBuild: index + 1 == messages.length
                                      ? () => _seenLatestMessage(user.userType!)
                                      : null),
                              itemCount: messages.length,
                            );
                          },
                        )),
                        MessageBar(
                          textController: controller,
                          onSubmitText: () {
                            FocusScope.of(context).unfocus();
                            _sendText(
                                text: controller.text, sendAs: user.userType!);
                          },
                          onSubmitImage: (path) =>
                              _sendImage(path: path, sendAs: user.userType!),
                          onSubmitAppointment: user.userType == 'doctor'
                              ? (start, end) => _makeAppointment(
                                  start: start,
                                  end: end,
                                  doctorUid: user.uid!,
                                  patientUid: widget.chat.patient.uid!)
                              : null,
                        )
                      ],
                    )),
              ),
            ));
  }

  Widget disc(bool active) => Container(
        width: 13,
        height: 13,
        decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                  color: Color.fromRGBO(53, 53, 53, 0.25),
                  offset: Offset(1, 2),
                  blurRadius: 10)
            ],
            shape: BoxShape.circle,
            color: active ? Palette.aquamarine : Palette.gray),
      );
}
  // Row(
    //   children: [
    //     disc(data.active!),
    //     const SizedBox(
    //       width: 7,
    //     ),
    //     Text(
    //       data.active!
    //           ? 'Active now'
    //           : 'Offline',
    //       style: GoogleFonts.roboto(
    //           color: Palette
    //               .gray.shade400,
    //           fontSize: 14,
    //           fontWeight:
    //               FontWeight.w400),
    //     )
    //   ],
    // ),