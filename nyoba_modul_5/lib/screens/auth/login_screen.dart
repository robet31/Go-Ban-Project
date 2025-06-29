import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:nyoba_modul_5/ads/ad_helper.dart';
import 'package:nyoba_modul_5/main.dart';
import 'package:nyoba_modul_5/screens/auth/profile_form_screen.dart';
import 'package:nyoba_modul_5/screens/home/home_screen.dart';
import 'package:nyoba_modul_5/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late StreamSubscription _connectionSubscription;
  bool _wasOffline = false;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
    _listenToConnectionChanges();
    _loadBannerAd();
  }
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _connectionSubscription.cancel(); // Tambahkan ini
    _bannerAd?.dispose();
    super.dispose();
  }


  void _listenToConnectionChanges() {
    final checker = InternetConnectionChecker.createInstance();
    _connectionSubscription = checker.onStatusChange.listen((status) {
      if (!mounted) return;

      if (status == InternetConnectionStatus.disconnected) {
        _wasOffline = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.wifi_off, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text("Tidak ada koneksi internet")),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(seconds: 3),
          ),
        );
      } else if (status == InternetConnectionStatus.connected && _wasOffline) {
        _wasOffline = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.wifi, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text("Koneksi Kembali Online")),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  Future<bool> _isConnectedToInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return await InternetConnectionChecker.createInstance().hasConnection;
  }

  void _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberedEmail = prefs.getString('remembered_email');
    if (rememberedEmail != null) {
      setState(() {
        _emailController.text = rememberedEmail;
        _rememberMe = true;
      });
    }
  }

  Future<void> _handleLoginNavigation() async {
    final user = FirebaseAuth.instance.currentUser;
    final profileSnapshot =
        await FirebaseFirestore.instance
            .collection('Profile')
            .doc(user!.uid)
            .get();

    final profileCompleted =
        profileSnapshot.data()?['profileCompleted'] ?? false;

    if (!mounted) return;

    if (profileCompleted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileFormScreen()),
      );
    }
  }

  Future<void> _login() async {
    if (!await _isConnectedToInternet()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text("Tidak ada koneksi internet")),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // TAMPILKAN INTERSTITIAL AD SETELAH LOGIN BERHASIL
        await Future.delayed(Duration(seconds: 1)); // Beri sedikit waktu
        interstitialAdManager.showAd();
        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setString(
            'remembered_email',
            _emailController.text.trim(),
          );
        } else {
          await prefs.remove('remembered_email');
        }

        if (!mounted) return;

        await NotificationService().showNotification(
          'Login Berhasil',
          'Selamat datang Aplikasi Go-ban!!!',
        );

        await _handleLoginNavigation();
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Login Gagal"),
                content: Text(
                  'Silahkan Cek Kembali Email Dan Password Anda Apakah Sudah Benar',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    if (!await _isConnectedToInternet()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text("Tidak ada koneksi internet")),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    try {
      setState(() => _isLoading = true);
      final googleSignIn = GoogleSignIn(
        clientId:
            "475941342310-0srr90qk2d1f4jrts4ddfi90lv6d4psk.apps.googleusercontent.com",
      );
      GoogleSignInAccount? currentUser = googleSignIn.currentUser;

      if (currentUser == null) {
        currentUser = await googleSignIn.signIn();
        if (currentUser == null) return;
      }

      final GoogleSignInAuthentication googleAuth =
          await currentUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      await googleSignIn.disconnect();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Login dengan Google berhasil!",
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(seconds: 3),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      await NotificationService().showNotification(
        'Login Berhasil',
        'Selamat datang Di Aplikasi Go-ban!!!',
      );
      // TAMPILKAN INTERSTITIAL AD SETELAH LOGIN BERHASIL
      interstitialAdManager.showAd();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileFormScreen()),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Google login failed: $e")));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginWithFacebook() async {
    try {
      setState(() => _isLoading = true);

      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;

        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        await FirebaseAuth.instance.signInWithCredential(
          facebookAuthCredential,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Facebook login successful")),
        );

        if (!mounted) return;

        await NotificationService().showNotification(
          'Login Berhasil',
          'Selamat datang Aplikasi Go-ban!!!',
        );

        await _handleLoginNavigation();
        // TAMPILKAN INTERSTITIAL AD SETELAH LOGIN BERHASIL
      interstitialAdManager.showAd();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Facebook login failed: ${result.status}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Facebook login error: $e")));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E0),
      body: Stack(
        children: [
          // Background elements - FIXED DEPRECATED withOpacity
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(
                  0x338DECB4,
                ), // Equivalent to .withOpacity(0.3)
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),

          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(
                  0x3341B06E,
                ), // Equivalent to .withOpacity(0.2)
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // IconButton(
                    //   icon: const Icon(
                    //     Icons.exit_to_app,
                    //     color: Color(0xFF141E46),
                    //   ),
                    //   onPressed: () {
                    //     // Kembali ke welcome screen
                    //     Navigator.pushReplacementNamed(context, '/welcome');
                    //   },
                    // ),
                    // Di dalam Scaffold di LoginScreen

                    // Logo/Header
                    const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF141E46),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Let's get you in",
                      style: TextStyle(
                        color: Color(0xFF141E46),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Social login buttons - FIXED BUTTON SYNTAX
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _loginWithFacebook,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Color(0xFF8DECB4)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.facebook, color: Colors.blue),
                        label: const Text(
                          "Sign In with Facebook",
                          style: TextStyle(
                            color: Color(0xFF141E46),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _loginWithGoogle,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Color(0xFF8DECB4)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Text(
                          "G",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        label: const Text(
                          "Sign In with Google",
                          style: TextStyle(
                            color: Color(0xFF141E46),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Divider
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFF8DECB4))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "OR",
                            style: TextStyle(
                              color: Color(0xFF141E46),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFF8DECB4))),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Email form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF41B06E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text(
                                        "SIGN IN",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value!;
                            });
                          },
                          activeColor: const Color(0xFF41B06E),
                        ),
                        const Text(
                          "Remember me",
                          style: TextStyle(
                            color: Color(0xFF141E46),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),

                    // Forgot password & Sign up
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/forgot-password',
                                );
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Color(0xFF41B06E),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  color: Color(0xFF141E46),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Color(0xFF41B06E),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading indicator - FIXED DEPRECATED withOpacity
          if (_isLoading)
            Container(
              color: const Color(0x80000000),
              child: Center(
                child: Lottie.asset(
                  'assets/animations/loading.json',
                  width: 100,
                  height: 100,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _isBannerLoaded
          ? SafeArea(
              child: Container(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            )
          : null,
    );
  }
}
