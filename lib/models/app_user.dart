class AppUser {
  String? firstName;
  String? lastName;
  String? email;
  String? img;
  String? uid;
  AppUser({
    this.firstName,
    this.lastName,
    this.email,
    this.img,
    this.uid = '',
  });

  AppUser.fromRef(AppUser ref)
    : firstName = ref.firstName,
      lastName = ref.lastName,
      email = ref.email,
      img = ref.img,
      uid = ref.uid;

  AppUser.fromJson(Map<dynamic, dynamic> json)
    : firstName = json['first_name'],
      lastName = json['last_name'],
      email = json['email'],
      img = json['img'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'img': img
      };
}
