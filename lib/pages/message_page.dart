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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
          child: Column(
            children: [
              const Text('Institute:'),
              Text(doctor.institute!),
              const Text('Contact:'),
              Text(doctor.contact!),
              const Text('Short bio:'),
              Text(doctor.bio ?? '-')
            ]
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))
        ],
      )
    );
  }

  Future<void> _sendText({ required String text, required String sendAs }) async {
    if (text.isEmpty) return;
    final msgTime = DateTime.now();
    await messageRef.add(
      Message(
        isFromDoctor: sendAs == 'doctor',
        type: 'text',
        content: text,
        time: msgTime
      )
    );
    _updateLatestMessage(
      text: text,
      time: msgTime
    );
  }

  Future<void> _sendImage({ required String path, required String sendAs }) async {
    if (path.isEmpty) return;
    final msgTime = DateTime.now();
    await messageRef.add(
      Message(
        isFromDoctor: sendAs == 'doctor',
        type: 'image',
        content: path,
        time: msgTime
      )
    );
    _updateLatestMessage(
      text: 'Photo',
      time: msgTime
    );
  }

  void _updateLatestMessage({ required String text, required DateTime time }) {
    FirebaseFirestore.instance.collection('chats').doc(widget.chat.id).update({
      'latest_message_text': text,
      'latest_message_time': Timestamp.fromDate(time),
      'latest_message_seen_doctor': false,
      'latest_message_seen_patient': false
    });
  }

  void _seenLatestMessage(String userType) {
    FirebaseFirestore.instance.collection('chats').doc(widget.chat.id).update({
      'latest_message_seen_$userType': true
    });
  }

  @override
  void initState() {
    super.initState();
    messageRef = FirebaseFirestore.instance
      .collection('chats')
      .doc(widget.chat.id)
      .collection('messages')
      .withConverter<Message>(
          fromFirestore: (snapshots, _) => Message.fromJson(snapshots.data()!),
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
                        backgroundColor: Colors.transparent,
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

                            return Row(children: [
                              CloudImage(image: data.img!, readOnly: true),
                              Column(
                                children: [
                                  Text('${data.firstName} ${data.lastName}'),
                                  // Row(
                                  //   children: [
                                  //     disc(data.active!),
                                  //     Text(data.active! ? 'Active now' : 'Offline')
                                  //   ]
                                  // )
                                ],
                              ),
                              IconButton(
                                onPressed: () => _showInfo(data),
                                icon: const Icon(Icons.info_outline, size: 24),
                                iconSize: 24
                              )
                            ]);
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
                                return const Center(
                                  child: Text('Empty')
                                );
                              }

                              return ListView.builder(
                                itemBuilder: (context, index) => MessageBubble(
                                  content: messages[index].content,
                                  type: messages[index].type,
                                  time: DateFormat('Hm').format(messages[index].time),
                                  align: messages[index].isFromDoctor
                                      ? user.userType == 'doctor'
                                          ? 'right'
                                          : 'left'
                                      : user.userType == 'patient'
                                          ? 'right'
                                          : 'left',
                                  onFirstBuild: index + 1 == messages.length
                                      ? () => _seenLatestMessage(user.userType!)
                                      : null
                                ),
                                itemCount: messages.length,
                              );
                            },
                          )
                        ),
                        MessageBar(
                          textController: controller,
                          onSubmitText: () {
                            FocusScope.of(context).unfocus();
                            _sendText(
                              text: controller.text,
                              sendAs: user.userType!
                            );
                            controller.clear();
                          },
                          onSubmitImage: (path) => _sendImage(path: path, sendAs: user.userType!)
                        )
                      ],
                    )),
              ),
            ));
  }

  Widget disc(bool active) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? Palette.aquamarine : Palette.gray),
      );
}
