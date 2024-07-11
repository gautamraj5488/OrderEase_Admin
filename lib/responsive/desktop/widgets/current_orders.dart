import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orderease_admin/services/firestore.dart';

import '../../../common/styles/spacing_style.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_fuctions.dart';
import '../../../utils/theme/custom_theme/text_theme.dart';

class CurrentOrders extends StatefulWidget {
  const CurrentOrders({super.key});

  @override
  State<CurrentOrders> createState() => _CurrentOrdersState();
}

class _CurrentOrdersState extends State<CurrentOrders> {

  final FireStoreServices _fireStoreServices = FireStoreServices();
  Stream<List<Map<String, dynamic>>> _streamCurrentOrders() {
      return FirebaseFirestore.instance
          .collection("orders")
          .where('status', isNotEqualTo: 'Completed')
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();
      });
  }



  Future<String> _fetchUserName(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        String? firstName = userData.containsKey("firstName") ? userData["firstName"] : null;
        String? phoneNumber = userData.containsKey("phoneNumber") ? userData["phoneNumber"] : null;
        return firstName ?? phoneNumber ?? "";
      } else {
        return "";
      }
    } catch (e) {
      print("Error fetching user name: $e");
      return "";
    }
  }


  @override
  Widget build(BuildContext context) {
    bool dark = SMAHelperFunctions.isDarkMode(context);
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _streamCurrentOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Container(
            height: 400,
            //width: width * 0.3,
            padding: SMASpacingStyle.allSidePadding,
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: dark ? SMAColors.dark : SMAColors.light,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Orders",
                  style: dark
                      ? SMATextTheme.darkTextTheme.headlineMedium
                      : SMATextTheme.lightTextTheme.headlineMedium,
                ),
                Expanded(
                  child: Center(
                    child: Text("Error fetching orders"),
                  ),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            height: 400,
            //width: width * 0.3,
            padding: SMASpacingStyle.allSidePadding,
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: dark ? SMAColors.dark : SMAColors.light,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Orders",
                  style: dark
                      ? SMATextTheme.darkTextTheme.headlineMedium
                      : SMATextTheme.lightTextTheme.headlineMedium,
                ),
                Expanded(
                  child: Center(
                    child: Text("No pending orders"),
                  ),
                ),
              ],
            ),
          );
        } else {
          List<Map<String, dynamic>> orders = snapshot.data!;
          double width = MediaQuery.of(context).size.width;
          return Container(
            height: 400,
            //width: width * 0.3,
            padding: SMASpacingStyle.allSidePadding,
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: dark ? SMAColors.dark : SMAColors.light,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Orders",
                  style: dark
                      ? SMATextTheme.darkTextTheme.headlineMedium
                      : SMATextTheme.lightTextTheme.headlineMedium,
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> order = orders[index];
                      String userId = order['userId'] ?? '';
                      String key = order['orderId'] ?? index.toString();
                      return Dismissible(
                        key: Key(key),
                        direction: DismissDirection.horizontal,
                        background: Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Icon(Icons.check, color: Colors.white),
                          ),
                        ),
                        secondaryBackground: Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Icon(Icons.check, color: Colors.white),
                          ),
                        ),

                        onDismissed: (direction) async {
                          String currentStatus = order['status'];
                          String newStatus;
                          if (currentStatus == 'Order Accepted') {
                            newStatus = 'Preparing';
                          } else if (currentStatus == 'Preparing') {
                            newStatus = 'Completed';
                          } else {
                            newStatus = currentStatus;
                          }

                          bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Confirm Status Change"),
                                content: Text("Are you sure you want to change the status to '$newStatus'?"),
                                actions: [
                                  TextButton(
                                    child: Text("Cancel"),
                                    onPressed: () {
                                      Navigator.of(context).pop(false); // Dismiss dialog and cancel action
                                    },
                                  ),
                                  TextButton(
                                    child: Text("Confirm"),
                                    onPressed: () {
                                      Navigator.of(context).pop(true); // Dismiss dialog and confirm action
                                    },
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            setState(() {
                              orders[index]['status'] = newStatus;
                            });

                            await _fireStoreServices.updateOrderStatus(order['orderId'], newStatus);
                          } else {
                            setState(() {});
                          }
                        },
                        confirmDismiss: (direction) async {
                          return true;
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: FutureBuilder<String>(
                              future: _fetchUserName(userId),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState == ConnectionState.waiting) {
                                  return Text('Loading user...');
                                } else if (userSnapshot.hasError) {
                                  return Text('Error loading user');
                                } else {
                                  String userName = userSnapshot.data ?? 'Unknown User';
                                  return Text('User: $userName');
                                }
                              },
                            ),
                            subtitle: Text('Status: ${order['status']}'),
                            trailing: Text('Total: \u{20B9}${order['totalBill']}'),
                            onTap: () {},
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
