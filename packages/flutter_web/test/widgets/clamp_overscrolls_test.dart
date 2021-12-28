// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/widgets.dart';

// Assuming that the test container is 800x600. The height of the
// viewport's contents is 650.0, the top and bottom text children
// are 100 pixels high and top/left edge of both widgets are visible.
// The top of the bottom widget is at 550 (the top of the top widget
// is at 0). The top of the bottom widget is 500 when it has been
// scrolled completely into view.
Widget buildFrame(ScrollPhysics physics, {ScrollController scrollController}) {
  return SingleChildScrollView(
    key: UniqueKey(),
    physics: physics,
    controller: scrollController,
    child: SizedBox(
      height: 650.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.ltr,
        children: <Widget>[
          const SizedBox(
              height: 100.0,
              child: Text('top', textDirection: TextDirection.ltr)),
          Expanded(child: Container()),
          const SizedBox(
              height: 100.0,
              child: Text('bottom', textDirection: TextDirection.ltr)),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('ClampingScrollPhysics', (WidgetTester tester) async {
    // Scroll the target text widget by offset and then return its origin
    // in global coordinates.
    Future<Offset> locationAfterScroll(String target, Offset offset) async {
      await tester.dragFrom(tester.getTopLeft(find.text(target)), offset);
      await tester.pump();
      final RenderBox textBox = tester.renderObject(find.text(target));
      final Offset widgetOrigin = textBox.localToGlobal(Offset.zero);
      await tester
          .pump(const Duration(seconds: 1)); // Allow overscroll to settle
      return Future<Offset>.value(widgetOrigin);
    }

    await tester.pumpWidget(buildFrame(const BouncingScrollPhysics()));
    Offset origin = await locationAfterScroll('top', const Offset(0.0, 400.0));
    expect(origin.dy, greaterThan(0.0));
    origin = await locationAfterScroll('bottom', const Offset(0.0, -400.0));
    expect(origin.dy, lessThan(500.0));

    await tester.pumpWidget(buildFrame(const ClampingScrollPhysics()));
    origin = await locationAfterScroll('top', const Offset(0.0, 400.0));
    expect(origin.dy, equals(0.0));
    origin = await locationAfterScroll('bottom', const Offset(0.0, -400.0));
    expect(origin.dy, equals(500.0));
  });

  testWidgets('ClampingScrollPhysics affects ScrollPosition',
      (WidgetTester tester) async {
    // BouncingScrollPhysics

    await tester.pumpWidget(buildFrame(const BouncingScrollPhysics()));
    ScrollableState scrollable = tester.state(find.byType(Scrollable));

    await tester.dragFrom(
        tester.getTopLeft(find.text('top')), const Offset(0.0, 400.0));
    await tester.pump();
    expect(scrollable.position.pixels, lessThan(0.0));
    await tester.pump(const Duration(seconds: 1)); // Allow overscroll to settle

    await tester.dragFrom(
        tester.getTopLeft(find.text('bottom')), const Offset(0.0, -400.0));
    await tester.pump();
    expect(scrollable.position.pixels, greaterThan(0.0));
    await tester.pump(const Duration(seconds: 1)); // Allow overscroll to settle

    // ClampingScrollPhysics

    await tester.pumpWidget(buildFrame(const ClampingScrollPhysics()));
    scrollable = scrollable = tester.state(find.byType(Scrollable));

    await tester.dragFrom(
        tester.getTopLeft(find.text('top')), const Offset(0.0, 400.0));
    await tester.pump();
    expect(scrollable.position.pixels, equals(0.0));
    await tester.pump(const Duration(seconds: 1)); // Allow overscroll to settle

    await tester.dragFrom(
        tester.getTopLeft(find.text('bottom')), const Offset(0.0, -400.0));
    await tester.pump();
    expect(scrollable.position.pixels, equals(50.0));
  });

  testWidgets('ClampingScrollPhysics handles out of bounds ScrollPosition',
      (WidgetTester tester) async {
    Future<void> testOutOfBounds(ScrollPhysics physics, double initialOffset,
        double expectedOffset) async {
      final ScrollController scrollController =
          ScrollController(initialScrollOffset: initialOffset);
      await tester
          .pumpWidget(buildFrame(physics, scrollController: scrollController));
      final ScrollableState scrollable = tester.state(find.byType(Scrollable));

      expect(scrollable.position.pixels, equals(initialOffset));
      await tester
          .pump(const Duration(seconds: 1)); // Allow overscroll to settle
      expect(scrollable.position.pixels, equals(expectedOffset));
    }

    await testOutOfBounds(const ClampingScrollPhysics(), -400.0, 0.0);
    await testOutOfBounds(const ClampingScrollPhysics(), 800.0, 50.0);
  });
}
