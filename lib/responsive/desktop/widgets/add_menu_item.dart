import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/sizes.dart';

class AddMenuItemScreen extends StatefulWidget {
  final String shopId;

  const AddMenuItemScreen({Key? key, required this.shopId}) : super(key: key);

  @override
  _AddMenuItemScreenState createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String _itemName = '';
  double _price = 0.0;
  String _category = '';
  String _description = '';
  String _photoUrl = '';

  Future<void> _addMenuItem() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      String itemId = FirebaseFirestore.instance.collection('shops').doc().id;
      await FirebaseFirestore.instance
          .collection('shops')
          .doc(widget.shopId)
          .collection('items')
          .add({
        'itemId': itemId,
        'itemName': _itemName,
        'price': _price,
        'category': _category,
        'description': _description,
        'itemImageUrl': _photoUrl.isNotEmpty
            ? _photoUrl
            : 'https://user-images.githubusercontent.com/47315479/81145216-7fbd8700-8f7e-11ea-9d49-bd5fb4a888f1.png',
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    String _category = 'Fast food';
    return Scaffold(
      appBar: SMAAppBar(
        title: Text('Add Menu Item'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                constraints: BoxConstraints(maxWidth: 600,minWidth: 300),
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Item Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the item name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _itemName = value ?? '';
                        },
                      ),
                      const SizedBox(height: SMASizes.spaceBtwInputFields),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the price';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _price = double.tryParse(value ?? '0.0') ?? 0.0;
                        },
                      ),
                      const SizedBox(height: SMASizes.spaceBtwInputFields),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          //fillColor: Colors.white,
                          //filled: true,
                        ),
                        value: _category,
                        onChanged: (String? newValue) {
                          setState(() {
                            _category =
                                newValue ?? 'Fast food';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                        items: <String>[
                          'Fast food',
                          'Veg',
                          'Non Veg',
                          'Meal',
                          'Starter',
                          'Healthy',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: SMASizes.spaceBtwInputFields),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Description'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the description';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _description = value ?? '';
                        },
                      ),
                      const SizedBox(height: SMASizes.spaceBtwInputFields),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Photo URL'),
                        onSaved: (value) {
                          _photoUrl = value ?? '';
                        },
                      ),
                      const SizedBox(height: SMASizes.spaceBtwInputFields),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addMenuItem,
                          child: Text('Add Item'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
