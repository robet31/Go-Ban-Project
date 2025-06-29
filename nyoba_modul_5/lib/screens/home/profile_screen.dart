import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:nyoba_modul_5/screens/auth/edit_profile_screen.dart';
// import 'package:nyoba_modul_5/screens/auth/change_password_screen.dart';
import 'package:nyoba_modul_5/screens/home/change_password_screen.dart';
import 'package:nyoba_modul_5/screens/home/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('Profile')
            .doc(user.uid)
            .get();

    if (doc.exists) {
      setState(() {
        _userData = doc.data()!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 90,
                    backgroundImage:
                        _userData?['imageUrl'] != null
                            ? NetworkImage(_userData!['imageUrl'])
                            : null,
                    backgroundColor: const Color(0xFFE0E0E0),
                    child:
                        _userData?['imageUrl'] == null
                            ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white70,
                            )
                            : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userData?['name'] ?? 'Nama Pengguna',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    _userData?['email'] ?? 'email@example.com',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuOption(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuOption(
                    icon: Icons.notifications,
                    title: 'Notification',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildMenuOption(
                    icon: Icons.location_on,
                    title: 'Shipping Address',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildMenuOption(
                    icon: Icons.lock,
                    title: 'Change Password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF41B06E)),
      title: Text(title, style: const TextStyle(fontFamily: 'Poppins')),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
