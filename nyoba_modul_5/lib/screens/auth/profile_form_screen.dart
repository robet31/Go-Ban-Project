import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nyoba_modul_5/services/location_service.dart';
import 'package:nyoba_modul_5/screens/home/home_screen.dart';
import 'package:nyoba_modul_5/services/notification_service.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:nyoba_modul_5/services/cloudinary_service.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _gender = 'Male';
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isInitializing = true; // Tambah state untuk inisialisasi
  Position? _currentPosition;
  File? _profileImage;
  String? _imageUrl;

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

  Future<void> _getCurrentLocation() async {
    if (_isLoading) return;

    try {
      setState(() => _isLoading = true);
      // Tambah pengecekan service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are disabled")),
        );
        return;
      }

      if (!await LocationService.hasPermission()) {
        final granted = await LocationService.requestPermission();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Location permission denied")),
            );
          }
          return;
        }
      }

      final locationService = LocationService();
      final position = await LocationService.getCurrentLocation();
      setState(() => _currentPosition = position);
      await _getAddressFromLatLng(position!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        setState(() {
          _addressController.text =
              "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Geocoding error: $e");
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadExistingData();
    // _getCurrentLocation();
  }

  Future<void> _initializeData() async {
    setState(() => _isInitializing = true);
    try {
      await _loadExistingData();
      await _getCurrentLocation();
    } catch (e) {
      if (kDebugMode) {
        print("Initialization error: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _loadExistingData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('Profile')
            .doc(user.uid)
            .get();

    if (doc.exists && mounted) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _gender = data['gender'] ?? 'Male';
        _imageUrl = data['imageUrl'];

        if (data['dateOfBirth'] != null) {
          _selectedDate = (data['dateOfBirth'] as Timestamp).toDate();
          _dobController.text = DateFormat(
            'dd MMMM yyyy',
          ).format(_selectedDate!);
        }

        if (data['address'] != null) {
          _addressController.text = data['address'];
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        String? imageUrl = _imageUrl;

        // Upload image jika ada gambar baru
        if (_profileImage != null) {
          imageUrl = await _uploadToCloudinary(_profileImage!);
          if (kDebugMode) {
            print("Cloudinary URL: $imageUrl");
          }
        }

        final data = {
          'uid': user.uid,
          'email': user.email,
          'name': _nameController.text,
          'phone': _phoneController.text,
          'dateOfBirth':
              _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
          'gender': _gender,
          'profileCompleted': true,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLocationUpdate': FieldValue.serverTimestamp(),
          'imageUrl': imageUrl, // Simpan URL dari Cloudinary
          'address': _addressController.text,
        };

        if (_currentPosition != null) {
          data['location'] = GeoPoint(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );
        }

        await FirebaseFirestore.instance
            .collection('Profile')
            .doc(user.uid)
            .set(data, SetOptions(merge: true));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
          // await NotificationService().showNotification(
          //   'Profil Disimpan',
          //   'Profil Anda berhasil diperbarui',
          // );
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Error: ${e.toString()}';

          // Handle khusus untuk permission denied
          if (e.toString().contains('permission-denied')) {
            errorMessage = 'Permission denied. Please check Firestore rules.';
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading screen selama inisialisasi
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF5E0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'Menyiapkan profil...',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  color: Color(0xFF141E46),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E0),
      appBar: AppBar(
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(fontFamily: 'Poppins',fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF41B06E),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),

              // Profile image
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF8DECB4),
                    backgroundImage:
                        _profileImage != null
                            ? FileImage(_profileImage!)
                            : (_imageUrl != null
                                ? NetworkImage(_imageUrl!)
                                : null),
                    child:
                        _profileImage == null && _imageUrl == null
                            ? const Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.white,
                            )
                            : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Add Profile Photo',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF141E46),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                'Personal Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF141E46),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Color(0xFF41B06E),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF8DECB4)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF8DECB4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF41B06E)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: const TextStyle(fontFamily: 'Poppins'),
                ),
                style: const TextStyle(fontFamily: 'Poppins'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFF41B06E)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF8DECB4)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF8DECB4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF41B06E)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: const TextStyle(fontFamily: 'Poppins'),
                ),
                style: const TextStyle(fontFamily: 'Poppins'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _dobController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF41B06E),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF8DECB4)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF8DECB4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF41B06E)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: const TextStyle(fontFamily: 'Poppins'),
                ),
                style: const TextStyle(fontFamily: 'Poppins'),
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your date of birth';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text(
                'Gender',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Radio<String>(
                    value: 'Male',
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value!),
                    activeColor: const Color(0xFF41B06E),
                  ),
                  const Text('Male', style: TextStyle(fontFamily: 'Poppins')),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'Female',
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value!),
                    activeColor: const Color(0xFF41B06E),
                  ),
                  const Text('Female', style: TextStyle(fontFamily: 'Poppins')),
                ],
              ),
              const SizedBox(height: 20),

              // Location section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.refresh, color: Color(0xFF41B06E)),
                    label: const Text(
                      'Refresh',
                      style: TextStyle(
                        color: Color(0xFF41B06E),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                readOnly: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.location_on,
                    color: Color(0xFF41B06E),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF8DECB4)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF8DECB4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF41B06E)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: const TextStyle(fontFamily: 'Poppins'),
                ),
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 40),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF41B06E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Save Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.white
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
