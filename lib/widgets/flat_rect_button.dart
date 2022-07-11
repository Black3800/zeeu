import 'package:ZeeU/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlatRectButton extends StatefulWidget {
  final Function()? onPressed;
  final String? text;
  final MaterialColor? backgroundColor;
  final MaterialColor? foregroundColor;
  final bool loadOnPressed;
  const FlatRectButton({
    Key? key,
    required this.onPressed,
    this.text,
    this.backgroundColor,
    this.foregroundColor,
    this.loadOnPressed = false
  }) : super(key: key);

  @override
  State<FlatRectButton> createState() => _FlatRectButtonState();
}

class _FlatRectButtonState extends State<FlatRectButton> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          if (widget.loadOnPressed) setState(() => loading = true);
          widget.onPressed?.call();
        },
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
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Palette.white,
                  strokeWidth: 2,
                ))
            : Text(
                '${widget.text}',
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    color: widget.foregroundColor?.shade700 ??
                        Palette.aquamarine.shade700),
              )
      );
  }
}
