import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../common/styles/spacing_style.dart';
import '../../../../navigation_menu.dart';
import '../../../../responsive/desktop/desktop_body.dart';
import '../../../../responsive/mobile/mobile_body.dart';
import '../../../../responsive/responsive_layout.dart';
import '../../../../responsive/tablet/tablet_body.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';

class CompleteProfileForm extends StatefulWidget {
  final User user;

  CompleteProfileForm({required this.user});

  @override
  _CompleteProfileFormState createState() => _CompleteProfileFormState();
}

class _CompleteProfileFormState extends State<CompleteProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.user.displayName?.split(' ')[0] ?? '';
    _lastNameController.text = widget.user.displayName?.split(' ').sublist(1).join(' ') ?? '';
    _emailController.text = widget.user.email ?? '';

    // Fetch user data from Firestore
    FirebaseFirestore.instance.collection('admins').doc(widget.user.uid).get().then((doc) {
      if (doc.exists) {
        setState(() {
          _phoneNumberController.text = doc.data()!['phoneNumber'] ?? '';
        });
      }
    }).catchError((error) {
      print("Error getting user data: $error");
    });
  }


  Future<void> _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      final userDoc = FirebaseFirestore.instance.collection('admins').doc(widget.user.uid);
      await userDoc.set({
        'uid': widget.user.uid,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'phoneNumber': _phoneNumberController.text,
        'email': _emailController.text,
        'createdAt': Timestamp.now(),
        'shopId': "KkpauYXfRoOJ0oOv4xRK",
      }, SetOptions(merge: true));
      print("User profile successfully updated with shopId.");
      // Navigate to the main screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ResponsiveLayout(
        mobileBody: MobileBody(),
        tabletBody: TabletBody(),
        desktopBody: DesktopBody(),
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete Your Profile')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
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
                        padding: SMASpacingStyle.allSidePadding,
                        child: Card(
                          child: Container(
                            padding: SMASpacingStyle.allSidePadding,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _firstNameController,
                                  decoration:
                                  InputDecoration(labelText: 'First Name'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your first name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: SMASizes.spaceBtwInputFields,
                                ),
                                TextFormField(
                                  controller: _lastNameController,
                                  decoration:
                                  InputDecoration(labelText: 'Last Name'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your last name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: SMASizes.spaceBtwInputFields,
                                ),
                                TextFormField(
                                  controller: _emailController,
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
                                const SizedBox(
                                  height: SMASizes.spaceBtwInputFields,
                                ),
                                TextFormField(
                                  controller: _phoneNumberController,
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
                                const SizedBox(
                                  height: SMASizes.spaceBtwInputFields,
                                ),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _submitProfile,
                                    child: Text('Save Profile'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
