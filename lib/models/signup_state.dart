class SignupState {
  String? userType = 'patient';
  String? firstName;
  String? lastName;
  String? email;
  String? img;
  String? password;
  String? confirmPassword;
  String? sex;
  String? institute;
  String? contact;
  String? specialty;
  String? bio;
  int? age;

  void dispose() {
    userType = 'patient';
    firstName = null;
    lastName = null;
    email = null;
    img = null;
    password = null;
    confirmPassword = null;
    sex = null;
    institute = null;
    contact = null;
    specialty = null;
    bio = null;
    age = null;
  }
}
