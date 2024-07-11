import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orderease_admin/utils/constants/colors.dart';
import 'package:orderease_admin/utils/helpers/helper_fuctions.dart';



class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  // final FireStoreServices _firestoreServices = FireStoreServices();
  final FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  void initState() {
    super.initState();
  }



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final dark = SMAHelperFunctions.isDarkMode(context);

    final List<Widget> _pages = [
      // HomeScreen(),
      // SearchScreen(),
      // Scaffold(),
      // ProfilePage(uid: _auth.currentUser!.uid,),
    ];

    return Scaffold(

        bottomNavigationBar: NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: dark ? SMAColors.black : Colors.white,
          indicatorColor: dark
              ? SMAColors.white.withOpacity(0.1)
              : SMAColors.black.withOpacity(0.1),
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
        body: _pages[_selectedIndex]);
  }
}


