import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:orderease_admin/utils/helpers/helper_fuctions.dart';
import '../../../common/styles/spacing_style.dart';
import '../modals/menu_items.dart'; // Assuming MenuItem class is defined here

class MenuItemCard extends StatelessWidget {
  final MenuItem menuItem; // Use MenuItem object directly

  const MenuItemCard({Key? key, required this.menuItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool dark = SMAHelperFunctions.isDarkMode(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                child: CachedNetworkImage(
                  imageUrl: menuItem.photo,
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      Center(child: Icon(Icons.error)),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuItem.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\u{20B9}${menuItem.price.toStringAsFixed(2)}', // Format price if needed
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Category: ${menuItem.category}",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  SizedBox(height: 4),
                  Container(
                    height: 60,
                    child: Text(
                      "Description: ${menuItem.description}",
                      style: TextStyle(color: Colors.grey[500],overflow: TextOverflow.ellipsis),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}
