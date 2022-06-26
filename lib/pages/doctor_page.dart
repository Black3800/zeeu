import 'package:ZeeU/models/app_user.dart';
import 'package:ZeeU/models/chat.dart';
import 'package:ZeeU/models/message.dart';
import 'package:ZeeU/models/user_state.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/utils/tab_item.dart';
import 'package:ZeeU/widgets/chats/message_bar.dart';
import 'package:ZeeU/widgets/chats/message_bubble.dart';
import 'package:ZeeU/widgets/cloud_image.dart';
import 'package:ZeeU/widgets/search/doctor_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage(
      {Key? key,
      required this.specialty,
      required this.notifyRouteChange,
      required this.changeTab})
      : super(key: key);

  final String specialty;
  final Function(String, String) notifyRouteChange;
  final Function(TabItem) changeTab;

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  final userRef = FirebaseFirestore.instance
      .collection('users')
      .withConverter<AppUser>(
          fromFirestore: (snapshots, _) => AppUser.fromJson(snapshots.data()!),
          toFirestore: (usr, _) => usr.toJson());

  Future<void> createChat(
      {required BuildContext ctx,
      required String doctorUid,
      required String patientUid}) async {
    final confirm = await showDialog<bool>(
        context: context,
        useRootNavigator: false,
        builder: (_) => AlertDialog(
                title: const Text('Consult with this doctor?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No')),
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Yes'))
                ]));

    if (!(confirm ?? true)) return;

    await FirebaseFirestore.instance.collection('chats').add({
      'doctor': doctorUid,
      'patient': patientUid,
      'latest_message_text': '',
      'latest_message_time': Timestamp.now(),
      'latest_message_seen_doctor': false,
      'latest_message_seen_patient': false
    });

    widget.changeTab(TabItem.chats);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserState>(
        builder: (context, user, child) => WillPopScope(
            onWillPop: () async {
              widget.notifyRouteChange('pop', '/doctors');
              return true;
            },
            child: SafeArea(
                child: Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                        backgroundColor: Palette.white,
                        foregroundColor: Palette.jet,
                        title: Text(
                          widget.specialty,
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w700,
                            color: Palette.jet,
                            fontSize: 18,
                          ),
                        ),
                        elevation: 0),
                    body: FutureBuilder<QuerySnapshot<AppUser>>(
                      future: userRef
                          .where('user_type', isEqualTo: 'doctor')
                          .where('specialty', isEqualTo: widget.specialty)
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

                        final data = snapshot.requireData.docs;
                        final doctors = data.map((e) {
                          final doc = e.data();
                          doc.uid = e.id;
                          return doc;
                        });

                        if (doctors.isEmpty) {
                          return const Center(child: Text('Empty'));
                        }

                        return Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Column(
                                children: doctors
                                    .map((e) => DoctorCard(
                                          image: e.img!,
                                          name: '${e.firstName} ${e.lastName}',
                                          specialty: e.specialty!,
                                          institute: e.institute!,
                                          contact: e.contact!,
                                          onTap: user.userType == 'patient'
                                              ? (ctx) => createChat(
                                                  ctx: ctx,
                                                  doctorUid: e.uid!,
                                                  patientUid: user.uid!)
                                              : null,
                                        ))
                                    .toList()),
                          ],
                        );
                      },
                    )))));
  }
}
