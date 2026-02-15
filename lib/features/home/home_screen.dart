import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/tokens.dart';
import '../../core/ui.dart';
import '../../services/cache_service.dart';
import '../../services/compress_service.dart';
import '../../services/history_store.dart';
import '../../services/settings_service.dart';
import '../../services/transform_service.dart';

import '../viewer/image_viewer.dart';
import '../settings/settings_screen.dart';
import '../history/history_screen.dart' as hist;

enum Style { cartoon, anime, threeD }

extension StyleX on Style {
  String get label => switch (this) {
        Style.cartoon => 'Cartoon',
        Style.anime => 'Anime',
        Style.threeD => '3D',
      };

  String prompt(String extra) {
    final core = switch (this) {
      Style.cartoon =>
        'Transform into a clean modern cartoon illustration. Preserve identity, pose, framing. Crisp lines, smooth shading.',
      Style.anime =>
        'Transform into high-quality anime style. Preserve identity, pose, framing. Cinematic lighting, clean linework.',
      Style.threeD =>
        'Transform into a premium 3D character render. Preserve identity, pose, framing. Studio lighting, realistic materials.',
    };
    const rules = 'No text. No watermark. No logo. High quality.';
    final e = extra.trim();
    return e.isEmpty ? '$core $rules' : '$core $rules Extra: $e';
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _picker = ImagePicker();

  final _cache = CacheService();
  final _compress = CompressService();
  final _settings = SettingsService();
  final _history = HistoryStore();

  late final _api = TransformService(endpoint: 'https://matthiasai.workers.dev');

  XFile? _singleSource;
  List<XFile> _batchSources = [];

  Uint8List? _srcPreview;
  final Map<Style, Uint8List> _results = {};

  bool _busy = false;
  String _status = '';
  String _extra = '';

  @override
  void initState() {
    super.initState();
    _settings.load().then((_) {
      if (mounted) setState(() {});
    });
  }

  bool get _hasInput => _singleSource != null || _batchSources.isNotEmpty;

  void _toast(String msg) {
    final m = ScaffoldMessenger.of(context);
    m.clearSnackBars();
    m.showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _pickCamera() async {
    HapticFeedback.selectionClick();
    final f = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 95,
      maxWidth: 2400,
    );
    if (f == null) return;

    final bytes = await File(f.path).readAsBytes();
    if (!mounted) return;

    setState(() {
      _singleSource = f;
      _batchSources = [];
      _results.clear();
      _status = '';
      _srcPreview = bytes;
    });
  }

  Future<void> _pickGallery() async {
    HapticFeedback.selectionClick();

    if (_settings.proMode) {
      final list = await _picker.pickMultiImage(imageQuality: 95, maxWidth: 2400);
      if (list.isEmpty) return;

      final trimmed = list.take(_settings.batchCount).toList();
      final bytes = await File(trimmed.first.path).readAsBytes();
      if (!mounted) return;

      setState(() {
        _batchSources = trimmed;
        _singleSource = null;
        _results.clear();
        _status = '';
        _srcPreview = bytes;
      });
    } else {
      final f = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
        maxWidth: 2400,
      );
      if (f == null) return;

      final bytes = await File(f.path).readAsBytes();
      if (!mounted) return;

      setState(() {
        _singleSource = f;
        _batchSources = [];
        _results.clear();
        _status = '';
        _srcPreview = bytes;
      });
    }
  }

  String _cacheKey(Style style, int len, int res, String extra) {
    return '${style.name}-$len-$res-${extra.trim()}';
  }

