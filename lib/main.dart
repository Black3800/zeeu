import 'package:ZeeU/models/signup_state.dart';
import 'package:ZeeU/pages/login_page.dart';
import 'package:ZeeU/pages/signup_page.dart';
import 'package:ZeeU/pages/signup_success_page.dart';
import 'package:ZeeU/services/api_socket.dart';
import 'package:ZeeU/widgets/app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/user_state.dart';
import 'utils/palette.dart';

Future<void> main() async {
  bool runOnce = false;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (runOnce) return;
    runApp(MyApp(user: user));
    runOnce = true;
  });
}

class MyApp extends StatelessWidget {
  final User? user;
  MyApp({Key? key, required this.user}) : super(key: key);

  final GlobalKey<NavigatorState> _appNavigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: user != null ? user!.getIdToken() : Future.value(''),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UserState()),
            Provider(create: (_) => SignupState()),
            Provider(create: (_) => ApiSocket(token: snapshot.data))
          ],
          child: MaterialApp(
                  title: 'Zee U',
                  navigatorKey: _appNavigatorKey,
                  initialRoute: user == null ? '/login' : '/app',
                  routes: {
                    '/login': (_) => const LoginPage(),
                    '/signup': (_) => const SignupPage(),
                    '/signup-success': (_) => const SignupSuccessPage(),
                    '/app': (_) => App(appNavigatorKey: _appNavigatorKey)
                  },
                  theme: ThemeData(
                    brightness: Brightness.light,
                    primarySwatch: Palette.aquamarine,
                    colorScheme: ThemeData().colorScheme.copyWith(primary: Palette.ultramarine),
                    fontFamily: GoogleFonts.roboto().fontFamily,
                    textTheme: TextTheme(
                      headline1: GoogleFonts.roboto(fontSize: 32.0, fontWeight: FontWeight.w900),
                      headline2: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.w600),
                      bodyText1: GoogleFonts.roboto(fontSize: 16.0),
                    )
                  ),
                  debugShowCheckedModeBanner: false,
                )
        );
      }
    );
  }
}
