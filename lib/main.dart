import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/app_user.dart';
import 'models/user_state.dart';
import 'pages/pages.dart';
import 'utils/palette.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    runApp(MyApp(user: user));
  });
}

class MyApp extends StatefulWidget {
  final User? user;
  const MyApp({Key? key, required this.user}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<AppUser> _user;

  Future<AppUser> _fetchUser() async {
    AppUser _appUser = AppUser();
    if (widget.user != null) {
      FirebaseFirestore
        .instance
        .collection('users')
        .doc(widget.user!.uid)
        .get()
        .then(
          (DocumentSnapshot doc) {
            final data = doc.data() as Map<String, dynamic>;
            _appUser = AppUser.fromJson(data);
          },
          onError: (e) => debugPrint('Error getting document: $e')
        );
    }
    return _appUser;
  }

  @override
  void initState() {
    super.initState();
    _user = _fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    final _userState = UserState();

    return ChangeNotifierProvider<UserState>(
      create: (_) => _userState,
      child: FutureBuilder<AppUser>(
        future: _user,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data!.uid != '') {
              return const HomePage();
            } else {
              return const LoginPage();
            }
          } else {
            return const CircularProgressIndicator();
          }
        }
      )
    );
  }
}
