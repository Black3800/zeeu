import 'package:ZeeU/models/signup_state.dart';
import 'package:ZeeU/utils/palette.dart';
import 'package:ZeeU/utils/upload.dart';
import 'package:ZeeU/widgets/cloud_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PersonalInfo extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const PersonalInfo({Key? key, required this.formKey}) : super(key: key);

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _ageController;
  final FocusNode _firstNameNode = FocusNode();
  final FocusNode _lastNameNode = FocusNode();
  final FocusNode _ageNode = FocusNode();
  final FocusNode _sexNode = FocusNode();
  String _sex = 'male';

  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    try {
      int.parse(value);
    } catch (e) {
      return 'Invalid';
    }
    return null;
  }

  @override
  void initState() {
    _firstNameController = TextEditingController(
        text: Provider.of<SignupState>(context, listen: false).firstName);
    _lastNameController = TextEditingController(
        text: Provider.of<SignupState>(context, listen: false).lastName);
    _ageController = TextEditingController(
        text: (Provider.of<SignupState>(context, listen: false).age ?? 18)
            .toString());
    _sex = Provider.of<SignupState>(context, listen: false).sex ?? 'male';
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _firstNameNode.dispose();
    _lastNameNode.dispose();
    _ageNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<SignupState>(context, listen: false);
    return Form(
      key: widget.formKey,
      child: Column(children: [
        Container(
            decoration: BoxDecoration(
                border: Border.all(color: Palette.jet.shade50, width: 5),
                shape: BoxShape.circle),
            child: state.img == null || state.img!.isEmpty
                ? InkWell(
                    onTap: () => Upload.pickImage(
                        onSuccess: (path) => setState(() => state.img = path)),
                    child: CircleAvatar(
                      foregroundColor: Palette.aquamarine.shade600,
                      backgroundColor: Palette.white,
                      child: const Icon(Icons.add, size: 25),
                      radius: 35,
                    ))
                : CloudImage(
                    image: state.img!,
                    onChanged: (path) {
                      if (path != '') setState(() => state.img = path);
                    },
                  )),
        const SizedBox(height: 15),
        Text(
          'Upload your photo',
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        TextFormField(
            controller: _firstNameController,
            validator: _validateFirstName,
            focusNode: _firstNameNode,
            decoration: const InputDecoration(
              labelText: 'First name',
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            textInputAction: TextInputAction.next,
            onChanged: (value) => state.firstName = value,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_lastNameNode)),
        const SizedBox(height: 20),
        TextFormField(
            controller: _lastNameController,
            validator: _validateLastName,
            focusNode: _lastNameNode,
            decoration: const InputDecoration(
              labelText: 'Last name',
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            textInputAction: TextInputAction.next,
            onChanged: (value) => state.lastName = value,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_ageNode)),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: TextFormField(
                  controller: _ageController,
                  validator: _validateAge,
                  focusNode: _ageNode,
                  maxLength: 2,
                  buildCounter: (context,
                          {required int currentLength,
                          required bool isFocused,
                          required int? maxLength}) =>
                      null,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Age',
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    try {
                      state.age = int.parse(value);
                    } catch (e) {
                      if (value != '' && value.isNotEmpty) {
                        _ageController.text = state.age.toString();
                      }
                    }
                  },
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_sexNode)),
            ),
            const SizedBox(width: 120),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: Palette.aquamarine),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                      isExpanded: true,
                      value: _sex,
                      focusNode: _sexNode,
                      items: const [
                        DropdownMenuItem(child: Text('Male'), value: 'male'),
                        DropdownMenuItem(
                            child: Text('Female'), value: 'female'),
                        DropdownMenuItem(child: Text('Other'), value: 'other'),
                      ],
                      onChanged: (value) {
                        state.sex = value;
                        setState(() => _sex = '$value');
                      }),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 100)
      ]),
    );
  }
}
