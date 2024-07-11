import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../desktop/modals/feedback.dart';
import '../../desktop/widgets/feedback_card.dart';


class MobileFeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<MobileFeedbackScreen> {
  late Future<List<FeedbackModel>> _feedbackListFuture;

  @override
  void initState() {
    super.initState();
    _feedbackListFuture = fetchFeedbacks();
  }

  Future<List<FeedbackModel>> fetchFeedbacks() async {
    try {
      QuerySnapshot feedbackSnapshot = await FirebaseFirestore.instance
          .collection('feedback')
          .orderBy('createdAt', descending: true)
          .get();

      List<FeedbackModel> feedbackList = await Future.wait(
        feedbackSnapshot.docs.map((doc) => FeedbackModel.fromFirestore(doc)).toList(),
      );

      return feedbackList;
    } catch (e) {
      print('Error fetching feedbacks: $e');
      return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<FeedbackModel>>(
        future: _feedbackListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No feedbacks available'));
          } else {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                FeedbackModel feedback = snapshot.data![index];
                return FeedbackCard(feedback: feedback);
              },
            );
          }
        },
      ),
    );
  }
}

