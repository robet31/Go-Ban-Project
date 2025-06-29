import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  const OTPVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  String? _verificationId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sendOTP();
  }

  void _sendOTP() async {
    setState(() => _isLoading = true);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification failed: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() => _verificationId = verificationId);
      },
    );
  }

  void _verifyOTP() async {
    final smsCode = otpController.text.trim();
    if (_verificationId == null || smsCode.isEmpty) return;

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid OTP")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Enter OTP sent to your number"),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              decoration: const InputDecoration(
                labelText: "6-digit OTP",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _verifyOTP,
                  child: const Text("Verify OTP"),
                ),
          ],
        ),
      ),
    );
  }
}
