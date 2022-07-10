import 'package:ZeeU/models/app_user.dart';
import 'package:ZeeU/models/chat.dart';
import 'package:ZeeU/models/message.dart';
import 'package:ZeeU/models/user_state.dart';
import 'package:ZeeU/services/api_socket.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/chats/message_bar.dart';
import 'package:ZeeU/widgets/chats/message_bubble.dart';
import 'package:ZeeU/widgets/cloud_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
  final itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  late CollectionReference<Message> messageRef;
  late UserDocumentSocket interlocutor;

  Future<void> _showInfo(AppUser doctor) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Institute:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(doctor.institute!),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Contact:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(doctor.contact!),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Short bio:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          '${' ' * 4}${doctor.bio ?? '-'}',
                        )
                      ]),
                ),
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

  void _scrollDown(index) {
    itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 666),
      curve: Curves.easeInOutCubic);
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
    interlocutor = Provider.of<ApiSocket>(context, listen: false)
                      .users.withUid(
                        Provider.of<UserState>(context, listen: false)
                            .userType == 'patient'
                                ? widget.chat.doctor.uid
                                : widget.chat.patient.uid);
    interlocutor.subscribe();
  }

  @override
  void dispose() {
    interlocutor.unsubsribe();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserState, ApiSocket>(
        builder: (context, user, api, child) => WillPopScope(
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
                        StreamBuilder<AppUser>(
                          stream: interlocutor.stream,
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

                            final data = snapshot.requireData;

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
                                          bottom: 30),
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
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                                const SizedBox(height: 10),
                                                status(data.active ?? false)
                                              ],
                                            ),
                                          ),
                                          if (user.userType == 'patient') IconButton(
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

                            return ScrollablePositionedList.builder(
                              itemScrollController: itemScrollController,
                              itemPositionsListener: itemPositionsListener,
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
                                      ? () {
                                          _seenLatestMessage(user.userType!);
                                          _scrollDown(index);
                                        }
                                      : null),
                              itemCount: messages.length,
                            );
                          },
                        )),
                        MessageBar(
                          textController: controller,
                          onSubmitText: () async {
                            FocusScope.of(context).unfocus();
                            await _sendText(
                                text: controller.text, sendAs: user.userType!);
                            controller.clear();
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

  Widget disc(bool isGreen) => Container(
        width: 13,
        height: 13,
        decoration: BoxDecoration(
            boxShadow: isGreen
                ? const [
                    BoxShadow(
                        color: Palette.aquamarine,
                        offset: Offset(1, 2),
                        blurRadius: 10)
                  ]
                : [],
            shape: BoxShape.circle,
            color: isGreen ? Palette.aquamarine : Palette.gray),
      );

  Widget status(bool active) => Row(
                                  children: [
                                    disc(active),
                                    const SizedBox(width: 10),
                                    Text(active ? 'Online' : 'Offline',
                                        style: const TextStyle(color: Palette.gray, fontSize: 14))
                                  ]
                                );
}