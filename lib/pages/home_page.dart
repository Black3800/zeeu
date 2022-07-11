import 'dart:async';

import 'package:ZeeU/models/app_user.dart';
import 'package:ZeeU/models/appointment.dart';
import 'package:ZeeU/models/user_state.dart';
import 'package:ZeeU/services/api_socket.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/utils/tab_item.dart';
import 'package:ZeeU/widgets/home/appointment_card.dart';
import 'package:ZeeU/widgets/home/appointment_divider.dart';
import 'package:ZeeU/widgets/home/hero_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.changeTab}) : super(key: key);

  final Function(TabItem) changeTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    Provider.of<ApiSocket>(context, listen: false).ensureSubscribed();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserState, ApiSocket>(
        builder: (context, user, api, child) {
          if (user.firstName == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Welcome back\n${user.firstName}! 😄',
                            style: GoogleFonts.roboto(
                                color: Palette.jet,
                                fontSize: 32,
                                fontWeight: FontWeight.w900)),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      HeroCard(
                          text: user.userType == 'patient'
                              ? 'How are you feeling today?'
                              : 'Thanks for your hard work!',
                          buttonText: user.userType == 'patient'
                              ? 'Consult now'
                              : 'See patients',
                          onPressed: () => widget.changeTab(TabItem.chats),
                          image: const AssetImage('assets/Heart.png')),
                      const SizedBox(
                        height: 25,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Upcoming',
                            style: Theme.of(context)
                                .textTheme
                                .headline2
                                ?.apply(color: Palette.jet)),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      if (user.uid != null)
                        StreamBuilder<List<Appointment>>(
                            stream: api.appointments.stream,
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

                              final docs = snapshot.requireData;
                              final appointments = [];
                              var previousAppointmentDate = '';
                              for (var i = 0; i < docs.length; i++) {
                                final a = docs[i];
                                if (a.start.isAfter(DateTime.now())) {
                                  final date = _formatAppointmentDate(a.start);
                                  if (date != previousAppointmentDate) {
                                    appointments.add(AppointmentDivider(text: date));
                                  }
                                  appointments.add(a);
                                  previousAppointmentDate = date;
                                }
                              }

                              if (appointments.isEmpty) {
                                return const Center(child: Text('Nothing'));
                              }

                              return Column(
                                  children: appointments
                                      .map<Widget>((a) => a
                                              is AppointmentDivider
                                          ? a
                                          : FutureBuilder<AppUser>(
                                              future: api.users
                                                .withUid(
                                                    user.userType == 'patient'
                                                        ? a.doctor.uid
                                                        : a.patient.uid)
                                                .once,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasError) {
                                                  return Center(
                                                    child: Text(snapshot.error
                                                        .toString()),
                                                  );
                                                }

                                                if (!snapshot.hasData) {
                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator());
                                                }

                                                final user = snapshot.requireData;
                                                return AppointmentCard(
                                                    image: user.img!,
                                                    name:
                                                        '${user.firstName} ${user.lastName}',
                                                    institute: user.institute ??
                                                        'Patient',
                                                    startTime: DateFormat('Hm')
                                                        .format(a.start),
                                                    endTime: DateFormat('Hm')
                                                        .format(a.end));
                                              }))
                                      .toList());
                            }),
                      const SizedBox(height: 50)
                    ],
                  )),
            )
          );
        }
    );
  }

  String _formatAppointmentDate(DateTime date) {
    final now = DateTime.now();
    if (date.subtract(const Duration(days: 1)).isSameDate(now)) {
      return 'Tomorrow';
    } else if (date.difference(now).inDays < 6) {
      return DateFormat('EEEE').format(date);
    } else if (date.year == now.year) {
      return DateFormat('MMMMd').format(date);
    }
    return DateFormat('yMMMMd').format(date);
  }
}
