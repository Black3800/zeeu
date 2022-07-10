import 'package:ZeeU/models/user_state.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/widgets/cloud_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                    title: Text(
                      'Profile',
                      style: GoogleFonts.roboto(
                          color: Palette.jet,
                          fontSize: 18,
                          fontWeight: FontWeight.w800),
                    ),
                    elevation: 0,
                    centerTitle: true,
                    backgroundColor: Palette.white,
                    foregroundColor: Palette.jet,
                  ),
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
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
                              radius: 150,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Text(
                              'Personal information',
                              style: GoogleFonts.roboto(
                                  color: Palette.jet,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Color.fromRGBO(
                                                53, 53, 53, 0.15),
                                            offset: Offset(2, 3),
                                            blurRadius: 15)
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: _firstNameController,
                                      validator: _validateNotEmpty,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 15.0,
                                                horizontal: 17.0),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: BorderSide(
                                            color: Palette.gray.shade300,
                                            width: 0.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: Palette.gray,
                                            width: 0.5,
                                          ),
                                        ),
                                        labelText: 'Firstname',
                                        labelStyle: const TextStyle(
                                            color: Palette.gray, fontSize: 18),
                                        fillColor: Colors.white,
                                        filled: true,
                                      ),
                                      onFieldSubmitted: (_) =>
                                          _updateProfile(user.uid!),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Color.fromRGBO(
                                                53, 53, 53, 0.15),
                                            offset: Offset(2, 3),
                                            blurRadius: 15)
                                      ],
                                    ),
                                    child: TextFormField(
                                        controller: _lastNameController,
                                        validator: _validateNotEmpty,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 15.0,
                                                  horizontal: 17.0),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: BorderSide(
                                              color: Palette.gray.shade300,
                                              width: 0.5,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: const BorderSide(
                                              color: Palette.gray,
                                              width: 0.5,
                                            ),
                                          ),
                                          labelText: 'Lastname',
                                          labelStyle: const TextStyle(
                                              color: Palette.gray,
                                              fontSize: 18),
                                          fillColor: Colors.white,
                                          filled: true,
                                        ),
                                        onFieldSubmitted: (_) =>
                                            _updateProfile(user.uid!)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            if (user.userType == 'doctor') ...[
                              Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(53, 53, 53, 0.15),
                                        offset: Offset(2, 3),
                                        blurRadius: 15)
                                  ],
                                ),
                                child: TextFormField(
                                    controller: _contactController,
                                    validator: _validateNotEmpty,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 20.0, horizontal: 17.0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                          color: Palette.gray.shade300,
                                          width: 0.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(
                                          color: Palette.gray,
                                          width: 0.5,
                                        ),
                                      ),
                                      labelText: 'Contact',
                                      labelStyle: const TextStyle(
                                          color: Palette.gray, fontSize: 18),
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                    onFieldSubmitted: (_) =>
                                        _updateProfile(user.uid!)),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(53, 53, 53, 0.15),
                                        offset: Offset(2, 3),
                                        blurRadius: 15)
                                  ],
                                ),
                                child: TextFormField(
                                    controller: _instituteController,
                                    validator: _validateNotEmpty,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 20.0, horizontal: 17.0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                          color: Palette.gray.shade300,
                                          width: 0.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(
                                          color: Palette.gray,
                                          width: 0.5,
                                        ),
                                      ),
                                      labelText: 'Institute',
                                      labelStyle: const TextStyle(
                                          color: Palette.gray, fontSize: 18),
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                    onFieldSubmitted: (_) =>
                                        _updateProfile(user.uid!)),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(53, 53, 53, 0.15),
                                        offset: Offset(2, 3),
                                        blurRadius: 15)
                                  ],
                                ),
                                child: TextFormField(
                                    controller: _bioController,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 15.0, horizontal: 17.0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                          color: Palette.gray.shade300,
                                          width: 0.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(
                                          color: Palette.gray,
                                          width: 0.5,
                                        ),
                                      ),
                                      labelText: 'Short bio',
                                      labelStyle: const TextStyle(
                                          color: Palette.gray, fontSize: 18),
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                    maxLines: 4,
                                    onFieldSubmitted: (_) =>
                                        _updateProfile(user.uid!)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )),
            ));
  }
}
