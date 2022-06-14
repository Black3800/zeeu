import 'package:ZeeU/models/app_user.dart';
import 'package:ZeeU/models/user_state.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/zeeu_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();
  bool isSubmitted = false;

  Future<void> handleLogin() async {
    setState(() => isSubmitted = true);
    ZeeuSnackbar snackBar = ZeeuSnackbar(
        text: 'Please check your credentials and try again',
        icon: Icons.clear,
        accentColor: Palette.danger);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc('${credential.user?.uid}').get();

      final user = AppUser.fromJson(doc.data() ?? {});
      
      Provider.of<UserState>(context, listen: false).updateUser(AppUser(
          uid: credential.user?.uid,
          email: credential.user?.email,
          firstName: user.firstName,
          lastName: user.lastName,
          img: user.img));

      snackBar.text = "Welcome, ${user.firstName}";
      snackBar.icon = Icons.check_circle;
      snackBar.accentColor = Palette.success;

      FocusScope.of(context).unfocus();
      Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // doSth
      } else if (e.code == 'wrong-password') {
        // doSth
      }
    } finally {
      _passwordController.clear();
      setState(() => isSubmitted = false);
      snackBar.show(context);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Palette.white,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/ZeeU-Logo-WhiteAlpha.png',
                    width: 250,
                    height: 150,
                  ),
                  const SizedBox(height: 50.0),
                  TextFormField(
                      controller: _emailController,
                      focusNode: _emailNode,
                      maxLength: 320,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_passwordNode)),
                  const SizedBox(height: 25.0),
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordNode,
                    // hintText: 'Password',
                    maxLength: 100,
                    // icon: Icons.lock_rounded,
                    obscureText: true,
                  ),
                  const SizedBox(height: 50.0),
                  // BigButton(
                  //   text: 'Login',
                  //   isLoading: isSubmitted,
                  //   onPressed: handleLogin,
                  // ),
                  // const SizedBox(height: 25.0),
                  // const SignUpClick(),
                ],
              ),
            ),
          ),
        ));
  }
}
