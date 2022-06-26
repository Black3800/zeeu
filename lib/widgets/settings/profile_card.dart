import 'package:ZeeU/models/user_state.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/cloud_image.dart';
import 'package:ZeeU/widgets/cta_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({Key? key, required this.notifyRouteChange})
      : super(key: key);

  final Function(String, String) notifyRouteChange;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserState>(
      builder: (context, user, child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Palette.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
              ),
            ]),
        child: Column(
          children: [
            if (user.img != null) CloudImage(image: user.img!, readOnly: true),
            Text('${user.firstName} ${user.lastName}'),
            CtaButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/profile');
                notifyRouteChange('push', '/profile');
              },
              text: 'Edit profile',
              icon: Icons.edit,
            )
          ],
        ),
      ),
    );
  }
}
