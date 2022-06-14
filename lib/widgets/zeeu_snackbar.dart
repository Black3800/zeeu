import 'package:ZeeU/utils/palette.dart';
import 'package:flutter/material.dart';

class ZeeuSnackbar {
  String text;
  IconData? icon;
  MaterialColor? accentColor;
  ZeeuSnackbar({required this.text, this.icon, this.accentColor});

  void show(BuildContext context) {
    SnackBar _snackBar = SnackBar(
      content: Row(children: [
        icon != null ? Icon(icon, color: accentColor) : Container(),
        const SizedBox(width: 10.0),
        Text(text)
      ]),
      backgroundColor: Palette.jet,
    );
    ScaffoldMessenger.of(context).showSnackBar(_snackBar);
  }
}
