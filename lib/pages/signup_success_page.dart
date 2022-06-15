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
    Timer(
      const Duration(seconds: 2),
      () => Navigator.of(context).popUntil(ModalRoute.withName('/login'))
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
            onWillPop: () async => false,
            child: SafeArea(
              child: Scaffold(
                  backgroundColor: Palette.white,
                  body: Center(
                    child: const Text('Success')
                  )
              )
            )
          );
  }
}
