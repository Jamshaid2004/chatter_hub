import 'dart:math' as math show sin, pi;

import 'package:flutter/animation.dart';

/// A custom [Tween] that introduces a delay in the animation by applying
/// a sine function to the animation value.
///
/// The [DelayTween] class extends the [Tween] class and overrides the
/// [lerp] and [evaluate] methods to introduce a delay in the animation.
///
/// The [delay] parameter specifies the amount of delay to be applied to
/// the animation value.
///
///
/// This will create a tween that starts the animation with a delay of 0.5.
class DelayTween extends Tween<double> {
  DelayTween({
    super.begin,
    super.end,
    required this.delay,
  });

  final double delay;

  @override
  double lerp(double t) {
    return super.lerp((math.sin((t - delay) * 2 * math.pi) + 1) / 2);
  }

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}
