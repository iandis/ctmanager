
abstract class BaseCancellationToken<T extends Object, R extends Object?> {
  /// the token of [T]
  T get token;

  /// returns one of the following:
  /// * [R] -> value resulting from the operation
  /// * `null` -> the operation was cancelled
  Future<R> get result;

  /// cancels the operation
  void Function() get cancel;
}