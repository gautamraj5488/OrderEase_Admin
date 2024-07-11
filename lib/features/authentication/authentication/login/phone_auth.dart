import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/widgets.login_signup/form_divider.dart';
import '../../../../common/widgets.login_signup/social_button.dart';
import '../../../../navigation_menu.dart';
import '../../../../responsive/desktop/desktop_body.dart';
import '../../../../responsive/mobile/mobile_body.dart';
import '../../../../responsive/responsive_layout.dart';
import '../../../../responsive/tablet/tablet_body.dart';
import '../../../../services/firestore.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/helpers/helper_fuctions.dart';
import 'complete_profile.dart';
import 'helper/email_helper.dart';
import 'widgets/header.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FireStoreServices _fireStoreServices = FireStoreServices();
  String _verificationId = '';
  bool _isOtpSent = false;
  bool _isLoading = false; // Add loading state
  final FocusNode _pinPutFocusNode = FocusNode();

  void _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+91${_phoneController.text}",
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          setState(() {
            _isLoading = false; // Hide loading indicator
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false; // Hide loading indicator
          });
          if (e.code == 'invalid-phone-number') {
            SMAHelperFunctions.showSnackBar(
                context, 'The provided phone number is not valid.');
            print('The provided phone number is not valid.');
          } else {
            SMAHelperFunctions.showSnackBar(
                context, 'Phone number verification failed: ${e.message}');
            print('Phone number verification failed: ${e.message}');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
            _isLoading = false; // Hide loading indicator
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false; // Hide loading indicator
          });
        },
      );
    }
  }

  void _verifyOtp() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: _otpController.text,
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null) {
        // Check if user already exists in Firestore
        bool userExists = await _fireStoreServices.checkUserExists(user.uid);

        if (!userExists) {
          // If user doesn't exist, create their profile
          final email = emailController.text;
          final firstName = user.displayName?.split(' ')[0] ?? 'User';
          final lastName = user.displayName?.split(' ').sublist(1).join(' ') ?? '';
          final shopId = 'KkpauYXfRoOJ0oOv4xRK';
          await EmailHelper.sendWelcomeEmail(email, "$firstName $lastName");
          await _fireStoreServices.createAdminInFirestore(user, email, firstName, lastName, shopId);
        }

        // Check if profile is complete
        bool isProfileComplete = await _fireStoreServices.isProfileComplete(user.uid);
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
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
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
      SMAHelperFunctions.showSnackBar(context, 'Failed to sign in: $e');
      print('Failed to sign in: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final dark = SMAHelperFunctions.isDarkMode(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth < 500 ? constraints.maxWidth : 500;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: SMASpacingStyle.paddingWithAppBarHeight,
                    child: Card(
                      child: Container(
                        padding: SMASpacingStyle.allSidePadding,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SMALoginHeader(dark: dark),
                              const SizedBox(height: SMASizes.spaceBtwSections),
                              if (_isLoading) ...[
                                Center(child: CircularProgressIndicator()), // Show loading indicator
                                const SizedBox(height: SMASizes.spaceBtwSections),
                              ] else if (!_isOtpSent) ...[
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone Number',
                                    prefix: Text('+91 '),
                                    prefixStyle: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your phone number';
                                    } else if (value.length != 10) {
                                      return 'Phone number must be 10 digits';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: SMASizes.spaceBtwInputFields),
                                TextFormField(
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.alternate_email),
                                    labelText: SMATexts.email,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: SMASizes.spaceBtwInputFields),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _sendOtp,
                                    child: const Text('Send OTP'),
                                  ),
                                ),
                                const SizedBox(height: SMASizes.spaceBtwSections),
                              ] else ...[
                                TextFormField(
                                  controller: _otpController,
                                  decoration: const InputDecoration(labelText: 'OTP'),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the OTP';
                                    } else if (value.length != 6) {
                                      return 'OTP must be 6 digits';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: SMASizes.spaceBtwSections),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _verifyOtp,
                                    child: const Text('Verify OTP'),
                                  ),
                                ),
                                const SizedBox(height: SMASizes.spaceBtwSections),
                              ],
                              SMAFormDivider(dark: dark, text: SMATexts.orSignInWith),
                              const SizedBox(height: SMASizes.spaceBtwSections),
                              SMASocialButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
