import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialize = ref.watch(initializationProvider);

    return MaterialApp(
      title: 'Canvas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF242424),
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: initialize.when(
        data: (user) {
          // If the future resolved but we have no user, sign-in silently
          // failed at some earlier point — surface the same error UI.
          if (user == null) {
            return const _AuthErrorScreen(
              error: 'Sign-in returned no user.',
            );
          }
          return const HomeScreen();
        },
        loading: () => const SplashScreen(),
        error: (e, stackTrace) => _AuthErrorScreen(error: e.toString()),
      ),
    );
  }
}

class _AuthErrorScreen extends ConsumerWidget {
  const _AuthErrorScreen({this.error});

  final String? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Sign-in failed. Check connection and try again.',
                textAlign: TextAlign.center,
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(initializationProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
