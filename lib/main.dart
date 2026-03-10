import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:omar_242/forgot_password_screen.dart';
import 'package:omar_242/login_screen.dart';
import 'package:omar_242/home_screen.dart';
import 'package:omar_242/reset_password_screen.dart';
import 'package:omar_242/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

// Global navigator key to allow navigation from outside the widget tree
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://kittbflniwjsasxynnqx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtpdHRiZmxuaXdqc2FzeHlubnF4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE4NTU3MTYsImV4cCI6MjA4NzQzMTcxNn0.BKNG_72qE7HpB8a90LV1wfbL4A4RGFsG6_THItWi7FE',
  );

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _handleIncomingLinks();
    _handleInitialUri();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// Handle incoming links (when app is running)
  void _handleIncomingLinks() {
    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        if (!mounted) return;
        if (uri.scheme == 'omar242' && uri.host == 'reset-password') {
          _navigatorKey.currentState?.pushNamed('/reset-password');
        }
      },
      onError: (Object err) {
        // Handle errors
      },
    );
  }

  /// Handle the initial Uri (when app is not running)
  Future<void> _handleInitialUri() async {
    try {
      // تعديل هنا: getInitialAppLink → getInitialLink
      final uri = await _appLinks.getInitialLink();
      if (uri != null &&
          uri.scheme == 'omar242' &&
          uri.host == 'reset-password') {
        _navigatorKey.currentState?.pushNamed('/reset-password');
      }
    } on FormatException {
      // Ignore malformed links
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'ruble_earner'.tr(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
      },
    );
  }
}
