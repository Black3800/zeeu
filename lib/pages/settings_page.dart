import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/settings/profile_card.dart';
import 'package:ZeeU/widgets/settings/settings_item.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key, required this.notifyRouteChange})
      : super(key: key);

  final Function(String, String) notifyRouteChange;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ProfileCard(notifyRouteChange: notifyRouteChange),
            ),
            const Text('General Settings'),
            SettingsItem(
              icon: Icons.history,
              text: 'Appointment history',
              notifyRouteChange: notifyRouteChange,
              routeName: '/history'
            ),
            SettingsItem(
              icon: Icons.logout,
              text: 'Logout',
              notifyRouteChange: notifyRouteChange,
              routeName: '/logout',
              showArrow: false,
              color: Palette.danger,
              fontWeight: FontWeight.w700,
            )
          ]),
        ));
  }
}
