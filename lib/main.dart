import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/palette_provider.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'theme/glass_background.dart';
import 'theme/palettes.dart';
import 'widgets/glass_card.dart';

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
    final palette = ref.watch(paletteProvider);

    return MaterialApp(
      title: 'Canvas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(paletteColorsOf(palette)),
      builder: (context, child) => GlassBackground(child: child ?? const SizedBox.shrink()),
      home: initialize.when(
        data: (user) {
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
    final teal = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: GlassCard(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 44, color: teal),
                  const SizedBox(height: 16),
                  const Text(
                    'Sign-in failed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check your connection and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, color: Colors.white38),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: teal.withValues(alpha: 0.9),
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () => ref.invalidate(initializationProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
