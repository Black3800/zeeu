import 'package:ZeeU/models/user_state.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/cloud_image.dart';
import 'package:ZeeU/widgets/cta_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
                color: Color.fromRGBO(53, 53, 53, 0.1),
                offset: Offset(1, 1),
                blurRadius: 15)
          ],
          border: Border.all(
            color: const Color.fromRGBO(204, 204, 204, 0.1),
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            if (user.img != null)
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(53, 53, 53, 0.1),
                        offset: Offset(2, 3),
                        blurRadius: 15)
                  ],
                ),
                child: CloudImage(
                  image: user.img!,
                  readOnly: true,
                  radius: 101,
                ),
              ),
            const SizedBox(
              height: 20,
            ),
            Text(
              '${user.firstName} ${user.lastName}',
              style: GoogleFonts.roboto(
                  color: Palette.jet,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 20,
            ),
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
