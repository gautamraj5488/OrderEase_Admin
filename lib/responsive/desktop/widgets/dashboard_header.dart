import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:orderease_admin/common/styles/spacing_style.dart';
import 'package:orderease_admin/utils/constants/colors.dart';
import 'package:orderease_admin/utils/device/device_utility.dart';
import 'package:orderease_admin/utils/theme/custom_theme/text_theme.dart';

import '../../../utils/helpers/helper_fuctions.dart';

class DashboardHeader extends StatefulWidget {
   DashboardHeader({super.key});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  int _currentIndex = 0;

  List<Widget> _buildDotsIndicator() {
    List<Widget> dots = [];
    for (int i = 0; i < 2; i++) { // Adjust the count based on the number of pages
      dots.add(
        Container(
          margin: EdgeInsets.all(5),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentIndex == i ? Colors.blue : Colors.grey,
          ),
        ),
      );
    }
    return dots;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder<int>(
            future: _fetchTotalRevenue(), // Future function to fetch total revenue
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return DashboardCard(
                  title: 'Total Revenue',
                  value: 'Loading...', // Placeholder while loading
                );
              } else if (snapshot.hasError) {
                return DashboardCard(
                  title: 'Total Revenue',
                  value: 'Error', // Display error message
                );
              } else {
                return DashboardCard(
                  title: 'Total Revenue',
                  value: '\u{20B9} ${snapshot.data ?? 0}', // Display fetched total revenue
                );
              }
            },
          ),
          FutureBuilder<int>(
            future: _fetchPendingRevenue(), // Future function to fetch total revenue
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return DashboardCard(
                  title: 'Total Pending Revenue',
                  value: 'Loading...', // Placeholder while loading
                );
              } else if (snapshot.hasError) {
                return DashboardCard(
                  title: 'Total Pending Revenue',
                  value: 'Error', // Display error message
                );
              } else {
                return DashboardCard(
                  title: 'Total Pending Revenue',
                  value: '\u{20B9} ${snapshot.data ?? 0}', // Display fetched total revenue
                );
              }
            },
          ),
          FutureBuilder<int>(
            future: _fetchTotalOrders(), // Future function to fetch total revenue
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return DashboardCard(
                  title: 'Total Orders',
                  value: 'Loading...', // Placeholder while loading
                );
              } else if (snapshot.hasError) {
                return DashboardCard(
                  title: 'Total Orders',
                  value: 'Error', // Display error message
                );
              } else {
                return DashboardCard(
                  title: 'Total Orders',
                  value: '${snapshot.data ?? 0}',
                );
              }
            },
          ),
          FutureBuilder<double>(
            future: _fetchTotalSpaceOccupied(), // Future function to fetch total revenue
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return DashboardCard(
                  title: 'Total Space Occupied',
                  value: 'Loading...', // Placeholder while loading
                );
              } else if (snapshot.hasError) {
                return DashboardCard(
                  title: 'Total Space Occupied',
                  value: 'Error', // Display error message
                );
              } else {
                return DashboardCard(
                  title: 'Total Space Occupied',
                  value: '${snapshot.data ?? 0} %',
                );
              }
            },
          ),

        ],
      ),
    );
  }

  Future<int> _fetchTotalRevenue() async {
    int totalRevenue = 0;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'Completed')
          .get();

      querySnapshot.docs.forEach((doc) {
        totalRevenue += int.parse((doc['totalBill'] ?? 0).toString());
      });

      return totalRevenue;
    } catch (e) {
      print("Error fetching: $e");
      return 0;
    }
  }

  Future<int> _fetchPendingRevenue() async {
    int totalRevenue = 0;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('status', isNotEqualTo: 'Completed')
          .get();

      querySnapshot.docs.forEach((doc) {
        totalRevenue += int.parse((doc['totalBill'] ?? 0).toString());
      });

      return totalRevenue;
    } catch (e) {
      print("Error fetching: $e");
      return 0;
    }
  }

  Future<int> _fetchTotalOrders() async {
    int totalOrders = 0;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .get();

      totalOrders = querySnapshot.size;

      return totalOrders;
    } catch (e) {
      print("Error fetching: $e");
      return 0;
    }
  }

  Future<double> _fetchTotalSpaceOccupied() async {
    try {
      // Fetch the current user's UID
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        print("User not logged in.");
        return 0.0; // Handle case where user is not logged in
      }

      // Fetch shopId from admins collection
      DocumentSnapshot adminSnapshot =
      await FirebaseFirestore.instance.collection('admins').doc(uid).get();
      if (!adminSnapshot.exists) {
        print("Admin document not found for current user.");
        return 0.0; // Handle case where admin document does not exist
      }

      String? shopId = adminSnapshot['shopId'];
      if (shopId == null) {
        print("ShopId not found in admin document.");
        return 0.0; // Handle case where shopId is not found
      }

      // Fetch numberOfTables from shops collection using shopId
      DocumentSnapshot shopSnapshot =
      await FirebaseFirestore.instance.collection('shops').doc(shopId).get();
      if (!shopSnapshot.exists) {
        print("Shop document not found for shopId: $shopId");
        return 0.0; // Handle case where shop document does not exist
      }

      int numberOfTables = shopSnapshot['numberOfTables'] ?? 1;
      print("Number of Tables: $numberOfTables");

      // Fetch total completed orders count from orders collection
      QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
          .collection("orders")
          .where("status", isNotEqualTo: "Completed")
          .get();
      int totalCompletedOrders = ordersSnapshot.size;
      print("Total incompleted Orders: $totalCompletedOrders");

      // Calculate percentage occupied
      double percentageOccupied = (totalCompletedOrders / numberOfTables) * 100;
      print("Percentage Occupied: $percentageOccupied");

      return percentageOccupied.toPrecision(1);
    } catch (e) {
      print("Error fetching: $e");
      return 0.0; // Return a default value or handle error as needed
    }
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool dark = SMAHelperFunctions.isDarkMode(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double widthFactor;
    // Determine width factor based on screen size
    if (screenWidth < 600) {
      // Mobile screens
      widthFactor = 0.35;
    } else if (screenWidth < 1100) {
      // Tablet screens
      widthFactor = 0.33;
    } else {
      // Desktop screens
      widthFactor = 0.25;
    }

    double calculatedWidth = screenWidth * widthFactor;
    return Container(
      width: calculatedWidth,
      height: 140,
      padding: SMASpacingStyle.allSidePadding,
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: dark? SMAColors.dark:SMAColors.light,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: SMAColors.darkGrey,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            value,
            style: dark
                ? SMATextTheme.darkTextTheme.headlineMedium
                : SMATextTheme.lightTextTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}
