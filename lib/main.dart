import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/palette_provider.dart';
import 'providers/sync_provider.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/legacy_firebase_gate.dart';
import 'theme/app_theme.dart';
import 'theme/glass_background.dart';
import 'theme/palettes.dart';
import 'utils/app_snackbar.dart';
import 'widgets/glass_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is only needed to bridge legacy Firestore data into drift on
  // first boot of a post-Phase-5 install. Once the migration has run (fresh
  // installs complete it immediately with an empty query, upgrades complete
  // it after the import), the flag flips and Firebase is never initialised
  // again. Keeps the binary dependency but removes the runtime footprint.
  final prefs = await SharedPreferences.getInstance();
  if (!(prefs.getBool(LegacyFirebaseGate.migrationCompletePrefKey) ?? false)) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Flush any pending debounced sync before the OS suspends us.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      ref.read(debouncedSyncProvider).flush();
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialize = ref.watch(initializationProvider);
    final palette = ref.watch(paletteProvider);
    // Keeps the sign-in → sync trigger alive for the lifetime of the app.
    ref.watch(signInTriggerProvider);

    return MaterialApp(
      title: 'Canvas',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: AppTheme.build(paletteColorsOf(palette)),
      builder: (context, child) =>
          GlassBackground(child: child ?? const SizedBox.shrink()),
      home: initialize.when(
        data: (_) => const HomeScreen(),
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
                  Icon(Icons.error_outline, size: 44, color: teal),
                  const SizedBox(height: 16),
                  const Text(
                    'Startup failed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Something went wrong while starting Canvas.',
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
