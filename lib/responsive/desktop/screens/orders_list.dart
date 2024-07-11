import 'package:flutter/material.dart';
import 'package:orderease_admin/services/firestore.dart';

import '../../../common/styles/spacing_style.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_fuctions.dart';
import '../../../utils/theme/custom_theme/text_theme.dart';

class OrderListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool dark = SMAHelperFunctions.isDarkMode(context);
    return Padding(
      padding: SMASpacingStyle.allSidePadding,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Order List",
            style: dark
                ? SMATextTheme.darkTextTheme.headlineMedium
                : SMATextTheme.lightTextTheme.headlineMedium,
          ),
        ),
        body: OrdersGridView(),
      ),
    );
  }
}

class OrdersGridView extends StatefulWidget {

  @override
  State<OrdersGridView> createState() => _OrdersGridViewState();
}

class _OrdersGridViewState extends State<OrdersGridView> {
  final FireStoreServices _fireStoreServices = FireStoreServices();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _fireStoreServices.streamOrders(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data ?? [];

        return LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: constraints.maxWidth > 600 ? 400 : 200,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final String orderId = order['orderId']?.toString() ?? '';
                  final String currentStatus = order['status']?.toString() ?? 'Unknown';

                  return Dismissible(
                    key: Key(order['orderId'] ?? index.toString()),
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
                    child: OrderCard(order: order),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  OrderCard({required this.order});

  Color _getStatusColorButton(String status) {
    switch (status) {
      case 'Order Accepted':
        return SMAColors.info.withOpacity(0.1);
      case 'Preparing':
        return SMAColors.warning.withOpacity(0.1);
      case 'Completed':
        return SMAColors.success.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Order Accepted':
        return SMAColors.info;
      case 'Preparing':
        return SMAColors.warning;
      case 'Completed':
        return SMAColors.success;
      default:
        return Colors.grey;
    }
  }


  @override
  Widget build(BuildContext context) {
    bool dark = SMAHelperFunctions.isDarkMode(context);
    return Container(
      height: double.infinity,
      padding: SMASpacingStyle.allSidePadding,
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: _getStatusColor(order['status'] ?? 'Unknown'),
        ),
        borderRadius: BorderRadius.circular(8.0),
        color: dark ? SMAColors.dark : SMAColors.light,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child:SingleChildScrollView(
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColorButton(order['status'] ?? 'Unknown'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order['status'] ?? 'Unknown',
                      style: TextStyle(color: _getStatusColor(order['status'] ?? 'Unknown')),
                    ),
                  ),
                ],
              ),
              Text(order['phone'] ?? ''),
              SizedBox(height: 8),
              Text(order['time'] ?? ''),
              Text(order['table'] ?? ''),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${(order['items'] as List).length } Items'),
                  Text('\u{20B9}${(order['total'] ?? 0.0).toString()}', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 8),
              ListView(
                shrinkWrap: true,
                children: ((order['items'] as List).map<Widget>((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['item'] ?? ''),
                        Text('\u{20B9}${(item['price'] ?? 0.0).toString()}'),
                      ],
                    ),
                  );
                }).toList()),
              )

            ],
          ),
        )
      ),
    );
  }
}