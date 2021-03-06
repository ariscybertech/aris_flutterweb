// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_ui/ui.dart';

import '../util.dart';

/// Base class for [Alignment] that allows for text-direction aware
/// resolution.
///
/// A property or argument of this type accepts classes created either with [new
/// Alignment] and its variants, or [new AlignmentDirectional].
///
/// To convert a [AlignmentGeometry] object of indeterminate type into a
/// [Alignment] object, call the [resolve] method.
abstract class AlignmentGeometry {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const AlignmentGeometry();

  double get _x;

  double get _start;

  double get _y;

  /// Returns the sum of two [AlignmentGeometry] objects.
  ///
  /// If you know you are adding two [Alignment] or two [AlignmentDirectional]
  /// objects, consider using the `+` operator instead, which always returns an
  /// object of the same type as the operands, and is typed accordingly.
  ///
  /// If [add] is applied to two objects of the same type ([Alignment] or
  /// [AlignmentDirectional]), an object of that type will be returned (though
  /// this is not reflected in the type system). Otherwise, an object
  /// representing a combination of both is returned. That object can be turned
  /// into a concrete [Alignment] using [resolve].
  AlignmentGeometry add(AlignmentGeometry other) {
    return new _MixedAlignment(
      _x + other._x,
      _start + other._start,
      _y + other._y,
    );
  }

  /// Returns the negation of the given [AlignmentGeometry] object.
  ///
  /// This is the same as multiplying the object by -1.0.
  ///
  /// This operator returns an object of the same type as the operand.
  AlignmentGeometry operator -();

  /// Scales the [AlignmentGeometry] object in each dimension by the given
  /// factor.
  ///
  /// This operator returns an object of the same type as the operand.
  AlignmentGeometry operator *(double other);

  /// Divides the [AlignmentGeometry] object in each dimension by the given
  /// factor.
  ///
  /// This operator returns an object of the same type as the operand.
  AlignmentGeometry operator /(double other);

  /// Integer divides the [AlignmentGeometry] object in each dimension by the
  /// given factor.
  ///
  /// This operator returns an object of the same type as the operand.
  AlignmentGeometry operator ~/(double other);

  /// Computes the remainder in each dimension by the given factor.
  ///
  /// This operator returns an object of the same type as the operand.
  AlignmentGeometry operator %(double other);

  /// Linearly interpolate between two [AlignmentGeometry] objects.
  ///
  /// If either is null, this function interpolates from [Alignment.center], and
  /// the result is an object of the same type as the non-null argument.
  ///
  /// If [lerp] is applied to two objects of the same type ([Alignment] or
  /// [AlignmentDirectional]), an object of that type will be returned (though
  /// this is not reflected in the type system). Otherwise, an object
  /// representing a combination of both is returned. That object can be turned
  /// into a concrete [Alignment] using [resolve].
  ///
  /// The `t` argument represents position on the timeline, with 0.0 meaning
  /// that the interpolation has not started, returning `a` (or something
  /// equivalent to `a`), 1.0 meaning that the interpolation has finished,
  /// returning `b` (or something equivalent to `b`), and values in between
  /// meaning that the interpolation is at the relevant point on the timeline
  /// between `a` and `b`. The interpolation can be extrapolated beyond 0.0 and
  /// 1.0, so negative values and values greater than 1.0 are valid (and can
  /// easily be generated by curves such as [Curves.elasticInOut]).
  ///
  /// Values for `t` are usually obtained from an [Animation<double>], such as
  /// an [AnimationController].
  static AlignmentGeometry lerp(
      AlignmentGeometry a, AlignmentGeometry b, double t) {
    assert(t != null);
    if (a == null && b == null) return null;
    if (a == null) return b * t;
    if (b == null) return a * (1.0 - t);
    if (a is Alignment && b is Alignment) return Alignment.lerp(a, b, t);
    if (a is AlignmentDirectional && b is AlignmentDirectional)
      return AlignmentDirectional.lerp(a, b, t);
    return new _MixedAlignment(
      lerpDouble(a._x, b._x, t),
      lerpDouble(a._start, b._start, t),
      lerpDouble(a._y, b._y, t),
    );
  }

  /// Convert this instance into a [Alignment], which uses literal
  /// coordinates (the `x` coordinate being explicitly a distance from the
  /// left).
  ///
  /// See also:
  ///
  ///  * [Alignment], for which this is a no-op (returns itself).
  ///  * [AlignmentDirectional], which flips the horizontal direction
  ///    based on the `direction` argument.
  Alignment resolve(TextDirection direction);

