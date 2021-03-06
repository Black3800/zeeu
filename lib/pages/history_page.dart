import 'package:ZeeU/models/app_user.dart';
import 'package:ZeeU/models/appointment.dart';
import 'package:ZeeU/models/user_state.dart';
import 'package:ZeeU/services/api_socket.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/home/appointment_card.dart';
import 'package:ZeeU/widgets/home/appointment_divider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key, required this.notifyRouteChange}) : super(key: key);

  final Function(String, String) notifyRouteChange;

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserState, ApiSocket>(
        builder: (context, user, api, child) => WillPopScope(
              onWillPop: () async {
                notifyRouteChange('pop', '/history');
                return true;
              },
              child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    elevation: 0,
                    title: Text(
                      'History',
                      style: GoogleFonts.roboto(
                          color: Palette.jet,
                          fontSize: 18,
                          fontWeight: FontWeight.w800),
                    ),
                    centerTitle: true,
                    backgroundColor: Palette.white,
                    foregroundColor: Palette.jet,
                  ),
                  body: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: FutureBuilder<List<Appointment>>(
                            future: api.appointments.once,
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
                                if (a.start.isBefore(DateTime.now())) {
                                  final date = DateFormat('yMMMMd').format(a.start);
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
                            })),
                  )),
            ));
  }
}
