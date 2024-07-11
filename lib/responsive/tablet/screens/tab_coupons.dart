import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coupon_uikit/coupon_uikit.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_fuctions.dart';

class TabCouponsPage extends StatefulWidget {
  final String shopId;

  const TabCouponsPage({Key? key, required this.shopId}) : super(key: key);

  @override
  State<TabCouponsPage> createState() => _TabCouponsPageState();
}

class _TabCouponsPageState extends State<TabCouponsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _codeController = TextEditingController();

  final TextEditingController _maxRupeesController = TextEditingController();

  final TextEditingController _percentageController = TextEditingController();

  Future<void> _addCoupon() async {
    final code = _codeController.text;
    final maxRupees = int.tryParse(_maxRupeesController.text) ?? 0;
    final percentage = int.tryParse(_percentageController.text) ?? 0;

    if (code.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('shops')
          .doc(widget.shopId)
          .collection('coupons')
          .add({
        'code': code,
        'maxRupees': maxRupees,
        'percentage': percentage,
      });

      _codeController.clear();
      _maxRupeesController.clear();
      _percentageController.clear();
    }
  }

  Future<void> _deleteCoupon(String couponId) async {
    await FirebaseFirestore.instance
        .collection('shops')
        .doc(widget.shopId)
        .collection('coupons')
        .doc(couponId)
        .delete();
  }

  void _showDeleteConfirmationDialog(String couponId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Coupon'),
        content: Text('Are you sure you want to delete this coupon?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteCoupon(couponId);
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    bool dark = SMAHelperFunctions.isDarkMode(context);
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('shops')
            .doc(widget.shopId)
            .collection('coupons')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No coupons found.'));
          }

          final coupons = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: coupons.length + 1,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 2 / 1,
              ),
              itemBuilder: (context, index) {
                if (index == coupons.length) {
                  return Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: CouponCard(
                      height: 150,
                      backgroundColor: dark? SMAColors.dark : SMAColors.light,
                      curvePosition: 135,
                      curveRadius: 30,
                      curveAxis: Axis.vertical,
                      borderRadius: 15,
                      firstChild: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: dark? SMAColors.white : SMAColors.dark,
                        ),
                        child: Center(
                          child: Text(
                            'New Coupon',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      secondChild: Container(
                        height: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: dark? SMAColors.darkContainer : SMAColors.darkGrey,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Form(
                          key: _formKey,  // Ensure you have defined _formKey as a GlobalKey<FormState>
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextFormField(
                                  controller: _codeController,
                                  decoration: InputDecoration(
                                    labelText: 'Code',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a code';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _maxRupeesController,
                                  decoration: InputDecoration(
                                    labelText: 'Max Rupees',
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the maximum rupees';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Please enter a valid number';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _percentageController,
                                  decoration: InputDecoration(
                                    labelText: 'Percentage',
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the percentage';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Please enter a valid number';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _addCoupon();
                                      }
                                    },
                                    child: Text('Add Coupon'),

                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final coupon = coupons[index];
                final code = coupon['code'] ?? 'Unknown';
                final maxRupees = coupon['maxRupees'] ?? 0;
                final percentage = coupon['percentage'] ?? 0;
                final couponId = coupon.id;

                return GestureDetector(
                  onLongPress: () => _showDeleteConfirmationDialog(couponId),
                  child: CouponCard(
                    height: 150,
                    backgroundColor: Colors.blue,
                    curvePosition: 135,
                    curveRadius: 30,
                    curveAxis: Axis.vertical,
                    borderRadius: 15,
                    firstChild: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: dark? SMAColors.white : SMAColors.dark,
                      ),
                      child: Center(
                        child: Text(
                          '$percentage% OFF',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    secondChild: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Code: $code',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Discount up to: \u{20B9}$maxRupees',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      )
    );
  }
}
