import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/cta_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroCard extends StatelessWidget {
  const HeroCard(
      {Key? key,
      required this.text,
      required this.buttonText,
      required this.onPressed,
      required this.image})
      : super(key: key);

  final String text;
  final String buttonText;
  final Function()? onPressed;
  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Palette.white,
            boxShadow: const [
              BoxShadow(
                  color: Color.fromRGBO(53, 53, 53, 0.10000000149011612),
                  offset: Offset(1, 1),
                  blurRadius: 15)
            ],
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFF8F8F8), Color(0xFFF3F3F3)],
              stops: [0.4531, 0.7656, 1],
            ),
            border: Border.all(
              color: Palette.gray.shade50,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          text,
                          style: GoogleFonts.roboto(
                              color: Palette.jet,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        CtaButton(onPressed: onPressed, text: buttonText)
                      ]),
                ),
                Expanded(
                  flex: 6,
                  child: Image(
                    image: image,
                    width: 180,
                    height: 180,
                  ),
                )
              ]),
        ));
  }
}
