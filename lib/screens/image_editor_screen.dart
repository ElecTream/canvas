import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../widgets/glass_app_bar.dart';
import '../widgets/glass_card.dart';

enum _EditorTab { crop, rotate }

class ImageEditorScreen extends StatefulWidget {
  const ImageEditorScreen({super.key, required this.bytes});

  final Uint8List bytes;

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  final CropController _cropController = CropController();

  late Uint8List _workingBytes;
  int _cropVersion = 0;
  int _quarterTurns = 0;

  _EditorTab _tab = _EditorTab.crop;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _workingBytes = widget.bytes;
  }

  Future<void> _rotate(int direction) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final decoded = await Future(() => img.decodeImage(_workingBytes));
      if (decoded == null) return;
      final rotated = img.copyRotate(decoded, angle: direction * 90);
      final encoded = Uint8List.fromList(img.encodeJpg(rotated, quality: 98));
      if (!mounted) return;
      setState(() {
        _workingBytes = encoded;
        _quarterTurns = (_quarterTurns + direction) % 4;
        _cropVersion++;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _resetRotation() {
    if (_quarterTurns == 0 && identical(_workingBytes, widget.bytes)) return;
    setState(() {
      _workingBytes = widget.bytes;
      _quarterTurns = 0;
      _cropVersion++;
    });
  }

  void _resetCrop() {
    setState(() => _cropVersion++);
  }

  void _resetActive() {
    switch (_tab) {
      case _EditorTab.crop:
        _resetCrop();
      case _EditorTab.rotate:
        _resetRotation();
    }
  }

  void _apply() {
    if (_busy) return;
    setState(() => _busy = true);
    _cropController.crop();
  }

  Future<void> _onCropped(CropResult result) async {
    if (result is! CropSuccess) {
      if (mounted) setState(() => _busy = false);
      return;
    }
    try {
      final decoded = img.decodeImage(result.croppedImage);
      if (decoded == null) {
        if (mounted) Navigator.pop<Uint8List?>(context, result.croppedImage);
        return;
      }
      final out = Uint8List.fromList(img.encodeJpg(decoded, quality: 92));
      if (mounted) Navigator.pop<Uint8List?>(context, out);
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _busy ? null : () => Navigator.pop(context),
        ),
        title: const Text('Edit image'),
        actions: [
          IconButton(
            tooltip: 'Apply',
            icon: const Icon(Icons.check),
            onPressed: _busy ? null : _apply,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            bottom: 12,
          ),
          child: Column(
            children: [
              Expanded(child: _buildPreview()),
              const SizedBox(height: 12),
              _buildTabContent(),
              const SizedBox(height: 10),
              _buildTabBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      child: Crop(
        key: ValueKey<int>(_cropVersion),
        controller: _cropController,
        image: _workingBytes,
        onCropped: _onCropped,
        baseColor: Colors.transparent,
        maskColor: Colors.black.withValues(alpha: 0.45),
        progressIndicator: const CircularProgressIndicator(),
        interactive: true,
        cornerDotBuilder: (size, edgeAlignment) => const DotControl(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      child: SizedBox(
        height: 72,
        child: Row(
          children: [
            Expanded(child: _tabBody()),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: _busy ? null : _resetActive,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabBody() {
    final teal = Theme.of(context).colorScheme.secondary;
    switch (_tab) {
      case _EditorTab.crop:
        return const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Drag handles to crop. Pinch to zoom.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        );
      case _EditorTab.rotate:
        return Row(
          children: [
            IconButton(
              tooltip: 'Rotate 90° CCW',
              onPressed: _busy ? null : () => _rotate(-1),
              icon: const Icon(Icons.rotate_left),
              color: teal,
            ),
            IconButton(
              tooltip: 'Rotate 90° CW',
              onPressed: _busy ? null : () => _rotate(1),
              icon: const Icon(Icons.rotate_right),
              color: teal,
            ),
            const SizedBox(width: 6),
            Text(
              '${_quarterTurns * 90}°',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildTabBar() {
    return GlassCard(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          _tabButton(_EditorTab.crop, Icons.crop, 'Crop'),
          _tabButton(_EditorTab.rotate, Icons.rotate_90_degrees_ccw, 'Rotate'),
        ],
      ),
    );
  }

  Widget _tabButton(_EditorTab tab, IconData icon, String label) {
    final selected = _tab == tab;
    final teal = Theme.of(context).colorScheme.secondary;
    return Expanded(
      child: Material(
        color: selected ? teal.withValues(alpha: 0.18) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _busy ? null : () => setState(() => _tab = tab),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: selected ? teal : Colors.white70),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? teal : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
