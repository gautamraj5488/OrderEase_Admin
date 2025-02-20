

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../../../../../navigation_menu.dart';
import '../../../../../services/firestore.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/device/device_utility.dart';
import '../../../../../utils/helpers/helper_fuctions.dart';


class SMALoginForm extends StatefulWidget {
  final String FCMtoken;
  SMALoginForm({
    super.key, required this.FCMtoken,
  });

  @override
  State<SMALoginForm> createState() => _SMALoginFormState();
}

class _SMALoginFormState extends State<SMALoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  FireStoreServices _fireStoreServices = FireStoreServices();
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();



  Future<void> _handleForgotPassword(String email) async {
    try {
      SMAHelperFunctions.showSnackBar(context,"Password reset email sent");
      print('Password reset email sent');
    } catch (e) {
      SMAHelperFunctions.showSnackBar(context,"Error: $e");
      print('Error: $e');
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Row(
              children: [
                Image.asset("assets/gifs/loading.gif"),
                SizedBox(width: 20),
                Text('Loading...'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _hideLoadingDialog() {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  // showDialogBox() => showCupertinoDialog<String>(
  //   context: context,
  //   builder: (BuildContext context) => CupertinoAlertDialog(
  //     title: const Text('No Connection'),
  //     content: const Text('Please check your internet connectivity'),
  //     actions: <Widget>[
  //       TextButton(
  //         onPressed: () async {
  //           Navigator.pop(context, 'Cancel');
  //           setState(() => isAlertSet = false);
  //           isDeviceConnected =
  //           await InternetConnectionChecker().hasConnection;
  //           if (!isDeviceConnected && isAlertSet == false) {
  //             showDialogBox();
  //             setState(() => isAlertSet = true);
  //           }
  //         },
  //         child: const Text('OK'),
  //       ),
  //     ],
  //   ),
  // );

  void signUserIn() async {
    SMADeviceUtils.hideKeyboard(context);
    if (_formKey.currentState?.validate() != true) {
      SMADeviceUtils.vibrate(Duration(milliseconds: 500));
      return;
    }

    // bool isConnected = await SMADeviceUtils.hasInternetConnection();
    // if (!isConnected) {
    //   SMAHelperFunctions.showSnackBar(context,"No internet connection");
    //   SMADeviceUtils.vibrate(Duration(milliseconds: 500));
    //   return;
    // }

    _showLoadingDialog();

    if(await SMADeviceUtils.hasInternetConnection()){

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        ).then((value){
          _fireStoreServices.updateUserPasswordFromLogin(password: passwordController.text.trim(), uid: _auth.currentUser!.uid);
          _fireStoreServices.updateFCMtoken(FCMtoken: widget.FCMtoken, uid: _auth.currentUser!.uid);
        });
        SMAHelperFunctions.showSnackBar(context,"Signed in successfully");
        _hideLoadingDialog();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Navigation()),
        );
      } on FirebaseAuthException catch (e) {
        _hideLoadingDialog();

        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            SMADeviceUtils.vibrate(Duration(milliseconds: 100));
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided.';
            SMADeviceUtils.vibrate(Duration(milliseconds: 500));
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address.';
            SMADeviceUtils.vibrate(Duration(milliseconds: 500));
            break;
          case 'user-disabled':
            errorMessage = 'User has been disabled.';
            SMADeviceUtils.vibrate(Duration(milliseconds: 500));
            break;
          case 'invalid-credential':
            errorMessage = 'The supplied auth credential is incorrect';
            SMADeviceUtils.vibrate(Duration(milliseconds: 500));
            break;
          default:
            errorMessage = 'An unknown error occurred.';
            SMADeviceUtils.vibrate(Duration(milliseconds: 500));
        }

        SMAHelperFunctions.showSnackBar(context,errorMessage);
      } catch (e) {
        _hideLoadingDialog();
        SMAHelperFunctions.showSnackBar(context,'An error occurred. Please try again.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
        SMADeviceUtils.vibrate(Duration(milliseconds: 500));
      }
    }
    else{
      _hideLoadingDialog();
      SMAHelperFunctions.showSnackBar(context, "No internet");
      SMADeviceUtils.hideKeyboard(context);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SMASizes.spaceBtwSections),
        child: Column(
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.arrow_forward_ios),
                  labelText: SMATexts.email),
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
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.password),
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
            ),
            obscureText: !_passwordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
            const SizedBox(height: SMASizes.spaceBtwInputFields / 2),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                  onPressed: () async {
                    String? email = await showDialog<String>(
                      context: context,
                      builder: (BuildContext context) {
                        TextEditingController emailController = TextEditingController();
                        return AlertDialog(
                          title: Text('Enter your email'),
                          content: TextField(
                            controller: emailController,
                            decoration: InputDecoration(hintText: 'Email'),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Submit'),
                              onPressed: () {
                                Navigator.of(context).pop(emailController.text);
                              },
                            ),
                          ],
                        );
                      },
                    );

                    if (email != null && email.isNotEmpty) {
                      await _handleForgotPassword(email);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('A password reset email has been sent.')),
                      );
                    }
                  },child: const Text(SMATexts.forgetPassword)),
            ]),
            const SizedBox(height: SMASizes.spaceBtwSections),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async{
                      signUserIn();
                    },
                    child: const Text(SMATexts.signIn))),
            const SizedBox(height: SMASizes.spaceBtwItems),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }
}

