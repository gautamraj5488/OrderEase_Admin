import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String customerId;
  String customerName; // Update to non-final to fetch from Firestore
  final String message;
  final int ratings; // Overall ratings

  FeedbackModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.message,
    required this.ratings,
  });

  static Future<FeedbackModel> fromFirestore(DocumentSnapshot doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Fetch customerName from customerId
    String customerName = await fetchCustomerName(data['customerId']);

    return FeedbackModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: customerName,
      message: data['feedbackText'] ?? '',
      ratings: data['rating'] ?? 0,
    );
  }

  static Future<String> fetchCustomerName(String customerId) async {
    try {
      DocumentSnapshot customerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(customerId)
          .get();
      if (customerSnapshot.exists) {
        return customerSnapshot.get('firstName') ?? 'Unknown';
      }
    } catch (e) {
      print('Error fetching customer name: $e');
    }
    return 'Unknown';
  }
}
