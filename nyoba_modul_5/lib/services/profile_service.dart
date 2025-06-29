import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> createOrUpdateProfile({
    required String username,
    String? photoUrl,
  }) async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection('{Profile}').doc(uid).set({
      'username': username,
      'email': _auth.currentUser!.email,
      'photoUrl': photoUrl ?? _auth.currentUser!.photoURL,
    }, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getProfile() async {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('{Profile}').doc(uid).get();
  }

  Future<void> deleteProfile() async {
    final uid = _auth.currentUser!.uid;
    await _firestore.collection('{Profile}').doc(uid).delete();
    await _auth.currentUser!.delete();
  }

  Future<void> updateEmail(String newEmail) async {
    await _auth.currentUser!.updateEmail(newEmail);
    await _firestore.collection('{Profile}').doc(_auth.currentUser!.uid).update({
      'email': newEmail,
    });
  }

  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser!.updatePassword(newPassword);
  }
}
