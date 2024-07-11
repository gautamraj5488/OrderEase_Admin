import 'package:flutter/material.dart';
import 'package:orderease_admin/features/authentication/authentication/login/widgets/form.dart';
import 'package:orderease_admin/features/authentication/authentication/login/widgets/header.dart';


import '../../../../common/styles/spacing_style.dart';
import '../../../../common/widgets.login_signup/form_divider.dart';
import '../../../../common/widgets.login_signup/social_button.dart';
import '../../../../services/firestore.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/helpers/helper_fuctions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key,});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final FireStoreServices _firestoreServices = FireStoreServices();

  String? _fcmToken;

  @override
  void initState() {
    super.initState();
   // _initializeFCMToken();
  }

  // Future<void> _initializeFCMToken() async {
  //   String? token = await _firestoreServices.getFCMToken();
  //   if (mounted) {
  //     setState(() {
  //       _fcmToken = token;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final dark = SMAHelperFunctions.isDarkMode(context);
    if (_fcmToken == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: SMASpacingStyle.paddingWithAppBarHeight,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SMALoginHeader(dark: dark),
              SMALoginForm(FCMtoken: _fcmToken!,),
              SMAFormDivider(dark: dark,text: SMATexts.orSignInWith,),
              SizedBox(
                height: SMASizes.spaceBtwSections,
              ),
              SMASocialButton(),
            ]),
          ),
        )
    );
  }
}
