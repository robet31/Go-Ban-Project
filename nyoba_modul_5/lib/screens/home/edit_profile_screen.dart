import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
// import 'package:nyoba_modul_5/screens/home/home_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _profileImage;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('Profile')
            .doc(user.uid)
            .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _imageUrl = data['imageUrl'];
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Ambil dari Kamera'),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                    );
                    if (pickedFile != null) {
                      setState(() => _profileImage = File(pickedFile.path));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      setState(() => _profileImage = File(pickedFile.path));
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  // Fungsi untuk mengompres gambar dengan error handling
  Future<File?> _compressImage(String path) async {
    try {
      final original = File(path);
      final imageBytes = await original.readAsBytes();

      // Batasi ukuran file maksimal 5MB
      if (imageBytes.length > 5 * 1024 * 1024) {
        if (kDebugMode) {
          print("Image too large, compressing...");
        }
      }

      final image = img.decodeImage(imageBytes);
      if (image == null) throw Exception("Failed to decode image");

      final compressed = img.copyResize(
        image,
        width: 1200,
        maintainAspect: true,
      );

      final tempFile = File('${original.path}_compressed.jpg');
      await tempFile.writeAsBytes(img.encodeJpg(compressed, quality: 85));

      return tempFile;
    } catch (e) {
      if (kDebugMode) {
        print("Compression error: $e");
      }
      return null;
    }
  }

  Future<String> _uploadToCloudinary(File imageFile) async {
    // Ubah return type ke String
    try {
      final compressedImage = await _compressImage(imageFile.path);
      final fileToUpload = compressedImage ?? imageFile;

      final dio = Dio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          fileToUpload.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'upload_preset': 'tz1jldlq',
      });

      final response = await dio.post(
        'https://api.cloudinary.com/v1_1/duncrb8jk/image/upload',
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(
          "Upload gagal: ${response.data?['error']?['message'] ?? 'Unknown error'}",
        );
      }

      return response.data['secure_url'] as String; // Kembalikan string
    } catch (e) {
      if (kDebugMode) {
        print("Upload error: $e");
      }
      rethrow;
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String? imageUrl = _imageUrl;
      if (_profileImage != null) {
        imageUrl = await _uploadToCloudinary(_profileImage!);
      }

      await FirebaseFirestore.instance
          .collection('Profile')
          .doc(user.uid)
          .update({
            'name': _nameController.text,
            'phone': _phoneController.text,
            'imageUrl': imageUrl,
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context); // Kembali ke halaman profile
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold, // Membuat teks bold
          ),
        ),
        centerTitle: true, // Untuk memposisikan title di tengah,
        backgroundColor: Color(0xFF8DECB4),
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        _profileImage != null
                            ? FileImage(_profileImage!)
                            : (_imageUrl != null
                                ? NetworkImage(_imageUrl!) as ImageProvider
                                : const AssetImage(
                                  'assets/avatar_placeholder.png',
                                )),
                    child:
                        _profileImage == null && _imageUrl == null
                            ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white70,
                            )
                            : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.teal,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                "Ubah Foto",
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Nomor Telepon',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF41B06E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
