import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orderease_admin/features/authentication/authentication/login/phone_auth.dart';
import 'package:orderease_admin/responsive/mobile/mobile_body.dart';
import 'package:orderease_admin/responsive/responsive_layout.dart';
import 'package:orderease_admin/services/firestore.dart';
import '../../../../navigation_menu.dart';
import '../../../../responsive/desktop/desktop_body.dart';
import '../../../../responsive/tablet/tablet_body.dart';
import 'complete_profile.dart';

class AuthPage extends StatelessWidget {
  AuthPage({Key? key}) : super(key: key);

  final FireStoreServices _fireStoreServices = FireStoreServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/gifs/error.gif"),
                  Text("Error: ${snapshot.error}"),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            // User is logged in, now check for user data in Firestore
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('admins')
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (userSnapshot.hasError) {
                  return Center(child: Text("Error: ${userSnapshot.error}"));
                } else if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  // No user data found in Firestore, navigate to PhoneAuthScreen
                  return PhoneAuthScreen();
                } else {
                  // User data found, check if profile is complete
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  return FutureBuilder<bool>(
                    future: _fireStoreServices.isProfileComplete(snapshot.data!.uid),
                    builder: (context, profileSnapshot) {
                      if (profileSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (profileSnapshot.hasError) {
                        return Center(child: Text("Error: ${profileSnapshot.error}"));
                      } else if (profileSnapshot.hasData && profileSnapshot.data == true) {
                        // Profile is complete, navigate to the main app
                        return const ResponsiveLayout(
                          mobileBody: MobileBody(),
                          tabletBody: TabletBody(),
                          desktopBody: DesktopBody(),
                        );
                      } else {
                        // Profile is incomplete, navigate to CompleteProfileForm
                        return CompleteProfileForm(user: snapshot.data!);
                      }
                    },
                  );
                }
              },
            );
          } else {
            // No user is logged in
            return PhoneAuthScreen();
          }
        },
      ),
    );
  }
}
