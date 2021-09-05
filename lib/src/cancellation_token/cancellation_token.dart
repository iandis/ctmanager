import 'base_cancellation_token.dart';

class CancellationToken<T extends Object, R extends Object?>
    implements BaseCancellationToken<T, R> {
  const CancellationToken({
    required this.token,
    required this.cancel,
    required this.result,
    required bool Function() isCompletedFunc,
  }) : _isCompletedFunc = isCompletedFunc;

  @override
  final T token;

  @override
  final Future<R> result;

  @override
  final void Function() cancel;

  final bool Function() _isCompletedFunc;

  /// returns true when the operation completes.
  ///
  /// this is needed if a completed operation that returns [result] can also return `null`
  bool get isCompleted => _isCompletedFunc();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CancellationToken<T, R> &&
        other.token == token &&
        other.cancel == cancel &&
        other.result == result;
  }

  @override
  int get hashCode => token.hashCode ^ cancel.hashCode ^ result.hashCode;
}
