import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ctmanager_example/main.dart';

void main() {
  testWidgets('Test CTManager when used in app\n', (tester) async {
    await tester.pumpWidget(MyApp());
    void expectTextToBe(String expectedText) {
      return expect(
        find.text(expectedText),
        findsOneWidget,
      );
    }

    void expectNormalOpButtonToBe({required bool enabled}) {
      return expect(
        find.byWidgetPredicate((widget) {
          return widget is TextButton && 
                widget.child is Text &&
                (widget.child! as Text).data == 'Run Normal Operation' && 
                widget.enabled == enabled;
        }),
        findsOneWidget,
      );
    }

    void expectToBeCancelledOpButtonToBe({required bool enabled}) {
      return expect(
        find.byWidgetPredicate((widget) {
          return widget is TextButton && 
                widget.child is Text &&
                (widget.child! as Text).data == 'Run To-Be-Cancelled Operation' && 
                widget.enabled == enabled;
        }),
        findsOneWidget,
      );
    }

    void expectCancelOpButtonToBe({required bool enabled}) {
      return expect(
        find.byWidgetPredicate((widget) {
          return widget is TextButton && 
                widget.child is Text &&
                (widget.child! as Text).data == 'Cancel To-Be-Cancelled Operation' && 
                widget.enabled == enabled;
        }),
        findsOneWidget,
      );
    }

    // ignore: avoid_print
    print(
      'Given app first started,\n'
      'when app has shown,\n'
      'then text should be `waiting`.\n'
      'and normal operation button should be ENABLED,\n'
      'and tobecancelled operation button should be ENABLED,\n'
      'and cancel operation button should be DISABLED.',
    );
    expectTextToBe('waiting');
    expectNormalOpButtonToBe(enabled: true);
    expectToBeCancelledOpButtonToBe(enabled: true);
    expectCancelOpButtonToBe(enabled: false);
    // ignore: avoid_print
    print('[passed]\n');

    // ignore: avoid_print
    print(
      'Given normal operation button is ENABLED,\n'
      'when tapped,\n'
      'then text should be `normal operation executed`,\n'
      'and normal operation button should be DISABLED,\n'
      'and tobecancelled operation button should be DISABLED,\n'
      'and cancel operation button should be DISABLED,\n'
      'then after 3 seconds text should be `normal operation finished`,\n'
      'and normal operation button should be ENABLED,\n'
      'and tobecancelled operation button should be ENABLED,\n'
      'and cancel operation button should be DISABLED.',
    );
    await tester.tap(
      find.byWidgetPredicate((widget) {
        return widget is TextButton && 
                widget.child is Text &&
                (widget.child! as Text).data == 'Run Normal Operation';
      }),
    );
    await tester.pump();
    expectTextToBe('normal operation executed');
    expectNormalOpButtonToBe(enabled: false);
    expectToBeCancelledOpButtonToBe(enabled: false);
    expectCancelOpButtonToBe(enabled: false);
    // rebuild the widget after 3 seconds of normal operation
    await tester.pump(const Duration(seconds: 3));
    expectTextToBe('normal operation finished');
    expectNormalOpButtonToBe(enabled: true);
    expectToBeCancelledOpButtonToBe(enabled: true);
    expectCancelOpButtonToBe(enabled: false);
    // ignore: avoid_print
    print('[passed]\n');
    
    // ignore: avoid_print
    print(
      'Given tobecancelled operation button is ENABLED,\n'
      'when tapped,\n'
      'then text should be `toBeCancelled operation executed`,\n'
      'and normal operation button should be DISABLED,\n'
      'and tobecancelled operation button should be DISABLED,\n'
      'and cancel operation button should be ENABLED,\n'
      'then after 3 seconds, the operation is cancelled,\n'
      'and text should be `toBeCancelled operation cancelled`,\n'
      'and normal operation button should be ENABLED,\n'
      'and tobecancelled operation button should be ENABLED,\n'
      'and cancel operation button should be DISABLED.',
    );
    // we need [runAsync] here since the app calls a real asynchronous method that uses
    // Future.delayed when tapping the `Run To-Be-Cancelled Operation` button.
    await tester.runAsync(() async {

      await tester.tap(
        find.byWidgetPredicate((widget) {
          return widget is TextButton && 
                  widget.child is Text &&
                  (widget.child! as Text).data == 'Run To-Be-Cancelled Operation';
        }),
      );

      await tester.pump();
      expectTextToBe('toBeCancelled operation executed');
      expectNormalOpButtonToBe(enabled: false);
      expectToBeCancelledOpButtonToBe(enabled: false);
      expectCancelOpButtonToBe(enabled: true);

      // cancel the operation within 3 seconds
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(
        find.byWidgetPredicate((widget) {
          return widget is TextButton && 
                  widget.child is Text &&
                  (widget.child! as Text).data == 'Cancel To-Be-Cancelled Operation';
        }),
      );
      await tester.pump();
      expectTextToBe('toBeCancelled operation cancelled');
      expectNormalOpButtonToBe(enabled: true);
      expectToBeCancelledOpButtonToBe(enabled: true);
      expectCancelOpButtonToBe(enabled: false);
      // ignore: avoid_print
      print('[passed]\n');

    });

    // ignore: avoid_print
    print(
      'Given tobecancelled operation button is ENABLED,\n'
      'when tapped,\n'
      'then text should be `toBeCancelled operation executed`,\n'
      'and normal operation button should be DISABLED,\n'
      'and tobecancelled operation button should be DISABLED,\n'
      'and cancel operation button should be ENABLED,\n'
      'then after 5 seconds, the operation is completed,\n'
      'and text should be `toBeCancelled operation finished`,\n'
      'and normal operation button should be ENABLED,\n'
      'and tobecancelled operation button should be ENABLED,\n'
      'and cancel operation button should be DISABLED.',
    );

    await tester.tap(
      find.byWidgetPredicate((widget) {
        return widget is TextButton && 
                widget.child is Text &&
                (widget.child! as Text).data == 'Run To-Be-Cancelled Operation';
      }),
    );

    await tester.pump();
    expectTextToBe('toBeCancelled operation executed');
    expectNormalOpButtonToBe(enabled: false);
    expectToBeCancelledOpButtonToBe(enabled: false);
    expectCancelOpButtonToBe(enabled: true);

    // wait for the operation to finished within 5 seconds
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expectTextToBe('toBeCancelled operation finished');
    expectNormalOpButtonToBe(enabled: true);
    expectToBeCancelledOpButtonToBe(enabled: true);
    expectCancelOpButtonToBe(enabled: false);
    // ignore: avoid_print
    print('[passed]\n');

  });
}
