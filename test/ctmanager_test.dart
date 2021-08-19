import 'package:ctmanager/ctmanager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ctManager = CTManager();
  group('Test CTManager:\n', () {
    test(
        'Given an async operation that will return [null],\n'
        'when completes normaly,\n'
        'then returns [null] with [isCompleted] is `true`\n'
        'and its cancellation token has been removed.\n', () {
      final Future<String?> operation =
          Future.value(1 == 2 ? 'something' : null);
      final ctResult = ctManager.create(
        token: 'S',
        operation: operation,
      );

      expectLater(
        ctResult.result.then(
          (result) {
            expect(ctResult.isCompleted, isTrue);
            expect(result, isNull);
          },
        ).then(
          (_) => ctManager.noTokenOf('S'),
        ),
        completion(isTrue),
      );
    });
    test(
        'Given an async operation that takes 5 seconds,\n'
        'when cancelled within 4 seconds of execution,\n'
        'then returns null\n'
        'and its cancellation token has been removed.\n', () {
      expectLater(
        ctManager
            .run(
              token: 'cancelled5sec',
              operation: Future.delayed(
                const Duration(seconds: 5),
                () => 'done',
              ),
            )
            .then(
              (result) => expect(result, isNull),
            )
            .then(
              (_) => ctManager.hasTokenOf('cancelled5sec'),
            ),
        completion(isFalse),
      );
      Future.delayed(
        const Duration(seconds: 4),
        () => ctManager.cancel('cancelled5sec'),
      );
    });
    test(
        'Given an async operation that takes 5 seconds,\n'
        'when cancelled within 4 seconds of execution,\n'
        'then returns null\n'
        'then [onCancel] is called\n'
        'and its cancellation token has been removed.\n', () {
      bool onCancelIsCalled = false;
      expectLater(
        ctManager
            .create(
              token: '5secWithOnCancel',
              operation: Future.delayed(
                const Duration(seconds: 5),
                () => 'done',
              ),
              onCancel: () {
                // ignore: avoid_print
                print('cancelled');
                onCancelIsCalled = true;
              },
            )
            .result
            .then(
          (result) {
            expect(result, isNull);
            expect(onCancelIsCalled, isTrue);
          },
        ).then(
          (_) => ctManager.hasTokenOf('5secWithOnCancel'),
        ),
        completion(isFalse),
      );
      Future.delayed(
        const Duration(seconds: 4),
        ctManager.of<String, String>('5secWithOnCancel')?.cancel,
      );
    });
  });
}
