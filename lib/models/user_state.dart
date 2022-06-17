import 'package:ZeeU/models/app_user.dart';
import 'package:flutter/foundation.dart';

class UserState extends ChangeNotifier {
  AppUser? _user;
  
  String? get userType => _user?.userType;
  String? get firstName => _user?.firstName;
  String? get lastName => _user?.lastName;
  String? get email => _user?.email;
  String? get img => _user?.img;
  String? get uid => _user?.uid;

  set firstName(String? value) {
    _user?.firstName = value;
    notifyListeners();
  }

  set lastName(String? value) {
    _user?.lastName = value;
    notifyListeners();
  }

  set email(String? value) {
    _user?.email = value;
    notifyListeners();
  }

  set img(String? value) {
    _user?.img = value;
    notifyListeners();
  }

  set uid(String? value) {
    _user?.uid = value;
    notifyListeners();
  }

  void updateUser(AppUser ref) {
    _user = AppUser.fromRef(ref);
    notifyListeners();
  }

  void disposeUser() {
    _user = null;
  }

  @override
  void dispose() {
    disposeUser();
    super.dispose();
  }
}
