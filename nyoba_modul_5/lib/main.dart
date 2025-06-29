import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nyoba_modul_5/ads/app_open_ad_manager.dart';
import 'package:nyoba_modul_5/ads/interstitial_ad_manager.dart';
import 'package:nyoba_modul_5/screens/auth/profile_form_screen.dart';
import 'package:nyoba_modul_5/screens/map/map_screen.dart';
import 'package:nyoba_modul_5/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
// import 'package:nyoba_modul_5/services/cloudinary_service.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding_screen.dart';

// Buat instance global
final AppOpenAdManager appOpenAdManager = AppOpenAdManager();
final InterstitialAdManager interstitialAdManager = InterstitialAdManager();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    // Tambahkan ini
    url: 'https://vtwexukinfliprxzkptq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ0d2V4dWtpbmZsaXByeHprcHRxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTExMjQ5MjgsImV4cCI6MjA2NjcwMDkyOH0.jhWd8AIwv7p0dWztOPXDRXV9yui3ArlmrIMGYgXzq9M',
  );
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ✅ Inisialisasi notifikasi
    await NotificationService().init();

    // ✅ Minta izin notifikasi (Android 13+)
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    // Inisialisasi Mobile Ads
    await MobileAds.instance.initialize();
    // Beri penundaan sebelum load ad
    Future.delayed(const Duration(seconds: 1), () {
      appOpenAdManager.loadAd();
      interstitialAdManager.loadAd();
    });

    print("Firebase initialized successfully");

    await dotenv.load(fileName: ".env");

    runApp(const MyApp());
  } catch (e) {
    print("Initialization error: $e");
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text("Initialization error: $e"))),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GOBAN App',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFFFF5E0),
        primaryColor: const Color(0xFF41B06E),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF8DECB4),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF141E46)),
        ),
      ),
      home: const AuthWrapper(),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/profile-form': (context) => const ProfileFormScreen(),
        '/map':
            (context) => const MapScreen(), // Pastikan route untuk '/map' ada
      },
    );
  }
}

// Moved AuthWrapper outside of MyApp
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  bool _isInitializing = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Tampilkan App Open Ad saat kembali ke aplikasi
      appOpenAdManager.showAdIfAvailable();
    }
  }

  Future<void> _initialize() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _isInitializing = false);
    } catch (e) {
      print("AuthWrapper initialization error: $e");
      setState(() {
        _isInitializing = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Terjadi kesalahan inisialisasi"),
              ElevatedButton(
                onPressed: _initialize,
                child: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return const WelcomeScreen();
          } else {
            return FutureBuilder<DocumentSnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('Profile')
                      .doc(user.uid)
                      .get(),
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState == ConnectionState.done) {
                  if (profileSnapshot.hasError) {
                    return Scaffold(
                      body: Center(
                        child: Text("Error: ${profileSnapshot.error}"),
                      ),
                    );
                  }

                  final profileData = profileSnapshot.data?.data() as Map?;
                  final profileCompleted =
                      profileData?['profileCompleted'] ?? false;

                  if (profileCompleted) {
                    return const HomeScreen();
                  } else {
                    return const ProfileFormScreen();
                  }
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            );
          }
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
