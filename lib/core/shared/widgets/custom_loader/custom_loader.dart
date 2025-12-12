import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/shared/widgets/custom_loader/delay_tween.dart';

/// A widget that displays a spinning circle with fading items.
///
/// The [SpinKitFadingCircle] widget is a customizable loading indicator
/// that shows a circle of items that fade in and out while rotating.
///
/// The [color] parameter specifies the color of the items. If [itemBuilder]
/// is provided, [color] must be null.
///
/// The [size] parameter specifies the overall size of the spinner. The default
/// value is 50.0.
///
/// The [itemSize] parameter specifies the size of each individual item. If
/// not provided, it defaults to 15% of the [size].
///
/// The [itemCount] parameter specifies the number of items in the spinner.
/// If not provided, it defaults to 12.
///
/// The [itemBuilder] parameter allows for custom item widgets. If provided,
/// [color] must be null.
///
/// The [duration] parameter specifies the duration of the animation cycle.
/// The default value is 1200 milliseconds.
///
/// The [controller] parameter allows for a custom [AnimationController] to
/// be provided. If not provided, a default controller is created.
///
/// The [SpinKitFadingCircle] widget asserts that either [itemBuilder] or
/// [color] must be provided, but not both.
///
/// Example usage:
/// ```dart
/// SpinKitFadingCircle(
///   color: Colors.blue,
///   size: 50.0,
/// )
/// ```
class SpinKitFadingCircle extends StatefulWidget {
  const SpinKitFadingCircle({
    super.key,
    this.color,
    this.size = 50.0,
    this.itemSize,
    this.itemCount,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
  }) : assert(
          !(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
          'You should specify either a itemBuilder or a color',
        );

  final Color? color;
  final double size;
  final double? itemSize;
  final int? itemCount;
  final IndexedWidgetBuilder? itemBuilder;
  final Duration duration;
  final AnimationController? controller;

  @override
  State<SpinKitFadingCircle> createState() => _SpinKitFadingCircleState();
}

class _SpinKitFadingCircleState extends State<SpinKitFadingCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = (widget.controller ?? AnimationController(vsync: this, duration: widget.duration))..repeat();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemSize = widget.itemSize ?? widget.size * 0.15;
    final itemCount = widget.itemCount ?? 12;

    return Center(
      child: SizedBox.fromSize(
        size: Size.square(widget.size),
        child: Stack(
          children: List.generate(itemCount, (i) {
            final position = widget.size * .5;
            return Positioned.fill(
              left: position,
              top: position,
              child: Transform(
                transform: Matrix4.rotationZ((360 / itemCount) * i * 0.0174533),
                child: Align(
                  alignment: Alignment.center,
                  child: FadeTransition(
                    opacity: DelayTween(begin: 0.0, end: 1.0, delay: i / itemCount).animate(_controller),
                    child: SizedBox.fromSize(size: Size.square(itemSize), child: _itemBuilder(i)),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _itemBuilder(int index) => widget.itemBuilder != null
      ? widget.itemBuilder!(context, index)
      : DecoratedBox(decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle));
}