  @override
  String toString() {
    if (assertionsEnabled) {
      if (_start == 0.0) return Alignment._stringify(_x, _y);
      if (_x == 0.0) return AlignmentDirectional._stringify(_start, _y);
      return Alignment._stringify(_x, _y) +
          ' + ' +
          AlignmentDirectional._stringify(_start, 0.0);
    } else {
      return super.toString();
    }
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! AlignmentGeometry) return false;
    final AlignmentGeometry typedOther = other;
    return _x == typedOther._x &&
        _start == typedOther._start &&
        _y == typedOther._y;
  }

  @override
  int get hashCode => hashValues(_x, _start, _y);

  double get x => _x;

  double get y => _y;
}

/// A point within a rectangle.
///
/// `Alignment(0.0, 0.0)` represents the center of the rectangle. The distance
/// from -1.0 to +1.0 is the distance from one side of the rectangle to the
/// other side of the rectangle. Therefore, 2.0 units horizontally (or
/// vertically) is equivalent to the width (or height) of the rectangle.
///
/// `Alignment(-1.0, -1.0)` represents the top left of the rectangle.
///
/// `Alignment(1.0, 1.0)` represents the bottom right of the rectangle.
///
/// `Alignment(0.0, 3.0)` represents a point that is horizontally centered with
/// respect to the rectangle and vertically below the bottom of the rectangle by
/// the height of the rectangle.
///
/// [Alignment] use visual coordinates, which means increasing [x] moves the
/// point from left to right. To support layouts with a right-to-left
/// [TextDirection], consider using [AlignmentDirectional], in which the
/// direction the point moves when increasing the horizontal value depends on
/// the [TextDirection].
///
/// A variety of widgets use [Alignment] in their configuration, most
/// notably:
///
///  * [Align] positions a child according to a [Alignment].
///
/// See also:
///
///  * [AlignmentDirectional], which has a horizontal coordinate orientation
///    that depends on the [TextDirection].
///  * [AlignmentGeometry], which is an abstract type that is agnostic as to
///    whether the horizontal direction depends on the [TextDirection].
class Alignment extends AlignmentGeometry {
  /// Creates an alignment.
  ///
  /// The [x] and [y] arguments must not be null.
  const Alignment(this.x, this.y)
      : assert(x != null),
        assert(y != null);

  /// The distance fraction in the horizontal direction.
  ///
  /// A value of -1.0 corresponds to the leftmost edge. A value of 1.0
  /// corresponds to the rightmost edge. Values are not limited to that range;
  /// values less than -1.0 represent positions to the left of the left edge,
  /// and values greater than 1.0 represent positions to the right of the right
  /// edge.
  final double x;

  /// The distance fraction in the vertical direction.
  ///
  /// A value of -1.0 corresponds to the topmost edge. A value of 1.0
  /// corresponds to the bottommost edge. Values are not limited to that range;
  /// values less than -1.0 represent positions above the top, and values
  /// greater than 1.0 represent positions below the bottom.
  final double y;

  @override
  double get _x => x;

  @override
  double get _start => 0.0;

  @override
  double get _y => y;

  /// The top left corner.
  static const Alignment topLeft = const Alignment(-1.0, -1.0);

  /// The center point along the top edge.
  static const Alignment topCenter = const Alignment(0.0, -1.0);

  /// The top right corner.
  static const Alignment topRight = const Alignment(1.0, -1.0);

  /// The center point along the left edge.
  static const Alignment centerLeft = const Alignment(-1.0, 0.0);

  /// The center point, both horizontally and vertically.
  static const Alignment center = const Alignment(0.0, 0.0);

  /// The center point along the right edge.
  static const Alignment centerRight = const Alignment(1.0, 0.0);

  /// The bottom left corner.
  static const Alignment bottomLeft = const Alignment(-1.0, 1.0);

  /// The center point along the bottom edge.
  static const Alignment bottomCenter = const Alignment(0.0, 1.0);

  /// The bottom right corner.
  static const Alignment bottomRight = const Alignment(1.0, 1.0);

  @override
  AlignmentGeometry add(AlignmentGeometry other) {
    if (other is Alignment) return this + other;
    return super.add(other);
  }

  /// Returns the difference between two [Alignment]s.
  Alignment operator -(Alignment other) {
    return new Alignment(x - other.x, y - other.y);
  }

  /// Returns the sum of two [Alignment]s.
  Alignment operator +(Alignment other) {
    return new Alignment(x + other.x, y + other.y);
  }

  /// Returns the negation of the given [Alignment].
  @override
  Alignment operator -() {
    return new Alignment(-x, -y);
  }

