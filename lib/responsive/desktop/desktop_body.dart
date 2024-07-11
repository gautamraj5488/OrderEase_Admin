import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orderease_admin/responsive/desktop/screens/coupons.dart';
import 'package:orderease_admin/responsive/desktop/screens/dashboard.dart';
import 'package:orderease_admin/responsive/desktop/screens/feedback.dart';
import 'package:orderease_admin/responsive/desktop/screens/menu.dart';
import 'package:orderease_admin/responsive/desktop/screens/orders_list.dart';
import 'package:orderease_admin/responsive/desktop/widgets/desktop_drawer.dart';

import '../../services/firestore.dart';

class DesktopBody extends StatefulWidget {
  const DesktopBody({Key? key}) : super(key: key);

  @override
  State<DesktopBody> createState() => _DesktopBodyState();
}

class _DesktopBodyState extends State<DesktopBody> {
  int _selectedIndex = 0;
  final FireStoreServices _fireStoreServices = FireStoreServices();

  String shopId = " ";

  @override
  void initState() {
    super.initState();
    _loadShopId();
  }

  Future<void> _loadShopId() async {
    String? id = await _fireStoreServices.getCurrentUserShopId();
    setState(() {
      shopId = id ?? " ";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          DesktopDrawer(
            selectedIndex: _selectedIndex,
            onItemTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: _buildSelectedPage(shopId),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPage(String shopId) {
    switch (_selectedIndex) {
      case 0:
        return const Dashboard();
      case 1:
        return OrderListScreen();
      case 2:
        return MenuScreen(shopId: shopId);

      case 3:
        return CouponsPage(shopId: shopId);
      case 4:
        return FeedbackScreen();
      default:
        return Container(); // Handle additional cases or default content
    }
  }
}
