import 'package:ZeeU/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientButton extends StatefulWidget {
  final Function()? onPressed;
  final String? text;
  final MaterialColor? foregroundColor;
  const GradientButton({
    Key? key,
    required this.onPressed,
    this.text,
    this.foregroundColor = Palette.white
  }) : super(key: key);

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Palette.ultramarine,
            Palette.violet
          ],
          stops: [0.174, 0.9753]
        ),
        borderRadius: BorderRadius.circular(15)
      ),
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size.fromHeight(35)),
          elevation: MaterialStateProperty.all(0),
          backgroundColor: MaterialStateProperty.all(Colors.transparent)
        ),
        child: Text(
          '${widget.text}',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            color: widget.foregroundColor
          ),
        )
      ),
    );
  }
}