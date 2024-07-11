import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orderease_admin/common/styles/spacing_style.dart';
import 'package:orderease_admin/features/authentication/authentication/login/authpage.dart';
import 'package:orderease_admin/utils/constants/colors.dart';
import 'package:orderease_admin/utils/constants/sizes.dart';
import 'package:orderease_admin/utils/helpers/helper_fuctions.dart';

import '../../../utils/constants/text_strings.dart';
import '../screens/profile.dart';

class DesktopDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTap;

   DesktopDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemTap,
  }) : super(key: key);

  @override
  State<DesktopDrawer> createState() => _DesktopDrawerState();
}

class _DesktopDrawerState extends State<DesktopDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? displayName = '';
  String? displayPic = '';

  Future<void> _logout(BuildContext context) async {
    try{
      await FirebaseAuth.instance.signOut();
      SMAHelperFunctions.pushAndRemoveUntil(context, AuthPage());
    } catch(e){
      print("Error logging out: $e");
    }
    // Handle logout logic
  }

  @override
  void initState() {
    super.initState();
    fetchDisplayName();
    fetchDisplayPic();
  }

  Future<void> fetchDisplayName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        displayName = user.displayName;
      });

      DocumentSnapshot adminSnapshot =
      await _firestore.collection('admins').doc(user.uid).get();
      if (adminSnapshot.exists) {
        setState(() {
          displayName = adminSnapshot.get('firstName') + ' ' + adminSnapshot.get('lastName') ?? " ";
        });
      }
    }
  }

  Future<void> fetchDisplayPic() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        displayPic = user.photoURL;
      });

      DocumentSnapshot adminSnapshot =
      await _firestore.collection('admins').doc(user.uid).get();
      if (adminSnapshot.exists) {
        setState(() {
          displayPic = adminSnapshot.get('profilePic');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool dark = SMAHelperFunctions.isDarkMode(context);
    return Container(
      width: 300,
      color: SMAColors.black,
      padding: SMASpacingStyle.allSidePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: SMAColors.dark,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              'OrderEase',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20.0), // Adjust spacing as needed
          _buildDrawerItem("Dashboard", Icons.dashboard, 0),
          _buildDrawerItem("Orders", Icons.shopping_bag, 1),
          _buildDrawerItem("Menu", Icons.restaurant_menu, 2),
          _buildDrawerItem("Coupons", Icons.local_offer, 3),
          _buildDrawerItem("Feedbacks", Icons.report, 4),
          Spacer(),
          InkWell(
            onTap: (){
              _logout(context);
            },
            child: SizedBox(
              width: double.infinity,
              child:  Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                child: Row(
                  children: [
                    Icon(Icons.logout,color: SMAColors.darkGrey,),
                    SizedBox(width: 16.0),
                    Text(
                      SMATexts.logOut,
                      style: TextStyle(fontSize: 16.0,color: SMAColors.darkGrey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ProfileTile(
            displayName: displayName ?? 'Loading...',
            imageUrl: displayPic ?? 'https://img.freepik.com/premium-photo/there-is-cat-that-is-sitting-ledge-chinese-garden-generative-ai_900396-35755.jpg',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, int index) {
    bool isSelected = index == widget.selectedIndex;
    return InkWell(
      onTap: () => widget.onItemTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ?SMAColors.secondary.withOpacity(0.1):null,
          borderRadius: BorderRadius.circular(SMASizes.borderRadiusMd),
          border:isSelected? Border.all(
            color: SMAColors.secondary.withOpacity(0.5)
          ):null
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? SMAColors.secondary : SMAColors.darkGrey,
              ),
              SizedBox(width: 16.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.0,
                  color: isSelected ? SMAColors.secondary  : SMAColors.darkGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ProfileTile extends StatelessWidget {
  final String displayName;
  final VoidCallback onTap;
  final String imageUrl;

  const ProfileTile({
    Key? key,
    required this.displayName,
    required this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
              radius: 20.0,
            ),
            SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(fontSize: 16.0),
                ),
                Text(
                  "Administration",
                  style: TextStyle(fontSize: SMASizes.fontSizeSm, color: SMAColors.darkGrey),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
