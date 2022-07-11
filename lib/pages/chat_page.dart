import 'package:ZeeU/models/app_user.dart';
import 'package:ZeeU/models/chat.dart';
import 'package:ZeeU/models/user_state.dart';
import 'package:ZeeU/services/api_socket.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/chats/chat_card.dart';
import 'package:ZeeU/widgets/chats/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.notifyRouteChange}) : super(key: key);

  final Function(String, String) notifyRouteChange;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String searchString = '';

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserState, ApiSocket>(
        builder: (context, user, api, child) => Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                'Chats',
                style: GoogleFonts.roboto(
                    color: Palette.jet,
                    fontSize: 18,
                    fontWeight: FontWeight.w800),
              ),
              backgroundColor: Palette.white,
              foregroundColor: Palette.jet,
              leading: const Icon(
                Icons.chat_bubble,
                color: Palette.aquamarine,
              ),
              elevation: 0,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SearchBar(
                      onSubmit: (value) =>
                          setState(() => searchString = value)),
                  if (user.uid != null)
                    StreamBuilder<List<Chat>>(
                        stream: api.chats.stream,
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

                          final chats = snapshot.requireData;
                          chats.sort((a, b) => b.latestMessageTime.compareTo(a.latestMessageTime));
                          final cards = chats
                              .map<Widget>((c) => FutureBuilder<AppUser>(
                                  future: api.users
                                      .withUid(user.userType == 'patient'
                                          ? c.doctor.uid
                                          : c.patient.uid)
                                      .once,
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
                                    
                                    final chatUser = snapshot.requireData;
                                    final chatName =
                                        '${chatUser.firstName} ${chatUser.lastName}';

                                    if (c.latestMessageText
                                            .toLowerCase()
                                            .contains(
                                                searchString.toLowerCase()) ||
                                        chatName.toLowerCase().contains(
                                            searchString.toLowerCase())) {
                                      return ChatCard(
                                        image: chatUser.img!,
                                        name: chatName,
                                        text: c.latestMessageText,
                                        time: _formatChatTime(
                                            c.latestMessageTime),
                                        seen: user.userType == 'doctor'
                                            ? c.latestMessageSeenDoctor
                                            : c.latestMessageSeenPatient,
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                              '/messages',
                                              arguments: c);
                                          widget.notifyRouteChange(
                                              'push', '/messages');
                                        },
                                      );
                                    }
                                    return Container();
                                  }))
                              .toList();

                          if (cards.isEmpty) {
                            return const Center(child: Text('Empty'));
                          }

                          return Column(children: cards);
                        }),
                ],
              ),
            )));
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
