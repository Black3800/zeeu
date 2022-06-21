import 'package:ZeeU/models/signup_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const LoginDetails({Key? key, required this.formKey}) : super(key: key);

  @override
  State<LoginDetails> createState() => _LoginDetailsState();
}

class _LoginDetailsState extends State<LoginDetails> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmController;
  final FocusNode _emailNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();
  final FocusNode _confirmNode = FocusNode();

  String? _validateEmail(String? value) {
    RegExp emailRegex = RegExp(r'^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$',
        caseSensitive: false);
    if (value == null || value.isEmpty) {
      return 'Required';
    } else if (!emailRegex.hasMatch(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    } else if (value.length < 6) {
      return 'At least 6 characters';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    } else if (value != _passwordController.text) {
      return 'Password does not match';
    }
    return null;
  }

  @override
  void initState() {
    _emailController = TextEditingController(
        text: Provider.of<SignupState>(context, listen: false).email);
    _passwordController = TextEditingController(
        text: Provider.of<SignupState>(context, listen: false).password);
    _confirmController = TextEditingController(
        text: Provider.of<SignupState>(context, listen: false).confirmPassword);
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    _confirmNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(children: [
        Text(
          'Your login details',
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        TextFormField(
            controller: _emailController,
            validator: _validateEmail,
            focusNode: _emailNode,
            decoration: const InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            textInputAction: TextInputAction.next,
            onChanged: (value) =>
                Provider.of<SignupState>(context, listen: false).email = value,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_passwordNode)),
        const SizedBox(height: 20),
        TextFormField(
            controller: _passwordController,
            validator: _validatePassword,
            focusNode: _passwordNode,
            decoration: const InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            textInputAction: TextInputAction.next,
            obscureText: true,
            onChanged: (value) =>
                Provider.of<SignupState>(context, listen: false).password =
                    value,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_confirmNode)),
        const SizedBox(height: 20),
        TextFormField(
            controller: _confirmController,
            validator: _validateConfirm,
            focusNode: _confirmNode,
            decoration: const InputDecoration(
              labelText: 'Confirm password',
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            textInputAction: TextInputAction.done,
            obscureText: true,
            onChanged: (value) =>
                Provider.of<SignupState>(context, listen: false)
                    .confirmPassword = value),
        const SizedBox(height: 100)
      ]),
    );
  }
}
