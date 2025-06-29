import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nyoba_modul_5/ads/ad_helper.dart';
import 'package:nyoba_modul_5/models/destination.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:nyoba_modul_5/screens/home/all_destinations_screen.dart';
import 'package:nyoba_modul_5/screens/home/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nyoba_modul_5/screens/auth/login_screen.dart';
import 'package:nyoba_modul_5/screens/home/faq.dart';
import 'package:nyoba_modul_5/screens/map/map_screen.dart';
import 'package:nyoba_modul_5/screens/map/destination_detail_screen.dart'
    hide MapScreen;
import 'package:nyoba_modul_5/services/destination_service.dart';
import 'package:nyoba_modul_5/utils/location_service.dart';
import 'package:nyoba_modul_5/widgets/destination_card.dart';
import 'package:nyoba_modul_5/widgets/destination_list_tile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as latlong2; // <-- DITAMBAHKAN: Impor untuk tipe LatLng yang benar

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _userName = "User";
  String? _userImageUrl;
  BannerAd? _bannerAd;
  NativeAd? _nativeAd;
  bool _isBannerLoaded = false;
  bool _isNativeAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadBannerAd();
    _loadNativeAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isBannerLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
           if (mounted) {
            setState(() {
              _isNativeAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.grey[200],
        cornerRadius: 12.0,
      ),
    )..load();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('Profile').doc(user.uid).get();

    if (mounted && doc.exists) {
      final data = doc.data()!;
      setState(() {
        _userName = data['name'] ?? 'User';
        _userImageUrl = data['imageUrl'];
      });
    }
  }

  final List<Widget> _pages = [
    const HomePage(),
    const MapScreen(),
    const FAQPage(),
    const ProfileScreen(),
  ];

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 3
              ? "Profile Pengguna"
              : _selectedIndex == 1
                  ? "Peta Tambal Ban"
                  : "Go-Ban",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: const Color(0xFF141E46),
          ),
        ),
        backgroundColor: const Color(0xFF8DECB4),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        actions: _selectedIndex == 3
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => logout(context),
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          Expanded(child: _pages[_selectedIndex]),
          if (_isBannerLoaded)
            SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
              backgroundColor: const Color(0xFF41B06E),
              child: const Icon(Icons.map_rounded, color: Colors.white),
            )
          : null,
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: _selectedIndex,
        showElevation: true,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
        items: [
          FlashyTabBarItem(
            icon: const Icon(Icons.home),
            title: Text('Beranda', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            activeColor: const Color(0xFF41B06E),
            inactiveColor: Colors.grey,
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.map_rounded),
            title: Text('MAPS', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            activeColor: const Color(0xFF41B06E),
            inactiveColor: Colors.grey,
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.question_answer_outlined),
            title: Text('FAQ', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            activeColor: const Color(0xFF41B06E),
            inactiveColor: Colors.grey,
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.person),
            title: Text('Profil', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            activeColor: const Color(0xFF41B06E),
            inactiveColor: Colors.grey,
          ),
        ],
        animationCurve: Curves.easeIn,
        animationDuration: const Duration(milliseconds: 300),
        iconSize: 24,
        backgroundColor: Colors.white,
      ),
    );
  }
}

// ==========================================================
// == KELAS HomePage YANG TELAH DIPERBAIKI (STATEFUL) ==
// ==========================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DestinationService _destinationService = DestinationService();
  final LocationService _locationService = LocationService();
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _userPosition = position;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final parentState = context.findAncestorStateOfType<_HomeScreenState>();
    final userName = parentState?._userName ?? "User";
    final userImageUrl = parentState?._userImageUrl;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with user info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8DECB4), Color(0xFF41B06E)],
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: userImageUrl != null
                          ? NetworkImage(userImageUrl)
                          : const AssetImage('assets/default_avatar.png')
                              as ImageProvider,
                      radius: 30,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hello, $userName", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text("Mau cari tambal ban terdekat ?", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: const Color(0x1A000000), blurRadius: 6, offset: const Offset(0, 3)),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Cari tambal ban disekitarmu...",
                    hintStyle: GoogleFonts.poppins(),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF41B06E)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
              
              if (parentState != null && parentState._isNativeAdLoaded)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  height: 300,
                  child: AdWidget(ad: parentState._nativeAd!),
                )
              else
                 const SizedBox(height: 24),

              // StreamBuilder untuk mengambil dan menampilkan data
              StreamBuilder<List<Destination>>(
                stream: _destinationService.getDestinations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada data destinasi.'));
                  }

                  final allDestinations = snapshot.data!;

                  // Logic untuk "Terpopuler" (berdasarkan rating)
                  final popularDests = List<Destination>.from(allDestinations);
                  popularDests.sort((a, b) => (b.rating ?? 0.0).compareTo(a.rating ?? 0.0));

                  // Logic untuk "Rekomendasi" (berdasarkan jarak)
                  final recommendedDests = List<Destination>.from(allDestinations);
                  if (_userPosition != null) {
                    recommendedDests.sort((a, b) {
                      final distA = Geolocator.distanceBetween(
                          _userPosition!.latitude, _userPosition!.longitude,
                          a.location.latitude, a.location.longitude);
                      final distB = Geolocator.distanceBetween(
                          _userPosition!.latitude, _userPosition!.longitude,
                          b.location.latitude, b.location.longitude);
                      return distA.compareTo(distB);
                    });
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("Terpopuler", () => _navigateToAll(context, "Terpopuler", popularDests)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: popularDests.length > 5 ? 5 : popularDests.length,
                          itemBuilder: (context, index) {
                            return DestinationCard(destination: popularDests[index], onTap: () => _navigateToDetail(context, popularDests[index]));
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionHeader("Rekomendasi Terdekat", () => _navigateToAll(context, "Rekomendasi", recommendedDests)),
                      const SizedBox(height: 12),
                      if (_userPosition == null)
                        const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Mengambil data lokasi Anda...")))
                      else
                        ListView.builder(
                          itemCount: recommendedDests.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final dest = recommendedDests[index];
                            return InkWell(
                              onTap: () => _navigateToDetail(context, dest),
                              child: DestinationListTile(
                                destination: dest,
                                userPosition: _userPosition,
                              ),
                            );
                          },
                        ),
                       const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF141E46))),
        TextButton(
          onPressed: onSeeAll,
          child: Text("Lihat Semua", style: GoogleFonts.poppins(color: const Color(0xFF41B06E), fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  void _navigateToDetail(BuildContext context, Destination destination) {
    // FIX: Ubah tipe LatLng ke latlong2.LatLng agar sesuai dengan DestinationDetailScreen
    latlong2.LatLng? userLocationForDetail;
    if (_userPosition != null) {
      userLocationForDetail = latlong2.LatLng(_userPosition!.latitude, _userPosition!.longitude);
    }
    
    Navigator.push(context, MaterialPageRoute(builder: (context) =>
        DestinationDetailScreen(destination: destination, userLocation: userLocationForDetail)
    ));
  }
  
  void _navigateToAll(BuildContext context, String title, List<Destination> destinations) {
     Navigator.push(context, MaterialPageRoute(builder: (context) => 
        AllDestinationsScreen(title: title, destinations: destinations, userPosition: _userPosition)
     ));
  }
}
