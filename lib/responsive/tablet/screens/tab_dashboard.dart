import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orderease_admin/common/styles/spacing_style.dart';
import 'package:orderease_admin/utils/theme/custom_theme/text_theme.dart';
import '../../../utils/helpers/helper_fuctions.dart';
import '../../desktop/services/order_analytics_service.dart';
import '../../desktop/widgets/average_order_value.dart';
import '../../desktop/widgets/current_orders.dart';
import '../../desktop/widgets/dashboard_header.dart';
import '../../desktop/widgets/orders_per_day.dart';


class TabDashboard extends StatefulWidget {
  const TabDashboard({Key? key}) : super(key: key);

  @override
  State<TabDashboard> createState() => _DashboardState();
}

class _DashboardState extends State<TabDashboard> {
  late Stream<List<double>> _ordersDataStream;
  final OrderAnalyticsService _analyticsService = OrderAnalyticsService();

  @override
  void initState() {
    super.initState();
    _ordersDataStream = _streamOrdersData();
  }

  Stream<List<double>> _streamOrdersData() {
    // Calculate the date 7 days ago from today
    DateTime sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));

    return FirebaseFirestore.instance
        .collection("orders")
        .where('createdAt', isGreaterThan: sevenDaysAgo)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((querySnapshot) {
      List<double> ordersData = [
        0, 0, 0, 0, 0, 0, 0
      ]; // Initialize with 0 orders for each day

      querySnapshot.docs.forEach((doc) {
        Timestamp createdAt = doc.get('createdAt');
        DateTime date = createdAt.toDate();
        int dayIndex = (date.weekday + 6) % 7;

        ordersData[dayIndex]++;
      });

      return ordersData;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool dark = SMAHelperFunctions.isDarkMode(context);
    return Padding(
      padding: SMASpacingStyle.allSidePadding,
      child: Scaffold(

          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardHeader(),
                Row(
                  children: [
                    Expanded(
                      child: CurrentOrders(),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: StreamBuilder<List<double>>(
                        stream: _ordersDataStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            print('Error: ${snapshot.error}');
                            return Text('Error: ${snapshot.error}');
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text('No data available'));
                          }

                          List<double> ordersData = snapshot.data!;
                          return OrdersPerDayContainer(ordersData: ordersData);
                        },
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: AverageOrderValueContainer(
                        ordersDataStream:
                            _analyticsService.streamAverageOrderValues(),
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
}
