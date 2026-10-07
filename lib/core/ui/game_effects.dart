import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 게임 효과 (AD-15): 부서지는 조각, 좌우 흔들림, 숫자 팝. 의존성 없이 Flutter 애니메이션만 쓴다.

/// [trigger] 값이 바뀔 때마다 [child]를 좌우로 흔든다 (오답 · 목숨 잃음).
class ShakeEffect extends StatefulWidget {
  const ShakeEffect({
    super.key,
    required this.trigger,
    required this.child,
    this.amplitude = 10,
  });

  final int trigger;
  final Widget child;
  final double amplitude;

  @override
  State<ShakeEffect> createState() => _ShakeEffectState();
}

class _ShakeEffectState extends State<ShakeEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(ShakeEffect old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        // 줄어드는 사인파: 4번 왕복하며 잦아든다.
        final t = _controller.value;
        final dx = sin(t * pi * 8) * (1 - t) * widget.amplitude;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }
}

/// [trigger] 값이 바뀔 때마다 [child]가 커졌다 돌아온다 (점수 · 콤보).
class PopEffect extends StatefulWidget {
  const PopEffect({
    super.key,
    required this.trigger,
    required this.child,
    this.scale = 1.35,
  });

  final int trigger;
  final Widget child;
  final double scale;

  @override
  State<PopEffect> createState() => _PopEffectState();
}

class _PopEffectState extends State<PopEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );

  @override
  void didUpdateWidget(PopEffect old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeOut.transform(_controller.value);
        // 0 → 커짐 → 1로 복귀.
        final s = 1 + (widget.scale - 1) * sin(t * pi);
        return Transform.scale(scale: s, child: child);
      },
    );
  }
}

class _Shard {
  _Shard({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.spin,
    required this.color,
    required this.life,
  });

  double x;
  double y;
  double vx;
  double vy;
  final double size;
  double angle = 0;
  final double spin;
  final Color color;
  final double life;
  double age = 0;
}

/// 부서지는 조각을 그리는 층. 게임 영역 위에 겹쳐 두고 [BurstLayerState.burst]를 부른다.
/// 터치를 가로채지 않는다.
class BurstLayer extends StatefulWidget {
  const BurstLayer({super.key});

  @override
  State<BurstLayer> createState() => BurstLayerState();
}

class BurstLayerState extends State<BurstLayer>
    with SingleTickerProviderStateMixin {
  final _shards = <_Shard>[];
  final _random = Random();
  late final Ticker _ticker = createTicker(_tick);
  Duration _last = Duration.zero;

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  /// [center]에서 [color]색 조각을 흩뿌린다. [spread]가 크면 더 멀리 퍼진다.
  void burst(
    Offset center, {
    required Color color,
    int count = 18,
    double spread = 1,
  }) {
    for (var i = 0; i < count; i++) {
      final angle = _random.nextDouble() * pi * 2;
      final speed = (160 + _random.nextDouble() * 320) * spread;
      _shards.add(
        _Shard(
          x: center.dx,
          y: center.dy,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed - 120,
          size: 4 + _random.nextDouble() * 7,
          spin: (_random.nextDouble() - 0.5) * 14,
          color: Color.lerp(color, Colors.white, _random.nextDouble() * 0.35)!,
          life: 0.6 + _random.nextDouble() * 0.4,
        ),
      );
    }
    if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  /// [target] 위젯의 한가운데에서 조각을 흩뿌린다 (이 층과 좌표가 달라도 된다).
  void burstAt(
    GlobalKey target, {
    required Color color,
    int count = 18,
    double spread = 1,
  }) {
    final box = target.currentContext?.findRenderObject();
    final mine = context.findRenderObject();
    if (box is! RenderBox || mine is! RenderBox || !box.hasSize) return;
    final global = box.localToGlobal(box.size.center(Offset.zero));
    burst(
      mine.globalToLocal(global),
      color: color,
      count: count,
      spread: spread,
    );
  }

  void _tick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 0.016
        : ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = elapsed;
    for (final s in _shards) {
      s.age += dt;
      s.vy += 900 * dt;
      s.x += s.vx * dt;
      s.y += s.vy * dt;
      s.angle += s.spin * dt;
    }
    _shards.removeWhere((s) => s.age >= s.life);
    if (_shards.isEmpty) _ticker.stop();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _BurstPainter(List.of(_shards)),
        size: Size.infinite,
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.shards);

  final List<_Shard> shards;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final s in shards) {
      final fade = (1 - s.age / s.life).clamp(0.0, 1.0);
      paint.color = s.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(s.x, s.y);
      canvas.rotate(s.angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: s.size,
            height: s.size * 0.7,
          ),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => true;
}
