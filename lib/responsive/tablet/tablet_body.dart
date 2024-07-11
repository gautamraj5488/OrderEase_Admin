import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orderease_admin/responsive/tablet/screens/tab_coupons.dart';
import 'package:orderease_admin/responsive/tablet/screens/tab_dashboard.dart';
import 'package:orderease_admin/responsive/tablet/screens/tab_feedback.dart';
import 'package:orderease_admin/responsive/tablet/screens/tab_menu.dart';
import 'package:orderease_admin/responsive/tablet/screens/tab_orders_list.dart';
import 'package:orderease_admin/utils/helpers/helper_fuctions.dart';

import '../../services/firestore.dart';
import '../../utils/constants/colors.dart';
import '../../utils/theme/custom_theme/text_theme.dart';
import '../desktop/screens/coupons.dart';
import '../desktop/screens/dashboard.dart';
import '../desktop/screens/menu.dart';
import '../desktop/screens/orders_list.dart';
import '../desktop/widgets/desktop_drawer.dart';

class TabletBody extends StatefulWidget {
  const TabletBody({super.key});

  @override
  State<TabletBody> createState() => _TabletBodyState();
}

class _TabletBodyState extends State<TabletBody> {
  int _selectedIndex = 0;
  final FireStoreServices _fireStoreServices = FireStoreServices();

  String shopId = " ";

  @override
  void initState() {
    super.initState();
    _loadShopId();
  }

  Future<void> _loadShopId() async {
    try {
      String? id = await _fireStoreServices.getCurrentUserShopId();

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          shopId = id ?? "default_shop_id"; // Handle null case appropriately
        });
      }
    } catch (e) {
      print("Error loading shop ID: $e");
      // Handle error appropriately, show error message or fallback
    }
  }


  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    bool dark = SMAHelperFunctions.isDarkMode(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: dark ? SMAColors.white : SMAColors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          _getTitleFromIndex(_selectedIndex),
          style: dark ? SMATextTheme.darkTextTheme.headlineMedium : SMATextTheme.lightTextTheme.headlineMedium,
        ),
      ),
      drawer: Drawer(
        child: DesktopDrawer(
          selectedIndex: _selectedIndex,
          onItemTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildSelectedPage(shopId),
    );
  }

  String _getTitleFromIndex(int index) {
    switch (index) {
      case 0:
        return "Dashboard";
      case 1:
        return "Order List";
      case 2:
        return "Menu";
      case 3:
        return "Coupons";
      case 4:
        return "Feedbacks";
      default:
        return "Unknown";
    }
  }

  Widget _buildSelectedPage(String shopId) {
    switch (_selectedIndex) {
      case 0:
        return const TabDashboard();
      case 1:
        return TabOrderListScreen();
      case 2:
        return TabMenuScreen(shopId: shopId);

      case 3:
        return TabCouponsPage(shopId: shopId);
      case 4:
        return TabFeedbackScreen();
      default:
        return Container(); // Handle additional cases or default content
    }
  }
}
