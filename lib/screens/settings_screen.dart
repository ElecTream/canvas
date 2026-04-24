import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/note.dart';
import '../providers/auth_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/package_info_provider.dart';
import '../providers/palette_provider.dart';
import '../providers/sync_provider.dart';
import '../services/auth_service.dart';
import '../sync/sync_service.dart';
import '../theme/palettes.dart';
import '../utils/app_snackbar.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/glass_card.dart';
import '../widgets/markdown_guide.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfoAsync = ref.watch(packageInfoProvider);
    final selected = ref.watch(paletteProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        automaticallyImplyLeading: false,
        actions: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.only(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            bottom: 24,
          ),
          children: [
          const _SectionLabel('Account'),
          const _AccountCard(),
          const SizedBox(height: 20),
          const _SectionLabel('Sync'),
          const _SyncCard(),
          const SizedBox(height: 12),
          const _DriveUsageCard(),
          const SizedBox(height: 12),
          const _ScanDriveCard(),
          const SizedBox(height: 20),
          const _SectionLabel('Appearance'),
          GlassCard(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Palette',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  palettes[selected]!.label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final p in AccentPalette.values)
                      _PaletteSwatch(
                        palette: p,
                        colors: palettes[p]!,
                        selected: p == selected,
                        onTap: () => ref.read(paletteProvider.notifier).set(p),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Backup'),
          const _ExportBackupCard(),
          const SizedBox(height: 20),
          const _SectionLabel('Markdown'),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            onTap: () => showMarkdownGuide(context),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reference',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'GitHub Flavored Markdown. Tap for full reference.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('About'),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Canvas',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      packageInfoAsync.when(
                        data: (info) => Text(
                          'Version ${info.version}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        loading: () => const Text(
                          'Loading…',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                        error: (_, __) => const Text(
                          'Version unavailable',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends ConsumerWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(signedInUserProvider);
    final accent = Theme.of(context).colorScheme.secondary;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: userAsync.when(
        loading: () => const SizedBox(
          height: 40,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (e, _) => Text(
          'Auth error: $e',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        data: (user) => user != null
            ? _SignedInView(user: user)
            : _SignedOutView(accent: accent),
      ),
    );
  }
}

class _SignedInView extends ConsumerWidget {
  const _SignedInView({required this.user});
  final SignedInUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = Theme.of(context).colorScheme.secondary;
    final photo = user.photoUrl;
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: accent.withValues(alpha: 0.2),
          foregroundImage: photo != null ? NetworkImage(photo) : null,
          child: photo == null ? Icon(Icons.person, color: accent) : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName ?? 'Signed in',
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                user.email,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () async {
            await ref.read(authServiceProvider).signOut();
          },
          child: const Text('Sign out'),
        ),
      ],
    );
  }
}

class _SignedOutView extends ConsumerWidget {
  const _SignedOutView({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.cloud_off_outlined, color: accent),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Local only',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Sign in with Google to enable Drive sync.',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: accent.withValues(alpha: 0.9),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              try {
                await ref.read(authServiceProvider).signIn();
              } catch (e) {
                if (!context.mounted) return;
                showAppSnack(context, 'Sign-in failed: $e');
              }
            },
            icon: const Icon(Icons.login),
            label: const Text('Sign in with Google'),
          ),
        ),
      ],
    );
  }
}

class _SyncCard extends ConsumerWidget {
  const _SyncCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = Theme.of(context).colorScheme.secondary;
    final user = ref.watch(signedInUserProvider).valueOrNull;
    final statusAsync = ref.watch(syncStatusProvider);
    final status = statusAsync.valueOrNull ?? SyncStatus.initial;
    final busy = status.phase == SyncPhase.running;
    final signedIn = user != null;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_sync_outlined, color: accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Google Drive',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _statusLine(status, signedIn),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: accent.withValues(alpha: 0.9),
                foregroundColor: Colors.black,
              ),
              onPressed: (!signedIn || busy)
                  ? null
                  : () async {
                      try {
                        final report =
                            await ref.read(syncServiceProvider).syncNow();
                        if (!context.mounted) return;
                        showAppSnack(
                          context,
                          'Synced: ${report.pulled} pulled, '
                          '${report.pushed} pushed'
                          '${report.conflicts > 0 ? ', ${report.conflicts} conflicts' : ''}',
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        showAppSnack(context, 'Sync failed: $e');
                      }
                    },
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.sync),
              label: Text(busy ? 'Syncing…' : 'Sync now'),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLine(SyncStatus s, bool signedIn) {
    if (!signedIn) return 'Sign in to enable Drive sync.';
    if (s.phase == SyncPhase.running) return 'Syncing with Google Drive…';
    if (s.lastError != null) return 'Last sync: error — ${s.lastError}';
    final last = s.lastSyncAt;
    if (last == null) return 'Not synced yet.';
    final fmt = DateFormat.yMd().add_jm().format(last.toLocal());
    final r = s.lastReport;
    final b = s.lastBlobReport;
    final notePart = r == null
        ? ''
        : '${r.pulled} pulled, ${r.pushed} pushed'
            '${r.conflicts > 0 ? ', ${r.conflicts} conflicts' : ''}';
    final blobPart = (b == null || (b.pulled == 0 && b.pushed == 0))
        ? ''
        : ' · blobs: ${b.pushed} up, ${b.pulled} down';
    final orphanPart = s.lastOrphansDeleted > 0
        ? ' · cleaned ${s.lastOrphansDeleted} orphan'
            '${s.lastOrphansDeleted == 1 ? '' : 's'}'
        : '';
    return 'Last sync: $fmt · $notePart$blobPart$orphanPart';
  }
}

