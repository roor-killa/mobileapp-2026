import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/tokens.dart';
import '../../core/ui.dart';

class ImageViewerFile extends StatelessWidget {
  final String tag;
  final String path;

  const ImageViewerFile({super.key, required this.tag, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: tag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(T.r28),
                  child: RepaintBoundary(
                    child: Image.file(File(path), fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 16,
              child: Glass(
                padding: const EdgeInsets.all(10),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
