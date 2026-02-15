import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/tokens.dart';
import '../../core/ui.dart';

class ImageViewer extends StatelessWidget {
  final String tag;
  final Uint8List bytes;

  const ImageViewer({
    super.key,
    required this.tag,
    required this.bytes,
  });

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
                    child: Image.memory(
                      bytes,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
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
