import 'package:flutter/material.dart';
import 'package:orderease_admin/responsive/mobile/mobile_body.dart';
import 'package:orderease_admin/responsive/responsive_layout.dart';
import 'package:orderease_admin/utils/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'features/authentication/screens/login/authpage.dart';
// import 'features/authentication/screens/login/widgets/phone_auth.dart';
import 'features/authentication/authentication/login/authpage.dart';
import 'features/authentication/screens/onboarding/onboarding.dart';
import 'navigation_menu.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: SMAAppTheme.lightTheme,
      darkTheme: SMAAppTheme.darkTheme,
      home: FutureBuilder<bool>(
        future: _isOnBoardingCompleted(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return snapshot.data ?? false ? AuthPage() : OnBoardingScreen();
          }
        },
      ),
      // routes: {
      //   '/phone-auth': (context) => PhoneAuthScreen(),
      //   '/home': (context) => Navigation(),
      // },
    );
  }

  Future<bool> _isOnBoardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onBoardingCompleted') ?? false;
  }
}
