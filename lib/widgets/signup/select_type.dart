import 'package:ZeeU/models/signup_state.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SelectType extends StatefulWidget {
  const SelectType({Key? key}) : super(key: key);

  @override
  State<SelectType> createState() => _SelectTypeState();
}

class _SelectTypeState extends State<SelectType> {
  late bool _isPatient;

  @override
  void initState() {
    _isPatient =
        Provider.of<SignupState>(context, listen: false).userType == 'patient';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        'Are you using ZeeU as a patient or doctor?',
        style: Theme.of(context).textTheme.bodyText1,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 100),
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _isPatient
              ? [selectedButton('Patient'), unselectedButton('Doctor')]
              : [unselectedButton('Patient'), selectedButton('Doctor')])
    ]);
  }

  Widget unselectedButton(text) => ElevatedButton(
        onPressed: () {
          setState(() => _isPatient = !_isPatient);
          Provider.of<SignupState>(context, listen: false).userType =
              _isPatient ? 'patient' : 'doctor';
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              text == 'Patient' ? 'assets/patient.png' : 'assets/doctor.png',
              fit: BoxFit.fitWidth,
              width: 54,
              height: 54,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(text, style: GoogleFonts.roboto(color: Palette.jet)),
          ],
        ),
        style: ElevatedButton.styleFrom(
            fixedSize: const Size(120, 120),
            shape: const CircleBorder(),
            primary: Palette.white,
            elevation: 0),
      );

  Widget selectedButton(text) => ElevatedButton(
        onPressed: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              text == 'Patient' ? 'assets/patient.png' : 'assets/doctor.png',
              fit: BoxFit.fitWidth,
              width: 54,
              height: 54,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(text,
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w700, color: Palette.white)),
          ],
        ),
        style: ElevatedButton.styleFrom(
            fixedSize: const Size(120, 120),
            shape: const CircleBorder(),
            primary: Palette.aquamarine,
            elevation: 0),
      );
}
