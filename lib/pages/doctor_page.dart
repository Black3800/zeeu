import 'package:ZeeU/models/app_user.dart';
import 'package:ZeeU/models/user_state.dart';
import 'package:ZeeU/services/api_socket.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/utils/tab_item.dart';
import 'package:ZeeU/widgets/search/doctor_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Future<void> createChat({required BuildContext ctx, required String doctorUid}) async {
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

    await Provider.of<ApiSocket>(context, listen: false).chats.withDoctor(doctorUid);

    widget.changeTab(TabItem.chats);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserState, ApiSocket>(
        builder: (context, user, api, child) => WillPopScope(
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
                    body: FutureBuilder<List<AppUser>>(
                      future: api.users.doctors.withSpecialty(widget.specialty),
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

                        final doctors = snapshot.requireData;

                        if (doctors.isEmpty) {
                          return const Center(child: Text('Empty'));
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: SingleChildScrollView(
                            child: Column(
                                    children: [
                                      if(user.userType == 'patient') const Text('Tap to chat'),
                                      ...doctors
                                        .map((e) => DoctorCard(
                                              image: e.img!,
                                              name: '${e.firstName} ${e.lastName}',
                                              specialty: e.specialty!,
                                              institute: e.institute!,
                                              contact: e.contact!,
                                              onTap: user.userType == 'patient'
                                                  ? (ctx) => createChat(
                                                      ctx: ctx,
                                                      doctorUid: e.uid!)
                                                  : null,
                                            ))
                                        .toList()]),
                          ),
                        );
                      },
                    )))));
  }
}
