import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/sizes.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  Map<String, dynamic> adminData = {};
  Map<String, dynamic> shopData = {};
  bool isLoading = true;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchAdminDetails();
  }

  Future<void> fetchAdminDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Fetch details from 'admins' collection
      DocumentSnapshot adminSnapshot =
      await _firestore.collection('admins').doc(user.uid).get();
      if (adminSnapshot.exists) {
        adminData.addAll(adminSnapshot.data() as Map<String, dynamic>);

        // Fetch shop details from 'shops' collection
        DocumentSnapshot shopSnapshot =
        await _firestore.collection('shops').doc(adminData['shopId']).get();
        if (shopSnapshot.exists) {
          shopData.addAll(shopSnapshot.data() as Map<String, dynamic>);
        }
      }

      // Update the state to refresh UI with fetched data
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _editProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    User? user = _auth.currentUser;
    if (user != null && _imageFile != null) {
      try {
        // Upload image to Firebase Storage
        String fileName = 'profile_${user.uid}.jpg';
        Reference reference =
        _storage.ref().child('profile_pictures/$fileName');
        UploadTask uploadTask = reference.putFile(_imageFile!);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadURL = await taskSnapshot.ref.getDownloadURL();

        // Update user's profile picture URL in Firestore
        await _firestore.collection('admins').doc(user.uid).update({
          'profilePic': downloadURL,
        });

        setState(() {
          adminData['profilePic'] = downloadURL;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile picture updated successfully')),
        );
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile picture')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SMAAppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage(adminData, shopData)),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: adminData['profilePic'] != null
                        ? NetworkImage(adminData['profilePic'])
                        : NetworkImage(
                        'https://img.freepik.com/premium-photo/there-is-cat-that-is-sitting-ledge-chinese-garden-generative-ai_900396-35755.jpg'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: _editProfilePicture,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildProfileItem('First Name', adminData['firstName']),
            _buildProfileItem('Last Name', adminData['lastName']),
            _buildProfileItem('Phone Number', adminData['phoneNumber']),
            _buildProfileItem('Email', adminData['email']),
            _buildProfileItem('Number of Tables', shopData['numberOfTables'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String title, String? value) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(value ?? 'Not provided'),
    );
  }
}


class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> adminData;
  final Map<String, dynamic> shopData;

  EditProfilePage(this.adminData, this.shopData);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _tablesCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.adminData['firstName'] ?? '';
    _lastNameController.text = widget.adminData['lastName'] ?? '';
    _tablesCountController.text = widget.shopData['numberOfTables'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Container(
            height: 300,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(labelText: 'First Name'),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(labelText: 'Last Name'),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _tablesCountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Number of Tables'),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      child: Text('Save Changes'),
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

  Future<void> _updateProfile() async {
    try {
      // Update profile data in Firestore
      await FirebaseFirestore.instance.collection('admins').doc(widget.adminData['uid']).update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
      });

      // Update shop data in Firestore
      await FirebaseFirestore.instance.collection('shops').doc(widget.adminData['shopId']).update({
        'numberOfTables': int.parse(_tablesCountController.text),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }
}
