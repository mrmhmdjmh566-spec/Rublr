import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:omar_242/forgot_password_screen.dart';
import 'package:omar_242/login_screen.dart';
import 'package:omar_242/reset_password_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_links/uni_links.dart';

// Global navigator key to allow navigation from outside the widget tree
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // تأكد من تهيئة Flutter bindings قبل أي شيء آخر
  WidgetsFlutterBinding.ensureInitialized();
  // قم بتهيئة EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    // TODO: Replace with your Supabase URL and Anon Key
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(
    EasyLocalization(
      // اللغات التي يدعمها تطبيقك
      supportedLocales: [Locale('en'), Locale('ar')],
      // المسار إلى ملفات الترجمة
      path: 'assets/translations',
      // اللغة الافتراضية في حال كانت لغة الجهاز غير مدعومة
      fallbackLocale: Locale('en'),
      // الويدجت الرئيسي لتطبيقك
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
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
    _handleInitialUri();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// Handle incoming links - (e.g., when app is already running)
  void _handleIncomingLinks() {
    _sub = uriLinkStream.listen(
      (Uri? uri) {
        if (!mounted) return;
        if (uri != null &&
            uri.scheme == 'omar242' &&
            uri.host == 'reset-password') {
          _navigatorKey.currentState?.pushNamed('/reset-password');
        }
      },
      onError: (Object err) {
        // Handle error
      },
    );
  }

  /// Handle the initial Uri - (e.g., when app is not running)
  Future<void> _handleInitialUri() async {
    try {
      final uri = await getInitialUri();
      if (uri != null &&
          uri.scheme == 'omar242' &&
          uri.host == 'reset-password') {
        _navigatorKey.currentState?.pushNamed('/reset-password');
      }
    } on FormatException {
      // Potentially ignore if the link is malformed
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      // هذه الأسطر الثلاثة ضرورية لربط MaterialApp مع EasyLocalization
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MyHomePage(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
      },
    );
  }
}

// هذه صفحة تجريبية يمكنك استخدامها لاختبار تغيير اللغة
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // استخدام مفتاح الترجمة من ملفات json
        title: Text('tasks'.tr()),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('login'.tr()),
            const SizedBox(height: 20),
            Text('register'.tr()),
            const SizedBox(height: 40),
            // أزرار لتغيير اللغة للتجربة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // تغيير اللغة إلى العربية
                    context.setLocale(const Locale('ar'));
                  },
                  child: const Text('العربية'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // تغيير اللغة إلى الإنجليزية
                    context.setLocale(const Locale('en'));
                  },
                  child: const Text('English'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
