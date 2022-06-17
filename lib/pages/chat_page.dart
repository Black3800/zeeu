import 'package:ZeeU/models/app_user.dart';
import 'package:ZeeU/models/chat.dart';
import 'package:ZeeU/models/user_state.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/chats/chat_card.dart';
import 'package:ZeeU/widgets/chats/search_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  final chatRef = FirebaseFirestore.instance
      .collection('chats')
      .withConverter<Chat>(
        fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!, id: snapshots.reference.id),
        toFirestore: (chat, _) => chat.toJson()
      );

  @override
  Widget build(BuildContext context) {
    return Consumer<UserState>(builder: (context, user, child) =>
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Chats'),
          backgroundColor: Palette.white,
          foregroundColor: Palette.jet,
          leading: Icon(Icons.chat_bubble),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SearchBar(onSubmit: (value) {
                print(value);
              }),
              if (user.uid != null)
                StreamBuilder<QuerySnapshot<Chat>>(
                  stream: chatRef
                            .where(user.userType!, isEqualTo: user.uid)
                            .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.requireData.docs;
                    final chats = [];
                    for (final chat in docs) {
                      chats.add(chat.data());
                    }

                    return Column(
                      children: chats
                                  .map<Widget>((c) => FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.userType == 'patient'
                                                  ? c.doctor.uid
                                                  : c.patient.uid)
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

                                      final data = snapshot.requireData.data() as Map;
                                      final user = AppUser.fromJson(data);
                                      return ChatCard(
                                        image: user.img!,
                                        name: '${user.firstName} ${user.lastName}',
                                        text: c.latestMessageText,
                                        time: _formatChatTime(c.latestMessageTime),
                                        seen: c.latestMessageSeen,
                                        onTap: () => print('/chats/${c.id}'),
                                      );
                                    }
                                  ))
                                  .toList()
                    );
                  }
                ),
            ],
          ),
        )
      )
    );
  }

  String _formatChatTime(DateTime date) {
    final now = DateTime.now();
    if (date.isSameDate(now)) {
      return DateFormat('Hm').format(date);
    } else if (date.add(const Duration(days: 1)).isSameDate(now)) {
      return 'Yesterday';
    } else if (date.year == now.year) {
      return DateFormat('MMMd').format(date);
    }
    return DateFormat('yMd').format(date);
  }
}
