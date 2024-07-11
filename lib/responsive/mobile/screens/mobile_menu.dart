import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../common/styles/spacing_style.dart';
import '../../../utils/helpers/helper_fuctions.dart';
import '../../../utils/theme/custom_theme/text_theme.dart';
import '../../desktop/modals/menu_items.dart';
import '../../desktop/widgets/add_menu_item.dart';
import '../../desktop/widgets/menu_item_card.dart';


class MobileMenuScreen extends StatefulWidget {
  final String shopId;

  const MobileMenuScreen({super.key, required this.shopId});

  @override
  State<MobileMenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MobileMenuScreen> {

  @override
  Widget build(BuildContext context) {
    bool dark = SMAHelperFunctions.isDarkMode(context);
    return Padding(
      padding: EdgeInsets.all(8),
      child: Scaffold(

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddMenuItemScreen(shopId: widget.shopId),
            ));
          },
          // mini: true,
          child: Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.all(0.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("shops")
                .doc(widget.shopId)
                .collection('items')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No menu items found.'));
              }

              List<MenuItem> menuItems = snapshot.data!.docs.map((doc) {
                var data = doc.data();
                return MenuItem(
                  name: (data as Map<String, dynamic>?)?.containsKey('itemName') == true ? data!['itemName'] : '',
                  price: (data)?.containsKey('price') == true ? (data!['price'] as num).toDouble() : 0.0,
                  category: (data)?.containsKey('category') == true ? data!['category'] : '',
                  photo: (data)?.containsKey('itemImageUrl') == true ? data!['itemImageUrl'] : 'https://user-images.githubusercontent.com/47315479/81145216-7fbd8700-8f7e-11ea-9d49-bd5fb4a888f1.png',
                  description: (data)?.containsKey('description') == true ? data!['description'] : '',
                );
              }).toList();

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = (constraints.maxWidth / 300).floor();
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        return MenuItemCard(menuItem: menuItems[index]);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
