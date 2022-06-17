import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/cta_button.dart';
import 'package:flutter/material.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({
    Key? key,
    required this.text,
    required this.buttonText,
    required this.onPressed,
    required this.image
  }) : super(key: key);

  final String text;
  final String buttonText;
  final Function()? onPressed;
  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.white
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(children: [
            Text(text),
            CtaButton(onPressed: onPressed, text: buttonText)
          ]),
          Image(
            image: image,
            width: 180,
            height: 180,
          )
        ]
      )
    );
  }
}