import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'config/supabase_config.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseKey,
  );

  // Get or generate device ID using localStorage
  String? existingId = html.window.localStorage['codeverify_device_id'];
  if (existingId == null || existingId.isEmpty) {
    existingId = DeviceManager.generateId();
    html.window.localStorage['codeverify_device_id'] = existingId;
  }
  DeviceManager.deviceId = existingId;

  runApp(const CodeVerifyApp());
}

class DeviceManager {
  static String deviceId = '';

  static String generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(32, (i) => chars[random.nextInt(chars.length)]).join();
  }
}

class ThemeNotifier extends ChangeNotifier {
  bool _isDark = true;

  bool get isDark => _isDark;

  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

final themeNotifier = ThemeNotifier();

class CodeVerifyApp extends StatefulWidget {
  const CodeVerifyApp({super.key});

  @override
  State<CodeVerifyApp> createState() => _CodeVerifyAppState();
}

class _CodeVerifyAppState extends State<CodeVerifyApp> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeVerify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5A0),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5A0),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        useMaterial3: true,
      ),
      themeMode: themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}