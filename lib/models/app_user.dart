class AppUser {
  String? userType;
  String? firstName;
  String? lastName;
  String? email;
  String? img;
  String? sex;
  String? institute;
  String? contact;
  String? specialty;
  String? bio;
  String? uid;
  bool? active;
  AppUser({
    this.userType,
    this.firstName,
    this.lastName,
    this.email,
    this.img,
    this.sex,
    this.institute,
    this.contact,
    this.specialty,
    this.bio,
    this.uid = '',
    this.active = false
  });

  AppUser.fromRef(AppUser ref)
    : userType = ref.userType,
      firstName = ref.firstName,
      lastName = ref.lastName,
      email = ref.email,
      img = ref.img,
      sex = ref.sex,
      institute = ref.institute,
      contact = ref.contact,
      specialty = ref.specialty,
      bio = ref.bio,
      uid = ref.uid,
      active = ref.active;

  AppUser.fromJson(Map<dynamic, dynamic> json, { String? uid })
    : userType = json['user_type'],
      firstName = json['first_name'],
      lastName = json['last_name'],
      email = json['email'],
      img = json['img'],
      sex = json['sex'],
      institute = json['institute'],
      contact = json['contact'],
      specialty = json['specialty'],
      bio = json['bio'],
      active = json['active'],
      this.uid = uid;

  Map<String, Object?> toJson() => <String, Object?>{
    'user_type': userType,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'img': img,
    'sex': sex,
    'institute': institute,
    'contact': contact,
    'specialty': specialty,
    'bio': bio,
    'active': active
  };
}