  Future<void> _generateOneFile(XFile file, {required int index, required int total}) async {
    setState(() => _status = total > 1 ? 'Photo ${index + 1}/$total • Compression…' : 'Compression…');

    // ✅ compression (idéalement en isolate dans CompressService)
    final jpg = await _compress.compressJpg(File(file.path));
    final res = _settings.resolution;

    setState(() => _status = total > 1 ? 'Photo ${index + 1}/$total • Génération…' : 'Génération…');

    // ✅ génération parallèle + affichage dès qu'un style est prêt
    final futures = <Future<void>>[];

    for (final style in Style.values) {
      futures.add(() async {
        final key = _cacheKey(style, jpg.length, res, _extra);

        // 1) Cache hit => update UI instant
        final cached = await _cache.get(key);
        if (cached != null) {
          _results[style] = cached;
          if (mounted) setState(() {}); // ✅ affichage immédiat

          if (mounted) await precacheImage(MemoryImage(cached), context);
          await _history.add(style: style.name, pngBytes: cached, resolution: res, extra: _extra);
          return;
        }

        // 2) Worker => image bytes directe (PNG)
        final out = await _api.transform(
          jpegBytes: jpg,
          prompt: style.prompt(_extra),
          resolution: res,
        );

        _results[style] = out;
        if (mounted) setState(() {}); // ✅ affichage immédiat

        await _cache.put(key, out);
        if (mounted) await precacheImage(MemoryImage(out), context);

        await _history.add(style: style.name, pngBytes: out, resolution: res, extra: _extra);
      }());
    }

    await Future.wait(futures);
  }

