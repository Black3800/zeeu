import 'package:ZeeU/utils/constants.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:flutter/material.dart';

class SpecialtyCard extends StatelessWidget {
  const SpecialtyCard({
    Key? key,
    required this.specialty,
    this.onTap
  }) : super(key: key);

  final String specialty;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: const BoxDecoration(
          color: Palette.white
        ),
        child: Column(
          children: [
            Text(specialty),
            Image(image: AssetImage(Constants.specialtiesImg[specialty]!))
          ],
        )
      )
    );
  }
}