import 'package:flutter/material.dart';

class CtaButton extends StatelessWidget {
  const CtaButton(
      {Key? key,
      required this.onPressed,
      required this.text,
      this.icon = Icons.chevron_right})
      : super(key: key);

  final Function()? onPressed;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed, child: Row(children: [Text(text), Icon(icon)]));
  }
}
