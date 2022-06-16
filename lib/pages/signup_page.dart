import 'package:ZeeU/models/signup_state.dart';
import 'package:ZeeU/utils/constants.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/flat_rect_button.dart';
import 'package:ZeeU/widgets/signup/login_details.dart';
import 'package:ZeeU/widgets/signup/personal_info.dart';
import 'package:ZeeU/widgets/signup/profession_info.dart';
import 'package:ZeeU/widgets/signup/select_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool isSubmitted = false;

  late List<Widget> _steps;
  late List<GlobalKey<FormState>> _formKeys;
  int _currentStep = 0;

  Future<void> _handleSignup() async {
    try {
      await FirebaseAuth.instance.currentUser?.delete();
      final SignupState detail = Provider.of<SignupState>(context, listen: false);
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: detail.email!, password: detail.password!);
      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'user_type': detail.userType,
        'first_name': detail.firstName,
        'last_name': detail.lastName,
        'age': detail.age ?? 18,
        'sex': detail.sex ?? 'male',
        'img': detail.img ?? Constants.dummyProfileImageUrl,
        'institute': detail.userType == 'doctor' ? detail.institute : null,
        'contact': detail.userType == 'doctor' ? detail.contact : null,
        'specialty': detail.userType == 'doctor' ? detail.specialty ?? 'General' : null,
        'bio': detail.userType == 'doctor' ? detail.bio : null
      });
      Provider.of<SignupState>(context, listen: false).dispose();
      FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "provider-already-linked":
          print("The provider has already been linked to the user.");
          break;
        case "invalid-credential":
          print("The provider's credential is not valid.");
          break;
        case "credential-already-in-use":
          print("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          break;
        // See the API reference for the full list of error codes.
        default:
          print("Unknown error.");
      }
    } on Exception catch (e) {
      print('Error');
    }
  }

  @override
  void initState() {
    _formKeys = [
      GlobalKey<FormState>(),
      GlobalKey<FormState>(),
      GlobalKey<FormState>(),
      GlobalKey<FormState>()
    ];
    _steps = [
      const SelectType(),
      LoginDetails(formKey: _formKeys[1]),
      PersonalInfo(formKey: _formKeys[2]),
      ProfessionInfo(formKey: _formKeys[3])
    ];
    FirebaseAuth.instance.signInAnonymously();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignupState>(builder: (context, state, child) {
      bool _isNotLastStep = _currentStep < 2 + (state.userType == 'patient' ? 0 : 1);
      return WillPopScope(
        onWillPop: () async {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
            return false;
          }
          state.dispose();
          FirebaseAuth.instance.currentUser?.delete();
          return true;
        },
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Palette.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: Palette.jet,
              elevation: 0,
            ),
            body: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(30),
                            child: Column(
                              children: [
                                Text('Sign up', style: Theme.of(context).textTheme.headline1!.apply(color: Palette.jet)),
                                const SizedBox(height: 30),
                                Expanded(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    switchInCurve: Curves.easeInOut,
                                    switchOutCurve: Curves.easeInOut,
                                    child: _steps[_currentStep],
                                  )
                                ),
                                FlatRectButton(
                                  onPressed: () async {
                                    FocusScope.of(context).unfocus();
                                    if (!(_formKeys[_currentStep].currentState?.validate() ?? true)) {
                                      return;
                                    }
                                    if (_isNotLastStep) {
                                      setState(() => _currentStep += 1);
                                    } else {
                                      await _handleSignup().then((_) => Navigator.of(context).pushNamed('/signup-success'));
                                    }
                                  },
                                  text: _isNotLastStep ? 'Next' : 'Finish',
                                  backgroundColor: _isNotLastStep ? null : Palette.ultramarine,
                                  foregroundColor: _isNotLastStep ? null : Palette.white,
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Palette.aquamarine)
                                  ),
                                  child: LinearProgressIndicator(
                                    value: state.userType == 'patient' ? 0.327 * _currentStep + 0.02 : 0.245 * _currentStep + 0.02,
                                    color: Palette.aquamarine,
                                    backgroundColor: Palette.white
                                  ),
                                )
                              ]
                            )
                          )
                        )
                      ]
                    )
                  )
                )
              ]
            )
          ),
        ),
      );
    });
  }
}
