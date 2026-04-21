import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/package_info_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfoAsync = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: packageInfoAsync.when(
                data: (info) => Text('Version ${info.version}'),
                loading: () => const Text('Loading version...'),
                error: (err, stack) => const Text('Could not load version info'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}