  /// Scales the [Alignment] in each dimension by the given factor.
  @override
  Alignment operator *(double other) {
    return new Alignment(x * other, y * other);
  }

  /// Divides the [Alignment] in each dimension by the given factor.
  @override
  Alignment operator /(double other) {
    return new Alignment(x / other, y / other);
  }

  /// Integer divides the [Alignment] in each dimension by the given factor.
  @override
  Alignment operator ~/(double other) {
    return new Alignment((x ~/ other).toDouble(), (y ~/ other).toDouble());
  }

  /// Computes the remainder in each dimension by the given factor.
  @override
  Alignment operator %(double other) {
    return new Alignment(x % other, y % other);
  }

  /// Returns the offset that is this fraction in the direction of the given
  /// offset.
  Offset alongOffset(Offset other) {
    final double centerX = other.dx / 2.0;
    final double centerY = other.dy / 2.0;
    return new Offset(centerX + x * centerX, centerY + y * centerY);
  }

  /// Returns the offset that is this fraction within the given size.
  Offset alongSize(Size other) {
    final double centerX = other.width / 2.0;
    final double centerY = other.height / 2.0;
    return new Offset(centerX + x * centerX, centerY + y * centerY);
  }

  /// Returns the point that is this fraction within the given rect.
  Offset withinRect(Rect rect) {
    final double halfWidth = rect.width / 2.0;
    final double halfHeight = rect.height / 2.0;
    return new Offset(
      rect.left + halfWidth + x * halfWidth,
      rect.top + halfHeight + y * halfHeight,
    );
  }

  /// Returns a rect of the given size, aligned within given rect as specified
  /// by this alignment.
  ///
  /// For example, a 100??100 size inscribed on a 200??200 rect using
  /// [Alignment.topLeft] would be the 100??100 rect at the top left of
  /// the 200??200 rect.
  Rect inscribe(Size size, Rect rect) {
    final double halfWidthDelta = (rect.width - size.width) / 2.0;
    final double halfHeightDelta = (rect.height - size.height) / 2.0;
    return new Rect.fromLTWH(
      rect.left + halfWidthDelta + x * halfWidthDelta,
      rect.top + halfHeightDelta + y * halfHeightDelta,
      size.width,
      size.height,
    );
  }

  /// Linearly interpolate between two [Alignment]s.
  ///
  /// If either is null, this function interpolates from [Alignment.center].
  ///
  /// The `t` argument represents position on the timeline, with 0.0 meaning
  /// that the interpolation has not started, returning `a` (or something
  /// equivalent to `a`), 1.0 meaning that the interpolation has finished,
  /// returning `b` (or something equivalent to `b`), and values in between
  /// meaning that the interpolation is at the relevant point on the timeline
  /// between `a` and `b`. The interpolation can be extrapolated beyond 0.0 and
  /// 1.0, so negative values and values greater than 1.0 are valid (and can
  /// easily be generated by curves such as [Curves.elasticInOut]).
  ///
  /// Values for `t` are usually obtained from an [Animation<double>], such as
  /// an [AnimationController].
  static Alignment lerp(Alignment a, Alignment b, double t) {
    assert(t != null);
    if (a == null && b == null) return null;
    if (a == null)
      return new Alignment(lerpDouble(0.0, b.x, t), lerpDouble(0.0, b.y, t));
    if (b == null)
      return new Alignment(lerpDouble(a.x, 0.0, t), lerpDouble(a.y, 0.0, t));
    return new Alignment(lerpDouble(a.x, b.x, t), lerpDouble(a.y, b.y, t));
  }

  static String _stringify(double x, double y) {
    if (x == -1.0 && y == -1.0) return 'topLeft';
    if (x == 0.0 && y == -1.0) return 'topCenter';
    if (x == 1.0 && y == -1.0) return 'topRight';
    if (x == -1.0 && y == 0.0) return 'centerLeft';
    if (x == 0.0 && y == 0.0) return 'center';
    if (x == 1.0 && y == 0.0) return 'centerRight';
    if (x == -1.0 && y == 1.0) return 'bottomLeft';
    if (x == 0.0 && y == 1.0) return 'bottomCenter';
    if (x == 1.0 && y == 1.0) return 'bottomRight';
    return 'Alignment(${x.toStringAsFixed(1)}, '
        '${y.toStringAsFixed(1)})';
  }

  @override
  Alignment resolve(TextDirection direction) => this;

  @override
  String toString() {
    if (assertionsEnabled) {
      return _stringify(x, y);
    } else {
      return super.toString();
    }
  }
}

