import 'dart:async';

import 'package:ZeeU/utils/palette.dart';
import 'package:flutter/material.dart';

class SignupSuccessPage extends StatefulWidget {
  const SignupSuccessPage({Key? key}) : super(key: key);

  @override
  State<SignupSuccessPage> createState() => _SignupSuccessPageState();
}

class _SignupSuccessPageState extends State<SignupSuccessPage> {
  @override
  void initState() {
    Timer(const Duration(seconds: 2),
        () => Navigator.of(context).pushReplacementNamed('/app'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: SafeArea(
            child: Scaffold(
          body: Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/Bg.png'), fit: BoxFit.cover),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Success!',
                    style: TextStyle(fontSize: 20, color: Palette.jet),
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                  Image.asset(
                    'assets/checked.png',
                    fit: BoxFit.fitWidth,
                    width: 92.5,
                    height: 92.5,
                  ),
                ],
              ),
            ),
          ),
        )));
  }
}
