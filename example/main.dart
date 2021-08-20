import 'package:ctmanager/ctmanager.dart';

void main() {
  example1();
  example2();
  example1_2();
  example3();
}

Future<void> example1() async {
  final ctManager = CTManager();
  final newCancelToken = ctManager.create(
    token: 'ct1',
    operation: Future.delayed(
      const Duration(seconds: 5),
      () => 'done',
    ),
    // optional
    onCancel: () => print('[example1]: cancelled'),
  );
  // the operation will be cancelled after 3 seconds.
  Future.delayed(
    const Duration(seconds: 3),
    newCancelToken.cancel,
  );

  final result = await newCancelToken.result;
  // since the operation will never return `null`,
  // we just need to check if it's `null` or not.
  // if it is then it was cancelled.
  if (result == null) {
    print('[example1]: operation was cancelled after 3 seconds');
  } else {
    print('[example1]: operation succeeded');
  }
}

Future<void> example2() async {
  final nullableValueCancelToken = CTManager.I.create(
    token: 'ct1',
    operation: Future.delayed(
      const Duration(seconds: 5),
      () => 1 < 2 ? null : 'done',
    ),
    // optional
    onCancel: () => print('[example2]: cancelled'),
  );
  // the operation will be cancelled after 3 seconds.
  Future.delayed(
    const Duration(seconds: 3),
    nullableValueCancelToken.cancel,
  );

  final result = await nullableValueCancelToken.result;
  if (nullableValueCancelToken.isCompleted) {
    if (result == null) {
      print('[example2]: operation suceeded with null value');
    } else {
      print('[example2]: operation succeeded with a value');
    }
  } else {
    print('[example2]: operation was cancelled after 3 seconds.');
  }
}

Future<void> example1_2() async {
  CTManager.I.run(
    token: 'ct2',
    operation: Future.delayed(
      const Duration(seconds: 5),
      () => print('[example1_2]: done'),
    ),
    onCancel: () => print('[example1_2]: cancelled'),
  );
  // cancel the operation after 3 seconds
  Future.delayed(
    const Duration(seconds: 3),
    () => CTManager.I.cancel('ct2'),
  );
}

Future<void> example3() async {
  final ct3 = CTManager.I.create(
    token: 'ct3',
    operation: Future.delayed(const Duration(seconds: 1), () => 'done ct3'),
  );
  final ct3result = await ct3.result;
  if (ct3result != null && ct3.isCompleted) {
    print('[example3]: result is `$ct3result`');
  } else {
    print('[example3]: operation cancelled');
  }
}
