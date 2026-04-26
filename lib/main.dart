import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const SpliceApp());

class SpliceApp extends StatelessWidget {
  const SpliceApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Splice',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true),
        home: const GamePage(),
      );
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final _sfx = AudioPlayer();
  final _rng = Random();
  double _angle = 0;
  double _speed = 2.4;
  int _segments = 6;
  int _target = 0;
  int _score = 0;
  int _best = 0;
  bool _dead = false;
  Duration _last = Duration.zero;

  static const _colors = [
    Color(0xFFE63946), Color(0xFFF7B538),
    Color(0xFF06D6A0), Color(0xFF118AB2),
    Color(0xFF9D4EDD), Color(0xFFFF6B6B),
    Color(0xFF26C485), Color(0xFFFFD60A),
  ];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
    _newRound();
  }

  void _newRound() {
    _target = _rng.nextInt(_segments);
  }

  void _tick(Duration t) {
    final dt = (t - _last).inMicroseconds / 1e6;
    _last = t;
    if (dt > 0.1 || _dead) return;
    setState(() {
      _angle += _speed * dt;
      while (_angle > 2 * pi) _angle -= 2 * pi;
    });
  }

  void _tap() {
    if (_dead) {
      setState(() {
        _dead = false; _score = 0; _speed = 2.4; _segments = 6;
        _newRound();
      });
      return;
    }
    // determine which segment is at notch (top, angle = -pi/2)
    final segAngle = 2 * pi / _segments;
    // notch at -pi/2; segment i covers [-pi/2 + i*segAngle - segAngle/2, +segAngle/2]
    // segments rotate counter to disk: equivalent reverse mapping
    final adj = (-pi/2 - _angle) % (2 * pi);
    final norm = (adj + 2*pi) % (2*pi);
    final idx = (norm / segAngle).floor() % _segments;
    if (idx == _target) {
      _sfx.play(AssetSource('sfx.wav'));
      setState(() {
        _score++;
        if (_score > _best) _best = _score;
        _speed += 0.18;
        if (_score % 5 == 0 && _segments < 8) _segments++;
        if (_score % 4 == 0) _speed = -_speed; // reverse
        _newRound();
      });
    } else {
      setState(() => _dead = true);
    }
  }

  @override
  void dispose() { _ticker.dispose(); _sfx.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      body: GestureDetector(
        onTap: _tap,
        behavior: HitTestBehavior.opaque,
        child: Stack(children: [
          Center(
            child: SizedBox.expand(
              child: CustomPaint(
                painter: _Painter(
                  angle: _angle, segments: _segments,
                  target: _target, colors: _colors,
                ),
              ),
            ),
          ),
          Positioned(
            top: 50, left: 0, right: 0,
            child: Column(children: [
              Text('$_score',
                  style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold)),
              Text('best $_best',
                  style: const TextStyle(color: Colors.white60)),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('tap when ', style: TextStyle(color: Colors.white60)),
                Container(width: 24, height: 24,
                    decoration: BoxDecoration(
                        color: _colors[_target],
                        borderRadius: BorderRadius.circular(4))),
                const Text(' is at notch', style: TextStyle(color: Colors.white60)),
              ]),
            ]),
          ),
          if (_dead)
            const Center(
              child: Text('MISS · TAP TO RETRY',
                  style: TextStyle(color: Color(0xFFFF6B6B), fontSize: 22)),
            ),
        ]),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final double angle;
  final int segments, target;
  final List<Color> colors;
  _Painter({required this.angle, required this.segments,
            required this.target, required this.colors});
  @override
  void paint(Canvas c, Size s) {
    final cx = s.width / 2, cy = s.height / 2 + 20;
    final r = min(s.width, s.height) * 0.36;
    final segAngle = 2 * pi / segments;
    for (int i = 0; i < segments; i++) {
      final start = -pi/2 + angle + i * segAngle - segAngle/2;
      final p = Paint()..color = colors[i % colors.length];
      c.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r),
          start, segAngle, true, p);
    }
    // ring outline
    c.drawCircle(Offset(cx, cy), r,
        Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 4);
    // center hole
    c.drawCircle(Offset(cx, cy), r * 0.25,
        Paint()..color = const Color(0xFF191919));
    // notch indicator at top
    final notchY = cy - r - 10;
    final notch = Path()
      ..moveTo(cx - 16, notchY - 26)
      ..lineTo(cx + 16, notchY - 26)
      ..lineTo(cx, notchY)
      ..close();
    c.drawPath(notch, Paint()..color = const Color(0xFFFFD60A));
  }

  @override
  bool shouldRepaint(covariant _Painter old) => true;
}
