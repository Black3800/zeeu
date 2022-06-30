import 'package:ZeeU/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsItem extends StatelessWidget {
  const SettingsItem(
      {Key? key,
      required this.text,
      required this.icon,
      required this.notifyRouteChange,
      required this.routeName,
      this.showArrow = true,
      this.color = Palette.jet,
      this.fontWeight = FontWeight.normal})
      : super(key: key);

  final String text;
  final IconData icon;
  final Function(String, String) notifyRouteChange;
  final String routeName;
  final bool showArrow;
  final MaterialColor color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        notifyRouteChange('push', routeName);
        Navigator.of(context).pushNamed(routeName);
      },
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: 0.2),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Palette.white.withOpacity(0.5),
            border: Border.all(
              color: Palette.gray.shade100,
              width: 0.5,
            ),
          ),
          child: Row(children: [
            Icon(
              icon,
              color: color,
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.roboto(color: color, fontWeight: fontWeight),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right,
                color: Palette.gray.shade300,
              )
          ])),
    );
  }
}