class _DriveUsageCard extends ConsumerStatefulWidget {
  const _DriveUsageCard();

  @override
  ConsumerState<_DriveUsageCard> createState() => _DriveUsageCardState();
}

class _DriveUsageCardState extends ConsumerState<_DriveUsageCard> {
  bool _purging = false;

  Future<void> _purge() async {
    setState(() => _purging = true);
    try {
      final r = await ref
          .read(syncServiceProvider)
          .cleanupOrphansNowVerbose();
      if (!mounted) return;
      showAppSnack(
        context,
        'Drive ${r.scanned}f / ${r.uniqueUuids}u · local ${r.local} · '
        'orphans ${r.orphanUuids} · dupes ${r.dupes} · '
        'deleted ${r.deleted}'
        '${r.failed > 0 ? ' · failed ${r.failed}' : ''}',
        duration: const Duration(seconds: 8),
      );
      ref.invalidate(driveUsageProvider);
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, 'Purge failed: $e');
    } finally {
      if (mounted) setState(() => _purging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    final signedIn = ref.watch(signedInUserProvider).valueOrNull != null;
    if (!signedIn) return const SizedBox.shrink();

    final usageAsync = ref.watch(driveUsageProvider);
    final active = ref.watch(activeNotesProvider).length;
    final archived = ref.watch(archivedNotesProvider).length;
    final localTotal = active + archived;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(Icons.storage_outlined, color: accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Drive usage',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                usageAsync.when(
                  loading: () => const Text(
                    'Fetching…',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5),
                  ),
                  error: (e, _) => Text(
                    'Unavailable: $e',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12.5),
                  ),
                  data: (u) {
                    final archivedPart =
                        archived > 0 ? ' · $archived archived' : '';
                    final mismatch = u.recordCount - localTotal;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_fmtBytes(u.bytes)} · '
                          '$active note${active == 1 ? '' : 's'}'
                          '$archivedPart',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12.5),
                        ),
                        if (mismatch > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.amberAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '$mismatch orphan file${mismatch == 1 ? '' : 's'} on Drive',
                                  style: const TextStyle(
                                    color: Colors.amberAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _purging ? null : _purge,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.amberAccent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  minimumSize: const Size(0, 28),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: _purging
                                    ? const SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.amberAccent,
                                        ),
                                      )
                                    : const Text(
                                        'Purge',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () => ref.invalidate(driveUsageProvider),
          ),
        ],
      ),
    );
  }

  String _fmtBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }
}

class _ScanDriveCard extends ConsumerStatefulWidget {
  const _ScanDriveCard();

  @override
  ConsumerState<_ScanDriveCard> createState() => _ScanDriveCardState();
}

class _ScanDriveCardState extends ConsumerState<_ScanDriveCard> {
  bool _busy = false;

  Future<void> _scan() async {
    setState(() => _busy = true);
    try {
      final svc = ref.read(syncServiceProvider);
      final report = await svc.dryRunOrphans();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => _OrphanReportDialog(report: report),
      );
      ref.invalidate(driveUsageProvider);
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, 'Scan failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    final signedIn = ref.watch(signedInUserProvider).valueOrNull != null;
    if (!signedIn) return const SizedBox.shrink();
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: _busy ? null : _scan,
      child: Row(
        children: [
          Icon(Icons.cleaning_services_outlined, color: accent),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan Drive',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  'Compare local notes with Drive; clean up orphans.',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ],
            ),
          ),
          if (_busy)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.45)),
        ],
      ),
    );
  }
}

class _OrphanReportDialog extends ConsumerStatefulWidget {
  const _OrphanReportDialog({required this.report});
  final OrphanReport report;

  @override
  ConsumerState<_OrphanReportDialog> createState() =>
      _OrphanReportDialogState();
}

class _OrphanReportDialogState extends ConsumerState<_OrphanReportDialog> {
  bool _cleaning = false;

