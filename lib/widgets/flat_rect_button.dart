import 'package:ZeeU/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlatRectButton extends StatefulWidget {
  final Function()? onPressed;
  final String? text;
  final MaterialColor? backgroundColor;
  final MaterialColor? foregroundColor;
  const FlatRectButton({
    Key? key,
    required this.onPressed,
    this.text,
    this.backgroundColor,
    this.foregroundColor
  }) : super(key: key);

  @override
  State<FlatRectButton> createState() => _FlatRectButtonState();
}

class _FlatRectButtonState extends State<FlatRectButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: widget.onPressed,
        style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(const Size.fromHeight(35)),
            elevation: MaterialStateProperty.all(0),
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return widget.backgroundColor?.shade500 ?? Palette.aquamarine.shade500;
              } else if (states.contains(MaterialState.disabled)) {
                return widget.backgroundColor?.shade300 ?? Palette.aquamarine.shade300;
              }
              return widget.backgroundColor ?? Palette.aquamarine;
            })
        ),
        child: Text(
          '${widget.text}',
          style: GoogleFonts.roboto(
              fontWeight: FontWeight.w600,
              color: widget.foregroundColor?.shade700 ?? Palette.aquamarine.shade700
          ),
        )
      );
  }
}