  Future<void> _generate() async {
    if (!_hasInput) {
      _toast('Ajoute une photo d’abord.');
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() {
      _busy = true;
      _status = 'Démarrage…';
      _results.clear();
    });

    try {
      if (_batchSources.isNotEmpty) {
        final total = _batchSources.length;
        for (var i = 0; i < total; i++) {
          final bytes = await File(_batchSources[i].path).readAsBytes();
          if (!mounted) return;
          setState(() => _srcPreview = bytes);

          await _generateOneFile(_batchSources[i], index: i, total: total);
        }
      } else {
        await _generateOneFile(_singleSource!, index: 0, total: 1);
      }

      if (!mounted) return;
      setState(() => _status = 'Terminé');
      HapticFeedback.lightImpact();
    } catch (_) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      _toast('Erreur réseau/génération. Réessaie.');
      setState(() => _status = 'Erreur');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share(Style style) async {
    final bytes = _results[style];
    if (bytes == null) return;
    HapticFeedback.selectionClick();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/transformation_${style.name}_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles([XFile(file.path)], text: 'Transformation AI • ${style.label}');
  }

  void _openSettings() {
    // ignore: inference_failure_on_function_invocation
    Navigator.of(context).push(appleRoute(SettingsScreen(settings: _settings))).then((_) {
      setState(() {});
    });
  }

  void _openHistory() {
    // ignore: inference_failure_on_function_invocation
    Navigator.of(context).push(appleRoute(hist.HistoryScreen(store: _history)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.bg,
      body: Stack(
        children: [
          const _Background(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                children: [
                  Glass(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Transformation AI', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Opacity(
                                opacity: 0.75,
                                child: Text(
                                  _settings.proMode
                                      ? 'Pro • ${_settings.resolution}px • Batch ${_settings.batchCount}'
                                      : '${_settings.resolution}px • Cartoon • Anime • 3D',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        _IconGlass(icon: CupertinoIcons.gear, onTap: _openSettings),
                        const SizedBox(width: 10),
                        _IconGlass(icon: CupertinoIcons.clock, onTap: _openHistory),
                        const SizedBox(width: 10),
                        _IconGlass(icon: CupertinoIcons.camera, onTap: _pickCamera),
                        const SizedBox(width: 10),
                        _IconGlass(icon: CupertinoIcons.photo_on_rectangle, onTap: _pickGallery),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(T.r28),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B0D12),
                                border: Border.all(color: T.stroke),
                              ),
                              child: _srcPreview == null
                                  ? Center(
                                      child: Opacity(
                                        opacity: 0.75,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(CupertinoIcons.sparkles, size: 34),
                                            SizedBox(height: 10),
                                            Text('Ajoute une photo\npuis génère les styles.'),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Image.memory(_srcPreview!, fit: BoxFit.cover, gaplessPlayback: true),
                            ),
                          ),
                          if (_busy)
                            Positioned.fill(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                                child: Container(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  alignment: Alignment.center,
                                  child: const CupertinoActivityIndicator(radius: 14),
                                ),
                              ),
                            ),
                          if (_status.isNotEmpty)
                            Positioned(
                              left: 12,
                              right: 12,
                              bottom: 12,
                              child: Glass(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Row(
                                  children: [
                                    const Icon(CupertinoIcons.info, size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _status,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Glass(
                    child: Column(
                      children: [
                        CupertinoTextField(
                          placeholder: 'Optionnel: “fond studio”, “lumière néon”…',
                          onChanged: (v) => _extra = v,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(T.r16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _Primary(
                          label: _busy ? '...' : (_settings.proMode ? 'Générer (Batch)' : 'Générer les 3 styles'),
                          enabled: !_busy && _hasInput,
                          onTap: _generate,
                        ),
                        const SizedBox(height: 12),
                        _ResultRow(
                          busy: _busy,
                          results: _results,
                          onOpen: (style, bytes) {
                            Navigator.of(context).push(
                              // ignore: inference_failure_on_function_invocation
                              appleRoute(ImageViewer(tag: 'res_${style.name}', bytes: bytes)),
                            );
                          },
                          onShare: _share,
                        ),
                      ],
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

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.7),
            radius: 1.2,
            colors: [
              const Color(0xFF1B2A55).withValues(alpha: 0.55),
              T.bg,
            ],
          ),
        ),
      ),
    );
  }
}

class _IconGlass extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconGlass({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.all(12),
      child: InkWell(onTap: onTap, child: Icon(icon, size: 20)),
    );
  }
}

class _Primary extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  const _Primary({required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: enabled ? 1 : 0.45,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(T.r20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                T.a.withValues(alpha: 0.95),
                T.b.withValues(alpha: 0.75),
              ],
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                color: T.a.withValues(alpha: 0.18),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(label, style: Theme.of(context).textTheme.titleSmall),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final bool busy;
  final Map<Style, Uint8List> results;
  final void Function(Style style, Uint8List bytes) onOpen;
  final Future<void> Function(Style style) onShare;

  const _ResultRow({
    required this.busy,
    required this.results,
    required this.onOpen,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Style.values.map((s) {
        final bytes = results[s];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Glass(
              radius: T.r20,
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(s.label, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 10),
                  AspectRatio(
                    aspectRatio: 1,
                    child: bytes == null
                        ? (busy ? const Skeleton(radius: T.r16) : const _EmptyTile())
                        : GestureDetector(
                            onTap: () => onOpen(s, bytes),
                            child: Hero(
                              tag: 'res_${s.name}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(T.r16),
                                child: Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: bytes == null ? null : () => onShare(s),
                    child: Glass(
                      radius: T.r16,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(CupertinoIcons.square_arrow_up, size: 18),
                          SizedBox(width: 8),
                          Text('Share'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyTile extends StatelessWidget {
  const _EmptyTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(T.r16),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      alignment: Alignment.center,
      child: const Icon(CupertinoIcons.photo, size: 22),
    );
  }
}

class Skeleton extends StatefulWidget {
  final double radius;
  const Skeleton({super.key, required this.radius});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: Container(
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05)),
            child: ShaderMask(
              shaderCallback: (r) {
                return LinearGradient(
                  begin: Alignment(-1 + 2 * t, -0.2),
                  end: Alignment(-0.2 + 2 * t, 0.2),
                  colors: [
                    Colors.white.withValues(alpha: 0.06),
                    Colors.white.withValues(alpha: 0.14),
                    Colors.white.withValues(alpha: 0.06),
                  ],
                ).createShader(r);
              },
              blendMode: BlendMode.srcATop,
              child: Container(color: Colors.white.withValues(alpha: 0.06)),
            ),
          ),
        );
      },
    );
  }
}