  Future<void> _clean() async {
    setState(() => _cleaning = true);
    try {
      final deleted =
          await ref.read(syncServiceProvider).cleanupOrphansNow();
      if (!mounted) return;
      Navigator.pop(context);
      showAppSnack(context, 'Removed $deleted orphan file${deleted == 1 ? '' : 's'}.');
      ref.invalidate(driveUsageProvider);
    } catch (e) {
      if (!mounted) return;
      setState(() => _cleaning = false);
      showAppSnack(context, 'Clean up failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    final orphansShort = r.orphans.take(3).map((id) => '• $id').join('\n');
    final missingShort =
        r.localOnly.take(3).map((id) => '• $id').join('\n');

    return AlertDialog(
      title: const Text('Drive state'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${r.remoteCount} note file${r.remoteCount == 1 ? '' : 's'} on Drive'),
          Text('${r.localCount} local record${r.localCount == 1 ? '' : 's'}'),
          const SizedBox(height: 12),
          Text(
            r.orphans.isEmpty
                ? 'No orphans on Drive.'
                : '${r.orphans.length} orphan file${r.orphans.length == 1 ? '' : 's'} on Drive:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (orphansShort.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(orphansShort,
                style: const TextStyle(fontSize: 11, color: Colors.white60)),
            if (r.orphans.length > 3)
              Text('…and ${r.orphans.length - 3} more',
                  style:
                      const TextStyle(fontSize: 11, color: Colors.white60)),
          ],
          const SizedBox(height: 10),
          Text(
            r.localOnly.isEmpty
                ? 'All local notes present on Drive.'
                : '${r.localOnly.length} local-only (not yet synced):',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (missingShort.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(missingShort,
                style: const TextStyle(fontSize: 11, color: Colors.white60)),
            if (r.localOnly.length > 3)
              Text('…and ${r.localOnly.length - 3} more',
                  style:
                      const TextStyle(fontSize: 11, color: Colors.white60)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _cleaning ? null : () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (r.orphans.isNotEmpty)
          FilledButton(
            onPressed: _cleaning ? null : _clean,
            child: _cleaning
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Clean up'),
          ),
      ],
    );
  }
}

class _ExportBackupCard extends ConsumerStatefulWidget {
  const _ExportBackupCard();

  @override
  ConsumerState<_ExportBackupCard> createState() => _ExportBackupCardState();
}

class _ExportBackupCardState extends ConsumerState<_ExportBackupCard> {
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final all = ref.read(notesStreamProvider).valueOrNull ?? const <Note>[];
      final dir = await _pickExportDir();
      final ts = DateTime.now()
          .toUtc()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final path = p.join(dir.path, 'canvas-backup-$ts.json');
      final payload = jsonEncode({
        'exportedAt': DateTime.now().toUtc().toIso8601String(),
        'source': 'canvas',
        'schemaNote':
            'createdAt/updatedAt are ISO-8601 strings. Attachments list is filename-only; blob bytes live on Drive or in the app\'s local image store.',
        'notes': all.map(_sanitizeNote).toList(),
      });
      final f = File(path);
      await f.writeAsString(payload, flush: true);
      if (!mounted) return;
      showAppSnack(
        context,
        'Exported ${all.length} notes → ${p.basename(path)}',
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, 'Export failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Directory> _pickExportDir() async {
    try {
      final d = await getDownloadsDirectory();
      if (d != null) return d;
    } catch (_) {}
    try {
      final ext = await getExternalStorageDirectory();
      if (ext != null) return ext;
    } catch (_) {}
    return getApplicationDocumentsDirectory();
  }

  Map<String, dynamic> _sanitizeNote(Note n) {
    final m = Map<String, dynamic>.from(n.toJson());
    m['createdAt'] = n.createdAt.toDate().toUtc().toIso8601String();
    m['updatedAt'] = n.updatedAt.toDate().toUtc().toIso8601String();
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    final all = ref.watch(notesStreamProvider).valueOrNull ?? const <Note>[];
    final active = all.where((n) => !n.isArchived).length;
    final archived = all.where((n) => n.isArchived).length;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(Icons.download_outlined, color: accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Export backup',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '$active active · $archived archived · JSON file',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: accent.withValues(alpha: 0.9),
              foregroundColor: Colors.black,
            ),
            onPressed: _busy ? null : _export,
            child: _busy
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Text('Export'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  const _PaletteSwatch({
    required this.palette,
    required this.colors,
    required this.selected,
    required this.onTap,
  });

  final AccentPalette palette;
  final PaletteColors colors;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = colors.accent;
    return SizedBox(
      width: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.blob1,
                      colors.surface,
                      colors.accent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? accent
                        : Colors.white.withValues(alpha: 0.12),
                    width: selected ? 2.2 : 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.35),
                            blurRadius: 12,
                            spreadRadius: 0.5,
                          ),
                        ]
                      : const [],
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: accent,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            colors.label.split(' · ').first,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: selected ? 0.95 : 0.65),
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
