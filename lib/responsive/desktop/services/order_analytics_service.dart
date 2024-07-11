import 'package:cloud_firestore/cloud_firestore.dart';

class OrderAnalyticsService {
  Stream<List<double>> streamAverageOrderValues() {
    DateTime sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
    return FirebaseFirestore.instance
        .collection("orders")
        .where("createdAt" , isGreaterThan: sevenDaysAgo)
        .snapshots()
        .map((querySnapshot) {
      List<double> averageOrderValues = [0, 0, 0, 0, 0, 0, 0]; // Initialize with 0 average values for each day

      for (var doc in querySnapshot.docs) {
        Timestamp createdAt = doc.get('createdAt');
        double orderValue = doc.get('totalBill'); // Adjust based on your Firestore schema

        // Calculate the day index (0 = Mon, 6 = Sun)
        int dayIndex = (createdAt.toDate().weekday + 6) % 7;

        // Accumulate order values per day
        averageOrderValues[dayIndex] += orderValue;
      }

      // Calculate average order value for each day
      for (int i = 0; i < averageOrderValues.length; i++) {
        int ordersCount = querySnapshot.docs
            .where((doc) => (doc.get('createdAt').toDate().weekday + 6) % 7 == i)
            .length;
        if (ordersCount > 0) {
          averageOrderValues[i] /= ordersCount;
        }
      }

      return averageOrderValues;
    });
  }
}
