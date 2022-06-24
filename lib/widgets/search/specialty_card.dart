import 'package:ZeeU/utils/constants.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpecialtyCard extends StatelessWidget {
  const SpecialtyCard({Key? key, required this.specialty, this.onTap})
      : super(key: key);

  final String specialty;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 1),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 1),
                width: 0.5,
              ),
              boxShadow: const [
                BoxShadow(
                    color: Color.fromRGBO(53, 53, 53, 0.10000000149011612),
                    offset: Offset(2, 3),
                    blurRadius: 20)
              ],
              gradient: const LinearGradient(
                  begin: Alignment(0.6023529171943665, 0.48941177129745483),
                  end: Alignment(-0.48941177129745483, 0.6023529171943665),
                  colors: [
                    Color.fromRGBO(255, 255, 255, 0.5),
                    Color.fromRGBO(255, 255, 255, 0.30000001192092896)
                  ]),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage(
                    Constants.specialtiesImg[specialty]!,
                  ),
                  width: 40,
                  height: 40,
                  fit: BoxFit.fitWidth,
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  specialty,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w500,
                    color: Palette.jet,
                    fontSize: 12,
                  ),
                ),
              ],
            )));
  }
}
