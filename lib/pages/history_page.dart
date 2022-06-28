import 'package:ZeeU/models/app_user.dart';
import 'package:ZeeU/models/appointment.dart';
import 'package:ZeeU/models/user_state.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/home/appointment_card.dart';
import 'package:ZeeU/widgets/home/appointment_divider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatelessWidget {
  HistoryPage({Key? key, required this.notifyRouteChange}) : super(key: key);

  final Function(String, String) notifyRouteChange;
  final appointmentRef = FirebaseFirestore.instance
      .collection('appointments')
      .withConverter<Appointment>(
          fromFirestore: (snapshots, _) =>
              Appointment.fromJson(snapshots.data()!),
          toFirestore: (appointment, _) => appointment.toJson());

  @override
  Widget build(BuildContext context) {
    return Consumer<UserState>(
        builder: (context, user, child) => WillPopScope(
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
                        child: FutureBuilder<QuerySnapshot<Appointment>>(
                            future: appointmentRef
                                .where(user.userType!, isEqualTo: user.uid)
                                .where('start', isLessThan: Timestamp.now())
                                .orderBy('start')
                                .get(),
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

                              final docs =
                                  snapshot.requireData.docs.reversed.toList();
                              final appointments = [];
                              var previousAppointmentDate = '';
                              for (var i = 0; i < docs.length; i++) {
                                final a = docs[i].data();
                                final date =
                                    DateFormat('yMMMMd').format(a.start);
                                if (date != previousAppointmentDate) {
                                  appointments
                                      .add(AppointmentDivider(text: date));
                                }
                                appointments.add(a);
                                previousAppointmentDate = date;
                              }

                              if (appointments.isEmpty) {
                                return const Center(child: Text('Nothing'));
                              }

                              return Column(
                                  children: appointments
                                      .map<Widget>((a) => a
                                              is AppointmentDivider
                                          ? a
                                          : FutureBuilder<DocumentSnapshot>(
                                              future: FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(
                                                      user.userType == 'patient'
                                                          ? a.doctor.uid
                                                          : a.patient.uid)
                                                  .get(),
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

                                                final data =
                                                    snapshot.requireData.data()
                                                        as Map;
                                                final user =
                                                    AppUser.fromJson(data);
                                                return AppointmentCard(
                                                    image: user.img!,
                                                    name:
                                                        '${user.firstName} ${user.lastName}',
                                                    institute: user.institute ??
                                                        'Patient');
                                              }))
                                      .toList());
                            })),
                  )),
            ));
  }
}
