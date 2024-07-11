import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:orderease_admin/responsive/email_helper/email_helper.dart';
import 'package:url_launcher/url_launcher_string.dart';
// import '../features/authentication/screens/login/helper/email_helper.dart';
// import '../features/authentication/screens/login/login.dart';

class FireStoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }
  //
  // void sendEmail(String email, String firstName, String lastName) async {
  //   try {
  //     await EmailHelper.sendWelcomeEmail(email, firstName+" "+lastName);
  //     print('Welcome email sent successfully');
  //   } catch (e) {
  //     print('Error sending email: $e');
  //   }
  // }

  Future<bool> isDeviceConnected() async {
    try {
      await canLaunchUrlString("google.com");
      return true;
    } catch (e) {
      return false;
    }
  }


  Future<bool> checkUserExists(String uid) async {
    final userRef = _firestore.collection('users').doc(uid);
    final userDoc = await userRef.get();
    return userDoc.exists;
  }

  Stream<DocumentSnapshot> getCartItems(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  Future<void> updateItemInCart(String userId, String itemId, int quantity,
      String name, double price, String imageUrl) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(userId);
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        print("User document does not exist.");
        return;
      }

      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      List cartItems = userData['cart'] ?? [];

      bool itemFound = false;
      // Update the quantity of the item if it exists in the cart
      for (var item in cartItems) {
        if (item['itemId'] == itemId) {
          item['quantity'] = quantity;
          itemFound = true;
          break;
        }
      }

      // If the item does not exist, add it to the cart
      if (!itemFound) {
        cartItems.add({
          'itemId': itemId,
          'name': name,
          'price': price,
          'imageUrl': imageUrl,
          'quantity': quantity,
        });
        print("Item with itemId $itemId added to cart.");
      } else {
        print("Item with itemId $itemId updated in cart.");
      }

      await userDoc.update({'cart': cartItems});
      print("Cart updated successfully.");
    } catch (e) {
      print("Error updating item in cart: $e");
    }
  }

  Future<void> removeItemFromCart(String userId, String itemId) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(userId);
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        print("User document does not exist.");
        return;
      }

      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      List cartItems = userData['cart'] ?? [];

      cartItems.removeWhere((item) => item['itemId'] == itemId);

      await userDoc.update({'cart': cartItems});
      print("Item removed from cart successfully.");
    } catch (e) {
      print("Error removing item from cart: $e");
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      // Update the 'cart' field to an empty array for the user document
      await _firestore.collection('users').doc(userId).update({
        'cart': [],
      });
    } catch (error) {
      print('Error clearing cart: $error');
      throw error; // Propagate the error up to handle it appropriately
    }
  }

  Future<void> createUserInFirestore(User user, String email) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference userDoc =
        firestore.collection('users').doc(user.uid);

    userDoc.set({
      'uid': user.uid,
      'phoneNumber': user.phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
      'email': email,
    }, SetOptions(merge: true)).catchError((e) {
      print('Error creating user: $e');
    });
  }

  Future<bool> isProfileComplete(String uid) async {
    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('admins').doc(uid).get();
    if (userDoc.exists) {
      var data = userDoc.data() as Map<String, dynamic>;
      return data.containsKey('firstName') &&
          data['firstName'].isNotEmpty &&
          data.containsKey('lastName') &&
          data['lastName'].isNotEmpty &&
          data.containsKey('email') &&
          data['email'].isNotEmpty &&
          data.containsKey('phoneNumber') &&
          data['phoneNumber'].isNotEmpty;
    }
    return false;
  }

  Future<void> createAdminInFirestore(
      User user, String email, String firstName, String lastName, String shopId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference userDoc =
        firestore.collection('admins').doc(user.uid);

    userDoc.set({
      'uid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'shopId':shopId,
    }, SetOptions(merge: true)).catchError((e) {
      print('Error creating user: $e');
    });
  }

  Stream<List<Map<String, dynamic>>> streamOrders() {
    return _firestore
        .collection('orders')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> orders = [];

      for (var doc in snapshot.docs) {
        try {
          String userId = doc['userId'];
          DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(userId).get();

          if (userDoc.exists) {
            var createdAt = (doc['createdAt'] as Timestamp).toDate();
            var formattedTime =
                DateFormat('hh:mm a, dd MMM yyyy').format(createdAt);
            var status = doc['status'] ?? 'Unknown';

            orders.add({
              'orderId': doc.id,
              'name': (userDoc['firstName'] ?? '') +
                  " " +
                  (userDoc['lastName'] ?? ''),
              'phone': userDoc['phoneNumber'] ?? '',
              'time': formattedTime,
              'table': doc['tableNumber'] ?? '',
              'items': (doc['items'] as List)
                  .map((item) => {
                        'item': item['name'] ?? '',
                        'price': item['price'] ?? 0.0
                      })
                  .toList(),
              'total': doc['totalBill'] ?? 0.0,
              'status': status,
              'createdAt': createdAt,
            });
          }
        } catch (e) {
          print("Error processing order: $e");
        }
      }

      // Sort orders by createdAt (oldest to newest)
      orders.sort((a, b) {
        var aCreatedAt = a['createdAt'] as DateTime;
        var bCreatedAt = b['createdAt'] as DateTime;

        if (a['status'] == 'Completed' && b['status'] != 'Completed') {
          return 1; // Place completed orders at the end
        } else if (a['status'] != 'Completed' && b['status'] == 'Completed') {
          return -1; // Place non-completed orders before completed orders
        } else {
          return aCreatedAt
              .compareTo(bCreatedAt); // Sort by createdAt for other cases
        }
      });

      return orders;
    });
  }



  Future<String?> getCurrentUserShopId() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('admins').doc(user.uid);

      try {
        DocumentSnapshot doc = await userDocRef.get();

        if (doc.exists) {
          String shopId = doc['shopId'];
          return shopId;
        } else {
          print('User document does not exist');
          return null;
        }
      } catch (error) {
        print('Failed to get user document: $error');
        return null;
      }
    } else {
      print('User is not authenticated');
      return null; // or handle this case accordingly
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      // Fetch order details to get userId
      DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection("orders")
          .doc(orderId)
          .get();

      if (!orderSnapshot.exists) {
        print("Order not found.");
        return;
      }

      String userId = orderSnapshot.get('userId');

      // Fetch user details (email and name)
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userSnapshot.exists) {
        print("User not found.");
        return;
      }

      String email = userSnapshot.get('email');
      String name = userSnapshot.get('firstName');

      // Update order status
      await FirebaseFirestore.instance
          .collection("orders")
          .doc(orderId)
          .update({"status": newStatus});

      if(newStatus == "Preparing"){
        EmailHelper.sendOrderPreparationEmail(email, name, orderId);
      } else if(newStatus == "Completed"){
        EmailHelper.sendOrderReadyEmail(email, name, orderId);
      }

    } catch (e) {
      print("Error updating order status: $e");
    }
  }


  Future<List<Map<String, dynamic>>> getCoupons(String shopId) async {
    List<Map<String, dynamic>> coupons = [];

    try {
      QuerySnapshot couponSnapshot = await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('coupons')
          .get();

      for (var doc in couponSnapshot.docs) {
        coupons.add(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching coupons: $e');
    }

    return coupons;
  }

  Future<bool> isUsernameInUse(String username) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      print("Username Query Result: ${result.docs}");
      return result.docs.isNotEmpty;
    } catch (e) {
      print("Error checking username: $e");
      return false; // Return false in case of an error
    }
  }

  Future<bool> isEmailInUse(String email) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      print("Email Query Result: ${result.docs}");
      return result.docs.isNotEmpty;
    } catch (e) {
      print("Error checking email: $e");
      return false; // Return false in case of an error
    }
  }

  Future<List<DocumentSnapshot>> getSharedPosts(String userId) async {
    try {
      // Query shared_posts collection where sharedTo field is equal to userId
      QuerySnapshot querySnapshot = await _firestore
          .collection('shared_posts')
          .where('sharedTo', isEqualTo: userId)
          .get();

      // Return list of DocumentSnapshots
      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching shared posts: $e');
      throw e; // Throw error to handle it in calling function
    }
  }

  Future<int> getUnreadMessageCount(
      String currentUser, String otherUser) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(currentUser).get();
    Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

    if (data['unreadMessages'] == null) {
      await _firestore
          .collection('users')
          .doc(currentUser)
          .update({'unreadMessages': {}});
      return 0;
    }

    Map<String, dynamic> unreadMessages =
        data['unreadMessages'] as Map<String, dynamic>;
    return unreadMessages[otherUser] ?? 0;
  }

  Future<void> incrementUnreadMessageCount(String receiverId) async {
    DocumentReference userRef = _firestore.collection('users').doc(receiverId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot userDoc = await transaction.get(userRef);
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

      Map<String, int> unreadMessages;
      if (data['unreadMessages'] == null) {
        unreadMessages = {};
      } else {
        unreadMessages = Map<String, int>.from(data['unreadMessages']);
      }

      unreadMessages[_auth.currentUser!.uid] =
          (unreadMessages[_auth.currentUser!.uid] ?? 0) + 1;
      transaction.update(userRef, {'unreadMessages': unreadMessages});
    });
  }

  Future<void> resetUnreadMessageCount(
      String currentUser, String senderId) async {
    DocumentReference userRef = _firestore.collection('users').doc(currentUser);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot userDoc = await transaction.get(userRef);
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

      Map<String, int> unreadMessages;
      if (data['unreadMessages'] == null) {
        unreadMessages = {};
      } else {
        unreadMessages = Map<String, int>.from(data['unreadMessages']);
      }

      unreadMessages[senderId] = 0;
      transaction.update(userRef, {'unreadMessages': unreadMessages});
    });
  }
  // logout(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Container(
  //         height: 200,
  //         width: double.infinity,
  //         decoration: BoxDecoration(
  //           //color: Colors.white,
  //             borderRadius: BorderRadius.only(topRight: Radius.circular(12),topLeft: Radius.circular(12))
  //         ),
  //
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           children: <Widget>[
  //             Text('Are you sure to Logout ?'),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceAround,
  //               children: [
  //                 ElevatedButton(
  //                   onPressed: () {
  //                     FirebaseAuth.instance.signOut();
  //                     Navigator.pop(context);
  //                     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context)=> LoginScreen()), (route)=>false);
  //
  //                   },
  //                   child: Text('Yes'),
  //                 ),
  //                 OutlinedButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                   child: Text('Close'),
  //                 ),
  //               ],
  //             )
  //           ],
  //         ),
  //       );
  //     },
  //   );
  //   // FirebaseAuth.instance.signOut();
  //   // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context)=> LoginScreen()), (route)=>false);
  // }

  // Future<String?> getFCMToken() async {
  //   return await FirebaseMessaging.instance.getToken();
  // }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(uid) async {
    User? user = getCurrentUser();
    if (user != null) {
      return await _firestore.collection('users').doc(uid).get();
    } else {
      throw Exception("No user logged in");
    }
  }

  Future<void> createUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String uid,
    required String FCMtoken,
    required String profilePicture,
    required List<String> following,
    required List<String> followers,
    required List<String> requested,
    required List<String> requestToConfirm,
  }) async {
    try {
      // Create a new user document in Firestore
      await _firestore.collection('users').doc(getCurrentUser()!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'profilePic': profilePicture,
        'phoneNumber': phoneNumber,
        'password': password,
        'createdAt': FieldValue.serverTimestamp(),
        'uis': uid,
        'FCMtoken': FCMtoken,
        'following': following,
        'followers': followers,
        'requested': requested,
        'requestToConfirm': requestToConfirm,
        'messageUpdatedAt': FieldValue.serverTimestamp(),
      });
      print("User created successfully");
    } catch (e) {
      print("Error creating user: $e");
    }
  }

  Future<void> updateUser({
    required String firstName,
    required String lastName,
    required String uid,
  }) async {
    try {
      // Update an existing user document in Firestore
      await _firestore.collection('users').doc(uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print("User updated successfully");
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  Future<void> updateUserPasswordFromLogin({
    required String password,
    required String uid,
  }) async {
    try {
      // Update an existing user document in Firestore
      await _firestore.collection('users').doc(uid).update({
        'password': password,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print("User updated successfully");
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  Future<void> updateMessageTime({
    required String uid,
  }) async {
    try {
      // Update an existing user document in Firestore
      await _firestore.collection('users').doc(uid).update({
        'messageUpdatedAt': FieldValue.serverTimestamp(),
      });
      print("User updated successfully");
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  Future<void> updateFCMtoken({
    required String FCMtoken,
    required String uid,
  }) async {
    try {
      // Update an existing user document in Firestore
      await _firestore.collection('users').doc(uid).update({
        'FCMtoken': FCMtoken,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print("User updated successfully");
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  // AIzaSyAMcw6jDBdoKvCC265Wdde0BQ2dU5CzRzs
  Future<void> sendNotification(String serverKey, String recipientToken) async {
    final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/social-media-app-436b7/messages:send');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $serverKey',
    };

    final body = {
      'message': {
        'token': recipientToken,
        'notification': {
          'title': 'Friend Request',
          'body': 'You have received a friend request',
        },
      },
    };

    final response =
        await http.post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.reasonPhrase}');
    }
  }
}
