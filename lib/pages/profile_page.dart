// import 'dart:html';

import 'package:ZeeU/models/user_state.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/cloud_image.dart';
import 'package:ZeeU/widgets/cta_button.dart';
import 'package:ZeeU/widgets/gradient_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.notifyRouteChange})
      : super(key: key);

  final Function(String, String) notifyRouteChange;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _contactController;
  late TextEditingController _instituteController;
  late TextEditingController _bioController;
  late String img;

  String? _validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    return null;
  }

  void _updateProfile(String id) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = Provider.of<UserState>(context, listen: false).instance!;
    user.img = img;
    user.firstName = _firstNameController.text;
    user.lastName = _lastNameController.text;
    user.contact =
        _contactController.text.isNotEmpty ? _contactController.text : null;
    user.institute =
        _instituteController.text.isNotEmpty ? _instituteController.text : null;
    user.bio = _bioController.text.isNotEmpty ? _bioController.text : null;
    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update(user.toJson());
  }

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserState>(context, listen: false);
    _firstNameController = TextEditingController(text: user.firstName);
    _lastNameController = TextEditingController(text: user.lastName);
    _contactController = TextEditingController(text: user.instance!.contact);
    _instituteController =
        TextEditingController(text: user.instance!.institute);
    _bioController = TextEditingController(text: user.instance!.bio);
    img = user.img!;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserState>(
        builder: (context, user, child) => WillPopScope(
              onWillPop: () async {
                widget.notifyRouteChange('pop', '/profile');
                return true;
              },
              child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    title: const Text('Profile'),
                    elevation: 0,
                    centerTitle: true,
                    backgroundColor: Palette.white,
                    foregroundColor: Palette.jet,
                  ),
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CloudImage(
                              image: user.img!,
                              onChanged: (path) {
                                if (path == '') return;
                                setState(() => img = path);
                                _updateProfile(user.uid!);
                              },
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _firstNameController,
                                    validator: _validateNotEmpty,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      labelText: 'Firstname',
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                    onFieldSubmitted: (_) =>
                                        _updateProfile(user.uid!),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: TextFormField(
                                      controller: _lastNameController,
                                      validator: _validateNotEmpty,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        labelText: 'Lastname',
                                        fillColor: Colors.white,
                                        filled: true,
                                      ),
                                      onFieldSubmitted: (_) =>
                                          _updateProfile(user.uid!)),
                                ),
                              ],
                            ),
                            if (user.userType == 'doctor') ...[
                              TextFormField(
                                  controller: _contactController,
                                  validator: _validateNotEmpty,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    labelText: 'Contact',
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                  onFieldSubmitted: (_) =>
                                      _updateProfile(user.uid!)),
                              TextFormField(
                                  controller: _instituteController,
                                  validator: _validateNotEmpty,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    labelText: 'Institute',
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                  onFieldSubmitted: (_) =>
                                      _updateProfile(user.uid!)),
                              TextFormField(
                                  controller: _bioController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    labelText: 'Short bio',
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                  maxLines: 4,
                                  onFieldSubmitted: (_) =>
                                      _updateProfile(user.uid!)),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                cancelButton(),
                                saveButton(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
            ));
  }

  Widget cancelButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        shadowColor: Colors.white38,
        primary: Color.fromARGB(0, 255, 255, 255),
        fixedSize: const Size(149, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Color(0xff8038DD),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            Icons.close,
            color: Color(0xff8038DD),
          ),
          Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xff8038DD),
            ),
          )
        ],
      ),
    );
  }

  Widget saveButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        primary: Color(0xff8038DD),
        fixedSize: const Size(149, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.save),
          Text(
            'Save',
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
