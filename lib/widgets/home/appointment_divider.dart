import 'package:ZeeU/utils/palette.dart';
import 'package:flutter/material.dart';

class AppointmentDivider extends StatelessWidget {
  const AppointmentDivider({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 22),
      child: Row(children: [
        Text(text),
        const SizedBox(
          width: 15,
        ),
        Expanded(
            child: Divider(thickness: 1, color: Palette.jet.withOpacity(.2)))
      ]),
    );
  }
}
