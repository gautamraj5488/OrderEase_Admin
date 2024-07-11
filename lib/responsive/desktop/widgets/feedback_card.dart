import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../modals/feedback.dart';

class FeedbackCard extends StatelessWidget {
  final FeedbackModel feedback;

  const FeedbackCard({Key? key, required this.feedback}) : super(key: key);

  Border getBorderByRating(int rating) {
    switch (rating) {
      case 5:
        return Border.all(color: Colors.green, width: 3);
      case 4:
        return Border.all(color: Colors.lightGreen, width: 3);
      case 3:
        return Border.all(color: Colors.yellow, width: 3);
      case 2:
        return Border.all(color: Colors.orange, width: 3);
      case 1:
        return Border.all(color: Colors.red, width: 3);
      default:
        return Border.all(color: Colors.grey, width: 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          border: getBorderByRating(feedback.ratings),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: FeedbackModel.fetchCustomerName(feedback.customerId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  if (snapshot.hasError) {
                    return Text('Error loading customer name');
                  } else {
                    return Text(
                      'Customer: ${snapshot.data ?? 'Unknown'}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    );
                  }
                }
              },
            ),
            SizedBox(height: 8),
            Text(
              'Message:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(feedback.message),
            SizedBox(height: 8),
            Text(
              'Overall Rating:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Row(
              children: List.generate(
                feedback.ratings,
                    (index) => Icon(Icons.star, color: Colors.amber),
              ),
            ),
            SizedBox(height: 8),

          ],
        ),
      ),
    );
  }
}
