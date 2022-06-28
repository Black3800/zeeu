import 'package:ZeeU/utils/palette.dart';
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
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        primary: Palette.honeydew.shade500,
        onPrimary: Palette.aquamarine.shade500,
        minimumSize: const Size(120, 35),
        maximumSize: const Size(120, 35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          Icon(
            icon,
            size: 17,
          ),
        ],
      ),
    );
  }
}