/// An offset that's expressed as a fraction of a [Size], but whose horizontal
/// component is dependent on the writing direction.
///
/// This can be used to indicate an offset from the left in [TextDirection.ltr]
/// text and an offset from the right in [TextDirection.rtl] text without having
/// to be aware of the current text direction.
///
/// See also:
///
///  * [Alignment], a variant that is defined in physical terms (i.e.
///    whose horizontal component does not depend on the text direction).
class AlignmentDirectional extends AlignmentGeometry {
  /// Creates a directional alignment.
  ///
  /// The [start] and [y] arguments must not be null.
  const AlignmentDirectional(this.start, this.y)
      : assert(start != null),
        assert(y != null);

  /// The distance fraction in the horizontal direction.
  ///
  /// A value of -1.0 corresponds to the edge on the "start" side, which is the
  /// left side in [TextDirection.ltr] contexts and the right side in
  /// [TextDirection.rtl] contexts. A value of 1.0 corresponds to the opposite
  /// edge, the "end" side. Values are not limited to that range; values less
  /// than -1.0 represent positions beyond the start edge, and values greater
  /// than 1.0 represent positions beyond the end edge.
  ///
  /// This value is normalized into a [Alignment.x] value by the [resolve]
  /// method.
  final double start;

  /// The distance fraction in the vertical direction.
  ///
  /// A value of -1.0 corresponds to the topmost edge. A value of 1.0
  /// corresponds to the bottommost edge. Values are not limited to that range;
  /// values less than -1.0 represent positions above the top, and values
  /// greater than 1.0 represent positions below the bottom.
  ///
  /// This value is passed through to [Alignment.y] unmodified by the
  /// [resolve] method.
  final double y;

  @override
  double get _x => 0.0;

  @override
  double get _start => start;

  @override
  double get _y => y;

  /// The top corner on the "start" side.
  static const AlignmentDirectional topStart =
      const AlignmentDirectional(-1.0, -1.0);

  /// The center point along the top edge.
  ///
  /// Consider using [Alignment.topCenter] instead, as it does not need
  /// to be [resolve]d to be used.
  static const AlignmentDirectional topCenter =
      const AlignmentDirectional(0.0, -1.0);

  /// The top corner on the "end" side.
  static const AlignmentDirectional topEnd =
      const AlignmentDirectional(1.0, -1.0);

  /// The center point along the "start" edge.
  static const AlignmentDirectional centerStart =
      const AlignmentDirectional(-1.0, 0.0);

  /// The center point, both horizontally and vertically.
  ///
  /// Consider using [Alignment.center] instead, as it does not need to
  /// be [resolve]d to be used.
  static const AlignmentDirectional center =
      const AlignmentDirectional(0.0, 0.0);

  /// The center point along the "end" edge.
  static const AlignmentDirectional centerEnd =
      const AlignmentDirectional(1.0, 0.0);

  /// The bottom corner on the "start" side.
  static const AlignmentDirectional bottomStart =
      const AlignmentDirectional(-1.0, 1.0);

  /// The center point along the bottom edge.
  ///
  /// Consider using [Alignment.bottomCenter] instead, as it does not
  /// need to be [resolve]d to be used.
  static const AlignmentDirectional bottomCenter =
      const AlignmentDirectional(0.0, 1.0);

  /// The bottom corner on the "end" side.
  static const AlignmentDirectional bottomEnd =
      const AlignmentDirectional(1.0, 1.0);

  @override
  AlignmentGeometry add(AlignmentGeometry other) {
    if (other is AlignmentDirectional) return this + other;
    return super.add(other);
  }

  /// Returns the difference between two [AlignmentDirectional]s.
  AlignmentDirectional operator -(AlignmentDirectional other) {
    return new AlignmentDirectional(start - other.start, y - other.y);
  }

  /// Returns the sum of two [AlignmentDirectional]s.
  AlignmentDirectional operator +(AlignmentDirectional other) {
    return new AlignmentDirectional(start + other.start, y + other.y);
  }

  /// Returns the negation of the given [AlignmentDirectional].
  @override
  AlignmentDirectional operator -() {
    return new AlignmentDirectional(-start, -y);
  }

  /// Scales the [AlignmentDirectional] in each dimension by the given factor.
  @override
  AlignmentDirectional operator *(double other) {
    return new AlignmentDirectional(start * other, y * other);
  }

  /// Divides the [AlignmentDirectional] in each dimension by the given factor.
  @override
  AlignmentDirectional operator /(double other) {
    return new AlignmentDirectional(start / other, y / other);
  }

