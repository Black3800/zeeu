import 'package:ZeeU/models/user_state.dart';
import 'package:ZeeU/services/api_socket.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/gradient_button.dart';
import 'package:ZeeU/widgets/zeeu_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

      final token = await credential.user?.getIdToken();
      final api = Provider.of<ApiSocket>(context, listen: false);
      final verifySuccess = await api.verifyToken(token!);

      if (!verifySuccess) {
        throw Exception('Token verification failed');
      }

      final user = await api.users.withUid(credential.user?.uid).once;
      user.uid = credential.user?.uid;
      user.email = credential.user?.email;

      snackBar.text = "Welcome, ${user.firstName}";
      snackBar.icon = Icons.check_circle;
      snackBar.accentColor = Palette.success;

      FirebaseAuth.instance.idTokenChanges().listen((user) async {
        final token = await user?.getIdToken();
        api.verifyToken(token!);
      });

      Provider.of<UserState>(context, listen: false).updateUser(user);
      Navigator.of(context).pushReplacementNamed('/app');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // doSth
      } else if (e.code == 'wrong-password') {
        // doSth
      }
      _passwordController.clear();
    } finally {
      if (mounted) {
        setState(() => isSubmitted = false);
        snackBar.show(context);
      }
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
    return SafeArea(
      child: Scaffold(
          body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/Bg.png'), fit: BoxFit.cover)),
        child: CustomScrollView(slivers: [
          SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(50),
                      child: Center(
                        child: Image.asset(
                          'assets/ZeeU-Logo.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                    Expanded(
                        child: Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Palette.honeydew, width: 0.5),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Palette.white.withOpacity(.8),
                                  Palette.white.withOpacity(.32)
                                ],
                              ),
                            ),
                            child: Column(children: [
                              const SizedBox(height: 10),
                              Text('Login',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline1!
                                      .apply(color: Palette.jet)),
                              const SizedBox(height: 30),
                              TextFormField(
                                  controller: _emailController,
                                  focusNode: _emailNode,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context)
                                          .requestFocus(_passwordNode)),
                              const SizedBox(height: 30),
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordNode,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 70),
                              GradientButton(
                                  onPressed: handleLogin, text: 'Login'),
                              const SizedBox(height: 30),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed('/signup');
                                },
                                child: Text(
                                  'Sign up',
                                  style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      color: Palette.jet,
                                      fontSize: 13),
                                ),
                              )
                            ])))
                  ])))
        ]),
      )),
    );
  }
}
