import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import '../app_theme.dart';

/// Horloge analogique locale, inspirée du tutoriel
/// [Flutter Analog Clock Light/Dark](https://github.com/abuanwar072/Flutter-Analog-Clock-Light-Dark-Theme).
/// Dessinée avec [CustomPainter] : pas besoin de flutter_svg ni google_fonts.
class AnalogClock extends StatefulWidget {
  const AnalogClock({
    super.key,
    this.size = 120,
    this.showDigital = true,
  });

  final double size;
  final bool showDigital;

  @override
  State<AnalogClock> createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> with SingleTickerProviderStateMixin {
  /// Heure « haute fréquence » pour une aiguille des secondes fluide (comme une vraie horloge).
  late Ticker _ticker;
  DateTime _now = DateTime.now();
  int _lastDigitalSecond = -1;
  String _digital = '';
  String _dateStr = '';

  @override
  void initState() {
    super.initState();
    _syncDigitalIfNeeded();
    _ticker = createTicker((_) {
      if (!mounted) return;
      _now = DateTime.now();
      _syncDigitalIfNeeded();
      setState(() {});
    })..start();
  }

  void _syncDigitalIfNeeded() {
    if (!widget.showDigital) return;
    final s = _now.second;
    if (s != _lastDigitalSecond) {
      _lastDigitalSecond = s;
      _digital = _formatDigital(_now);
      _dateStr = _formatDateFr(_now);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RepaintBoundary(
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _AnalogClockPainter(
                time: _now,
                faceColor: AppTheme.cardElevated,
                rimColor: AppTheme.primary.withValues(alpha: 0.55),
                tickColor: AppTheme.textSecondary,
                hourColor: AppTheme.textPrimary,
                minuteColor: AppTheme.primaryLight,
                secondColor: AppTheme.secondary,
              ),
            ),
          ),
        ),
        if (widget.showDigital) ...[
          const SizedBox(height: 8),
          Text(
            _digital,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            _dateStr,
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  static String _formatDigital(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    final s = d.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static String _formatDateFr(DateTime d) {
    const days = ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];
    const months = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    final wd = days[(d.weekday - 1) % 7];
    final mo = months[d.month - 1];
    return '$wd ${d.day} $mo ${d.year}';
  }
}

class _AnalogClockPainter extends CustomPainter {
  _AnalogClockPainter({
    required this.time,
    required this.faceColor,
    required this.rimColor,
    required this.tickColor,
    required this.hourColor,
    required this.minuteColor,
    required this.secondColor,
  });

  final DateTime time;
  final Color faceColor;
  final Color rimColor;
  final Color tickColor;
  final Color hourColor;
  final Color minuteColor;
  final Color secondColor;

  /// Angle en radians : 0 h en haut (comme une vraie horloge).
  static double _rad(double turnsFromTop) => turnsFromTop * 2 * math.pi - math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;

    // Fond du cadran
    final facePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          faceColor,
          AppTheme.card.withValues(alpha: 0.95),
        ],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r - 2, facePaint);

    // Bord néon
    final rim = Paint()
      ..color = rimColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(c, r - 1.5, rim);

    // Graduations (60 traits fins + 12 plus marqués)
    for (var i = 0; i < 60; i++) {
      final ang = i * 2 * math.pi / 60 - math.pi / 2;
      final isMajor = i % 5 == 0;
      final inner = r - (isMajor ? 14 : 8);
      final outer = r - 4;
      final p1 = Offset(c.dx + inner * math.cos(ang), c.dy + inner * math.sin(ang));
      final p2 = Offset(c.dx + outer * math.cos(ang), c.dy + outer * math.sin(ang));
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = isMajor ? tickColor.withValues(alpha: 0.95) : tickColor.withValues(alpha: 0.35)
          ..strokeWidth = isMajor ? 2 : 1
          ..strokeCap = StrokeCap.round,
      );
    }

    final sec = time.second + time.millisecond / 1000.0;
    final min = time.minute + sec / 60.0;
    final hour = (time.hour % 12) + min / 60.0;

    // Aiguille heures
    _hand(
      canvas,
      c,
      _rad(hour / 12),
      length: r * 0.46,
      width: 5,
      color: hourColor,
    );
    // Aiguille minutes
    _hand(
      canvas,
      c,
      _rad(min / 60),
      length: r * 0.62,
      width: 3.2,
      color: minuteColor,
    );
    // Aiguille secondes
    _hand(
      canvas,
      c,
      _rad(sec / 60),
      length: r * 0.68,
      width: 1.5,
      color: secondColor,
    );

    // Capot central
    canvas.drawCircle(
      c,
      5,
      Paint()..color = AppTheme.primary,
    );
    canvas.drawCircle(
      c,
      2.5,
      Paint()..color = AppTheme.textPrimary,
    );
  }

  void _hand(Canvas canvas, Offset c, double angle, {required double length, required double width, required Color color}) {
    final end = Offset(
      c.dx + length * math.cos(angle),
      c.dy + length * math.sin(angle),
    );
    canvas.drawLine(
      c,
      end,
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _AnalogClockPainter oldDelegate) {
    return oldDelegate.time.millisecond != time.millisecond ||
        oldDelegate.time.second != time.second ||
        oldDelegate.time.minute != time.minute ||
        oldDelegate.time.hour != time.hour;
  }
}
