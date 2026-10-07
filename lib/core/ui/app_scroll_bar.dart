import 'package:flutter/material.dart';

/// 가로 스크롤 영역 아래에 두는 잡기 쉬운 스크롤 막대. 막대를 끌거나 트랙을 눌러 이동한다.
/// 내용이 넘치지 않으면 아무것도 그리지 않는다.
class AppScrollBar extends StatefulWidget {
  const AppScrollBar({super.key, required this.controller});

  final ScrollController controller;

  @override
  State<AppScrollBar> createState() => _AppScrollBarState();
}

class _AppScrollBarState extends State<AppScrollBar> {
  static const _hit = 28.0;
  static const _track = 8.0;
  static const _minThumb = 48.0;

  double _viewport = 0;
  double _max = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(AppScrollBar old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (mounted) setState(() {});
  }

  /// 내용 크기가 바뀌었는지 프레임이 끝난 뒤 확인한다.
  void _syncMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.controller.hasClients) return;
      final p = widget.controller.position;
      if (!p.hasViewportDimension || !p.hasContentDimensions) return;
      if (p.viewportDimension != _viewport || p.maxScrollExtent != _max) {
        setState(() {
          _viewport = p.viewportDimension;
          _max = p.maxScrollExtent;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _syncMetrics();
    if (_max <= 0 || !widget.controller.hasClients) {
      return const SizedBox.shrink();
    }
    final colors = Theme.of(context).colorScheme;
    final offset = widget.controller.offset.clamp(0.0, _max);

    return LayoutBuilder(
      builder: (context, box) {
        final width = box.maxWidth;
        final content = _viewport + _max;
        final thumb = (width * _viewport / content).clamp(_minThumb, width);
        final travel = width - thumb;
        final left = _max == 0 ? 0.0 : travel * offset / _max;

        void jumpTo(double dx) {
          if (travel <= 0) return;
          final ratio = ((dx - thumb / 2) / travel).clamp(0.0, 1.0);
          widget.controller.jumpTo(ratio * _max);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => jumpTo(d.localPosition.dx),
          onHorizontalDragStart: (d) => jumpTo(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => jumpTo(d.localPosition.dx),
          child: SizedBox(
            height: _hit,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: _track,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(_track),
                  ),
                ),
                Positioned(
                  left: left,
                  child: Container(
                    width: thumb,
                    height: _track + 4,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(_track),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
