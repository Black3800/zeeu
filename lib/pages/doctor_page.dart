import 'package:ZeeU/models/app_user.dart';
import 'package:ZeeU/models/chat.dart';
import 'package:ZeeU/models/message.dart';
import 'package:ZeeU/models/user_state.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/chats/message_bar.dart';
import 'package:ZeeU/widgets/chats/message_bubble.dart';
import 'package:ZeeU/widgets/cloud_image.dart';
import 'package:ZeeU/widgets/search/doctor_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({
    Key? key,
    required this.specialty,
    required this.notifyRouteChange
  }) : super(key: key);

  final String specialty;
  final Function(String, String) notifyRouteChange;

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  final userRef = FirebaseFirestore.instance
                .collection('users')
                .withConverter<AppUser>(
                    fromFirestore: (snapshots, _) => AppUser.fromJson(snapshots.data()!),
                    toFirestore: (usr, _) => usr.toJson());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
              onWillPop: () async {
                widget.notifyRouteChange('pop', '/doctors');
                return true;
              },
              child: SafeArea(
                child: Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Palette.jet,
                        title: Text(widget.specialty),
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
                        final doctors = data.map((e) => e.data());

                        if (doctors.isEmpty) {
                          return const Center(
                            child: Text('Empty')
                          );
                        }

                        return Column(
                          children: doctors.map((e) => DoctorCard(
                              image: e.img!,
                              name: '${e.firstName} ${e.lastName}',
                              specialty: e.specialty!,
                              institute: e.institute!,
                              contact: e.contact!,
                            )).toList()
                        );
                      },
                    )
                )
              )
            );
  }
}
