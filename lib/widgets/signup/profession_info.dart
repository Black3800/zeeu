import 'package:ZeeU/models/signup_state.dart';
import 'package:ZeeU/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfessionInfo extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const ProfessionInfo({Key? key, required this.formKey}) : super(key: key);

  @override
  State<ProfessionInfo> createState() => _ProfessionInfoState();
}

class _ProfessionInfoState extends State<ProfessionInfo> {
  late TextEditingController _instituteController;
  late TextEditingController _contactController;
  late TextEditingController _bioController;
  final FocusNode _instituteNode = FocusNode();
  final FocusNode _contactNode = FocusNode();
  final FocusNode _specialtyNode = FocusNode();
  final FocusNode _bioNode = FocusNode();
  String _specialty = 'General';

  String? _validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    return null;
  }

  @override
  void initState() {
    _instituteController = TextEditingController(text: Provider.of<SignupState>(context, listen: false).institute);
    _contactController = TextEditingController(text: Provider.of<SignupState>(context, listen: false).contact);
    _bioController = TextEditingController(text: Provider.of<SignupState>(context, listen: false).bio);
    _specialty = Provider.of<SignupState>(context, listen: false).specialty ?? 'General';
    super.initState();
  }

  @override
  void dispose() {
    _instituteController.dispose();
    _contactController.dispose();
    _bioController.dispose();
    _instituteNode.dispose();
    _contactNode.dispose();
    _specialtyNode.dispose();
    _bioNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignupState>(builder: (context, state, child) => 
      Form(
        key: widget.formKey,
        child: Column(
          children: [
            Text(
              'Your profession info',
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextFormField(
                controller: _instituteController,
                validator: _validateNotEmpty,
                focusNode: _instituteNode,
                decoration: const InputDecoration(labelText: 'Institute'),
                textInputAction: TextInputAction.next,
                onChanged: (value) => state.institute = value,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_contactNode)),
            const SizedBox(height: 15),
            TextFormField(
                controller: _contactController,
                validator: _validateNotEmpty,
                focusNode: _contactNode,
                decoration: const InputDecoration(labelText: 'Contact', hintText: 'Phone or address'),
                textInputAction: TextInputAction.next,
                onChanged: (value) => state.contact = value,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_specialtyNode)),
            const SizedBox(height: 15),
            DropdownButton<String>(
              value: _specialty,
              focusNode: _specialtyNode,
              items: Constants.specialties.map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
              onChanged: (value) {
                state.specialty = value;
                setState(() => _specialty = '$value');
              }
            ),
            const SizedBox(height: 15),
            TextFormField(
                controller: _bioController,
                focusNode: _bioNode,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Short bio'),
                textInputAction: TextInputAction.done,
                onChanged: (value) => state.bio = value),
            const SizedBox(height: 100)
          ]
        ),
      )
    );
  }
}