  /// Integer divides the [AlignmentDirectional] in each dimension by the given
  /// factor.
  @override
  AlignmentDirectional operator ~/(double other) {
    return new AlignmentDirectional(
        (start ~/ other).toDouble(), (y ~/ other).toDouble());
  }

  /// Computes the remainder in each dimension by the given factor.
  @override
  AlignmentDirectional operator %(double other) {
    return new AlignmentDirectional(start % other, y % other);
  }

  /// Linearly interpolate between two [AlignmentDirectional]s.
  ///
  /// If either is null, this function interpolates from
  /// [AlignmentDirectional.center].
  ///
  /// The `t` argument represents position on the timeline, with 0.0 meaning
  /// that the interpolation has not started, returning `a` (or something
  /// equivalent to `a`), 1.0 meaning that the interpolation has finished,
  /// returning `b` (or something equivalent to `b`), and values in between
  /// meaning that the interpolation is at the relevant point on the timeline
  /// between `a` and `b`. The interpolation can be extrapolated beyond 0.0 and
  /// 1.0, so negative values and values greater than 1.0 are valid (and can
  /// easily be generated by curves such as [Curves.elasticInOut]).
  ///
  /// Values for `t` are usually obtained from an [Animation<double>], such as
  /// an [AnimationController].
  static AlignmentDirectional lerp(
      AlignmentDirectional a, AlignmentDirectional b, double t) {
    assert(t != null);
    if (a == null && b == null) return null;
    if (a == null)
      return new AlignmentDirectional(
          lerpDouble(0.0, b.start, t), lerpDouble(0.0, b.y, t));
    if (b == null)
      return new AlignmentDirectional(
          lerpDouble(a.start, 0.0, t), lerpDouble(a.y, 0.0, t));
    return new AlignmentDirectional(
        lerpDouble(a.start, b.start, t), lerpDouble(a.y, b.y, t));
  }

  @override
  Alignment resolve(TextDirection direction) {
    assert(direction != null);
    switch (direction) {
      case TextDirection.rtl:
        return new Alignment(-start, y);
      case TextDirection.ltr:
        return new Alignment(start, y);
    }
    return null;
  }

  static String _stringify(double start, double y) {
    if (start == -1.0 && y == -1.0) return 'AlignmentDirectional.topStart';
    if (start == 0.0 && y == -1.0) return 'AlignmentDirectional.topCenter';
    if (start == 1.0 && y == -1.0) return 'AlignmentDirectional.topEnd';
    if (start == -1.0 && y == 0.0) return 'AlignmentDirectional.centerStart';
    if (start == 0.0 && y == 0.0) return 'AlignmentDirectional.center';
    if (start == 1.0 && y == 0.0) return 'AlignmentDirectional.centerEnd';
    if (start == -1.0 && y == 1.0) return 'AlignmentDirectional.bottomStart';
    if (start == 0.0 && y == 1.0) return 'AlignmentDirectional.bottomCenter';
    if (start == 1.0 && y == 1.0) return 'AlignmentDirectional.bottomEnd';
    return 'AlignmentDirectional(${start.toStringAsFixed(1)}, '
        '${y.toStringAsFixed(1)})';
  }

  @override
  String toString() => _stringify(start, y);
}

class _MixedAlignment extends AlignmentGeometry {
  const _MixedAlignment(this._x, this._start, this._y);

  @override
  final double _x;

  @override
  final double _start;

  @override
  final double _y;

  @override
  _MixedAlignment operator -() {
    return new _MixedAlignment(
      -_x,
      -_start,
      -_y,
    );
  }

  @override
  _MixedAlignment operator *(double other) {
    return new _MixedAlignment(
      _x * other,
      _start * other,
      _y * other,
    );
  }

  @override
  _MixedAlignment operator /(double other) {
    return new _MixedAlignment(
      _x / other,
      _start / other,
      _y / other,
    );
  }

  @override
  _MixedAlignment operator ~/(double other) {
    return new _MixedAlignment(
      (_x ~/ other).toDouble(),
      (_start ~/ other).toDouble(),
      (_y ~/ other).toDouble(),
    );
  }

  @override
  _MixedAlignment operator %(double other) {
    return new _MixedAlignment(
      _x % other,
      _start % other,
      _y % other,
    );
  }

  @override
  Alignment resolve(TextDirection direction) {
    assert(direction != null);
    switch (direction) {
      case TextDirection.rtl:
        return new Alignment(_x - _start, _y);
      case TextDirection.ltr:
        return new Alignment(_x + _start, _y);
    }
    return null;
  }
}
