// lib/screens/sell_product_screen.dart (REPLACE ENTIRE FILE)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart'; // <-- Import new package

class SellProductScreen extends StatefulWidget {
  const SellProductScreen({super.key});

  @override
  State<SellProductScreen> createState() => _SellProductScreenState();
}

class _SellProductScreenState extends State<SellProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _productImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ======== NEW AND IMPROVED IMAGE PICKING FUNCTION ========
  Future<void> _pickImage() async {
    // Show a dialog to let the user choose between Camera and Gallery
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Photo Library'),
                  onTap: () {
                    _getImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    // Check for permissions first
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _productImage = File(pickedFile.path);
        });
      }
    } else if (status.isPermanentlyDenied) {
      // If permission is permanently denied, show a dialog to open app settings
      openAppSettings();
    } else {
      // Handle other permission statuses
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission was denied.')),
        );
      }
    }
  }
  // ========================================================

  Future<String?> _uploadImage(File image) async {
    // This function is correct and doesn't need changes
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('product_images')
          .child('${user.uid}_${DateTime.now().toIso8601String()}.jpg');
      
      await storageRef.putFile(image);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint("Image Upload Error: $e");
      return null;
    }
  }

  Future<void> _submitProduct() async {
    // This function is correct and doesn't need changes
    if (!_formKey.currentState!.validate()) return;
    if (_productImage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a product image.'), backgroundColor: Colors.red),
        );
      }
      return;
    }
    setState(() { _isLoading = true; });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
        setState(() { _isLoading = false; });
        return;
    }
    final imageUrl = await _uploadImage(_productImage!);
    if (!mounted) return;
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload failed. Please try again.'), backgroundColor: Colors.red),
      );
      setState(() { _isLoading = false; });
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': _nameController.text,
        'price': _priceController.text,
        'description': _descriptionController.text,
        'imageUrl': imageUrl,
        'sellerUid': user.uid,
        'sellerName': user.displayName ?? 'A Farmer',
        'postedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('product_posted_success'.tr()), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // The build method is correct and doesn't need changes
    return Scaffold(
      appBar: AppBar(
        title: Text('sell_new_product'.tr()),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'product_name'.tr(), border: const OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a product name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'price'.tr(), border: const OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a price' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'description'.tr(), border: const OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(Icons.image),
                label: Text('add_product_image'.tr()),
                onPressed: _pickImage,
              ),
              const SizedBox(height: 12),
              _productImage != null
                  ? Image.file(_productImage!, height: 150)
                  : const Text('No image selected.', textAlign: TextAlign.center),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('post_for_sale'.tr()),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}