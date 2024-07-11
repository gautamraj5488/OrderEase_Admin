import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orderease_admin/responsive/desktop/desktop_body.dart';
import '../../features/authentication/authentication/login/complete_profile.dart';
import '../../navigation_menu.dart';
import '../../responsive/mobile/mobile_body.dart';
import '../../responsive/responsive_layout.dart';
import '../../responsive/tablet/tablet_body.dart';
import '../../services/firestore.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_fuctions.dart';

class SMASocialButton extends StatelessWidget {
  SMASocialButton({
    super.key,
  });

  final FireStoreServices _fireStoreServices = FireStoreServices();

  Future<void> _signInWithGoogle(BuildContext context) async {
    if (kIsWeb) {
      // Google Sign-In for web
      try {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
        final User? user = userCredential.user;

        if (user != null) {
          final firstName = user.displayName?.split(' ')[0] ?? '';
          final lastName = user.displayName?.split(' ').sublist(1).join(' ') ?? '';

          // Check if the user already exists in Firestore
          final userDoc = FirebaseFirestore.instance.collection('admins').doc(user.uid);
          final docSnapshot = await userDoc.get();

          if (!docSnapshot.exists) {
            // Create a new user in Firestore
            await userDoc.set({
              'uid': user.uid,
              'firstName': firstName,
              'lastName': lastName,
              'email': user.email,
              'createdAt': Timestamp.now(),
              'shopId':"KkpauYXfRoOJ0oOv4xRK",
            });
          }

          bool isProfileComplete = await _fireStoreServices.isProfileComplete(user.uid);
          if (isProfileComplete) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ResponsiveLayout(
              mobileBody: MobileBody(),
              tabletBody: TabletBody(),
              desktopBody: DesktopBody(),
            )));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CompleteProfileForm(user: user)));
          }
        }
      } catch (e) {
        SMAHelperFunctions.showSnackBar(context, "Failed to sign in with Google: $e");
      }
    } else {
      // Google Sign-In for mobile
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        try {
          final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
          final User? user = userCredential.user;

          if (user != null) {
            final firstName = googleUser.displayName?.split(' ')[0] ?? '';
            final lastName = googleUser.displayName?.split(' ').sublist(1).join(' ') ?? '';

            // Check if the user already exists in Firestore
            final userDoc = FirebaseFirestore.instance.collection('admins').doc(user.uid);
            final docSnapshot = await userDoc.get();

            if (!docSnapshot.exists) {
              // Create a new user in Firestore
              await userDoc.set({
                'uid': user.uid,
                'firstName': firstName,
                'lastName': lastName,
                'email': user.email,
                'createdAt': Timestamp.now(),
                'shopId':"KkpauYXfRoOJ0oOv4xRK",
              });
            }

            bool isProfileComplete = await _fireStoreServices.isProfileComplete(user.uid);
            if (isProfileComplete) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ResponsiveLayout(
                mobileBody: MobileBody(),
                tabletBody: TabletBody(),
                desktopBody: DesktopBody(),
              )));
            } else {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CompleteProfileForm(user: user)));
            }
          }
        } catch (e) {
          SMAHelperFunctions.showSnackBar(context, "Failed to sign in with Google: $e");
        }
      } else {
        SMAHelperFunctions.showSnackBar(context, "Google Sign-In aborted");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: SMAColors.grey),
              borderRadius: BorderRadius.circular(100)),
          child: IconButton(
            onPressed: () => _signInWithGoogle(context),
            icon: const Image(
              width: SMASizes.iconMd,
              height: SMASizes.iconMd,
              image: AssetImage(SMAImages.google),
            ),
          ),
        ),
        const SizedBox(width: SMASizes.spaceBtwItems),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: SMAColors.grey),
              borderRadius: BorderRadius.circular(180)),
          child: IconButton(
            onPressed: () {
              SMAHelperFunctions.showSnackBar(context, "This feature will be available soon");
            },
            icon: const Image(
              width: SMASizes.iconMd,
              height: SMASizes.iconMd,
              image: AssetImage(SMAImages.facebook),
            ),
          ),
        ),
      ],
    );
  }
}
