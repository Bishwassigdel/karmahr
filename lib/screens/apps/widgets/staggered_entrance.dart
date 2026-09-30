// Fades + slides a list item in, each one a beat after the one above
// it, so a list "cascades" onto the screen instead of popping in all at
// once. Wrap each item: StaggeredEntrance(index: i, child: card).
//
// Two deliberate choices:
//  - No Future.delayed/Timer for the stagger. Each item's controller
//    simply runs a little longer, with its visible motion confined to
//    the tail end via an Interval curve. Same look, but nothing is left
//    pending if the screen closes mid-animation (and tests stay clean).
//  - Respects the OS "Reduce Motion" / disable-animations setting —
//    items just appear, for people who get motion-sick from UI motion.

import 'package:flutter/cupertino.dart';

class StaggeredEntrance extends StatefulWidget {
  final int index;
  final Widget child;

  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
  });

  // Past this many items the delay stops growing — item 30 shouldn't
  // make someone wait a second and a half to see it. Anything below the
  // fold was going to be scrolled to anyway.
  static const maxStaggeredItems = 8;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  static const _itemDuration = Duration(milliseconds: 320);
  static const _stepDelay = Duration(milliseconds: 55);

  late final AnimationController _controller;
  late final Animation<double> _progress;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    final step = widget.index.clamp(0, StaggeredEntrance.maxStaggeredItems);
    final delayMs = _stepDelay.inMilliseconds * step;
    final totalMs = delayMs + _itemDuration.inMilliseconds;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(delayMs / totalMs, 1, curve: Curves.easeOutCubic),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(_progress);
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FadeTransition/SlideTransition rather than Opacity + Transform in
    // a builder: they repaint without rebuilding the child every frame.
    return FadeTransition(
      opacity: _progress,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
