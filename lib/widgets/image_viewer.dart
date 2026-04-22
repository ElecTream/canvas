import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../services/image_service.dart';

Future<void> openImageViewer(
  BuildContext context,
  ImageService service,
  List<String> names,
  int initialIndex,
) async {
  if (names.isEmpty) return;
  final files = <File>[];
  for (final n in names) {
    files.add(await service.resolve(n));
  }
  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => _ViewerScreen(files: files, initialIndex: initialIndex),
    ),
  );
}

class _ViewerScreen extends StatefulWidget {
  const _ViewerScreen({required this.files, required this.initialIndex});
  final List<File> files;
  final int initialIndex;

  @override
  State<_ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<_ViewerScreen> {
  late final PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex.clamp(0, widget.files.length - 1);
    _controller = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: widget.files.length,
            pageController: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            builder: (ctx, i) {
              final f = widget.files[i];
              if (!f.existsSync()) {
                return PhotoViewGalleryPageOptions.customChild(
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 64,
                      color: Colors.white30,
                    ),
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained,
                );
              }
              return PhotoViewGalleryPageOptions(
                imageProvider: FileImage(f),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4,
                heroAttributes: PhotoViewHeroAttributes(tag: 'image-${f.path}'),
              );
            },
            loadingBuilder: (_, __) => const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  if (widget.files.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '${_current + 1} / ${widget.files.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
