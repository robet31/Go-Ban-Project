import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nyoba_modul_5/ads/ad_helper.dart' show AdHelper;
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
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
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E0),
      body: Stack(
        children: [
          // Background elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0x338DECB4),
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
                color: const Color(0x3341B06E),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Go-Ban dengan rounded border
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        40,
                      ), // Atur tingkat kebulatan di sini
                      border: Border.all(
                        color: const Color(0xFF41B06E), // Warna border hijau
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        37,
                      ), // Sedikit lebih kecil dari border
                      child: Image.asset(
                        'assets/icon/logo.png',
                        fit: BoxFit.contain,
                        // Fallback jika gambar gagal dimuat
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: const Color(0xFF41B06E).withOpacity(0.1),
                              child: const Icon(
                                Icons.car_repair,
                                size: 80,
                                color: Color(0xFF41B06E),
                              ),
                            ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // // Judul
                  // const Text(
                  //   "GOBAN",
                  //   style: TextStyle(
                  //     fontSize: 36, // Ukuran lebih besar
                  //     fontWeight: FontWeight.bold,
                  //     color: Color(0xFF141E46),
                  //     fontFamily: 'Poppins',
                  //     letterSpacing: 1.5,
                  //   ),
                  // ),
                  const SizedBox(height: 12),

                  // Subjudul
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Darurat ban bocor? Tenang, Go-Ban solusinya!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF141E46),
                        fontFamily: 'Poppins',
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Tombol Login
                  SizedBox(
                    width: double.infinity,
                    height: 55, // Tinggi tombol ditambah
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF41B06E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Border lebih bulat
                        ),
                        elevation: 5, // Menambahkan efek bayangan
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18, // Ukuran font lebih besar
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Tombol Register
                  SizedBox(
                    width: double.infinity,
                    height: 55, // Tinggi tombol ditambah
                    child: OutlinedButton(
                      onPressed:
                          () => Navigator.pushNamed(context, '/register'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(
                          color: Color(0xFF41B06E),
                          width: 2, // Garis lebih tebal
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Border lebih bulat
                        ),
                        backgroundColor: Colors.white.withOpacity(0.9),
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 18, // Ukuran font lebih besar
                          color: Color(0xFF41B06E),
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tombol Onboarding
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/onboarding');
                    },
                    child: const Text(
                      "Lihat Onboarding",
                      style: TextStyle(
                        color: Color(0xFF41B06E),
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Tambahkan Banner Ad di bagian bawah
      bottomNavigationBar:
          _isBannerLoaded
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
