import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/tokens.dart';
import '../../core/ui.dart';
import '../../services/history_store.dart';
import '../../models/history_entry.dart';
import '../viewer/image_viewer_file.dart';

class HistoryScreen extends StatefulWidget {
  final HistoryStore store;
  const HistoryScreen({super.key, required this.store});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry> items = [];
  bool onlyFav = false;

  Future<void> _reload() async {
    final all = await widget.store.load();
    setState(() {
      items = onlyFav ? all.where((e) => e.favorite).toList() : all;
    });
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('History'),
        actions: [
          IconButton(
            icon: Icon(onlyFav ? CupertinoIcons.heart_fill : CupertinoIcons.heart),
            onPressed: () {
              setState(() => onlyFav = !onlyFav);
              _reload();
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.trash),
            onPressed: () async {
              await widget.store.clearAll();
              await _reload();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: items.isEmpty
            ? const Center(child: Text('Aucun historique pour le moment.'))
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final e = items[i];
                  return Glass(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              // ignore: inference_failure_on_function_invocation
                              appleRoute(ImageViewerFile(tag: 'h_${e.id}', path: e.imagePath)),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(T.r16),
                            child: Hero(
                              tag: 'h_${e.id}',
                              child: Image.file(
                                File(e.imagePath),
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${e.style.toUpperCase()} • ${e.resolution}px'),
                              const SizedBox(height: 4),
                              Opacity(
                                opacity: 0.7,
                                child: Text(e.extra.isEmpty ? '—' : e.extra, maxLines: 2),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(e.favorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart),
                          onPressed: () async {
                            await widget.store.toggleFavorite(e.id);
                            await _reload();
                          },
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.delete),
                          onPressed: () async {
                            await widget.store.delete(e.id);
                            await _reload();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
