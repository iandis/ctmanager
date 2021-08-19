import 'dart:async' show FutureOr;
import 'dart:developer' as dev show log;

import 'package:async/async.dart' show CancelableOperation;
import 'package:flutter/foundation.dart' as foundation
    show kDebugMode, visibleForTesting;

import 'cancellation_token/cancellation_token.dart';

/// the base class for managing Cancellation Tokens
///
/// this can be used either as a singleton by calling [CTManager.I]
///
/// or
///
/// for creating a new [CTManager].
///
/// example:
///
/// * without singleton
///   ```dart
///   final ctManager = CTManager();
///   final result = await ctManager.run(
///     token: 'ct1',
///     operation: Future.value('done'),
///     onCancel: () => print('cancelled'),
///   );
///   ...
///   ```
/// * with singleton
///   ```dart
///   final result = await CTManager.I.create(
///     token: 'ct1',
///     operation: Future.value('done'),
///     onCancel: () => print('cancelled'),
///   ).result;
///   ...
///   ```
abstract class CTManager {
  /// returns a singleton [CTManager] which is capable of managing multiple [CancellationToken]
  static CTManager get I => _CTManagerImpl._instance;

  /// creates a new [CTManager] which is capable of managing multiple [CancellationToken]
  factory CTManager() = _CTManagerImpl;

  /// creates a unique [CancellationToken] which then can be used to
  /// either cancel it or get the value
  ///
  /// [token] will be used later to get the [CancellationToken]
  ///
  /// [operation] the operation that returns the result of [R]
  ///
  /// [onCancel] an optional additional mechanism when [CancellationToken.cancel] is called
  CancellationToken<T, R?> create<T extends Object, R extends Object?>({
    required T token,
    required Future<R> operation,
    FutureOr<void> Function()? onCancel,
  });

  /// a shortcut to [create] which creates a unique [CancellationToken] and
  /// immediately returns the [CancellationToken.result]
  ///
  /// this is suitable if you already know that [operation] will not return `null` when it completes
  ///
  /// [token] will be used later to get the [CancellationToken]
  ///
  /// [operation] the operation that returns the result of [R]
  ///
  /// [onCancel] an optional additional mechanism when [CancellationToken.cancel] is called
  Future<R?> run<T extends Object, R extends Object?>({
    required T token,
    required Future<R> operation,
    FutureOr<void> Function()? onCancel,
  });

  /// returns either:
  /// * a [CancellationToken] of [token] or,
  /// * `null` if [token] cannot be found
  CancellationToken<T, R?>? of<T extends Object, R extends Object?>(T token);

  @foundation.visibleForTesting
  bool hasTokenOf<T extends Object>(T token);

  @foundation.visibleForTesting
  bool noTokenOf<T extends Object>(T token);

  /// cancels the operation held by [CancellationToken] of [token]
  void cancel<T extends Object>(T token);

  /// cancels all registered operations
  void cancelAll();
}

class _CTManagerImpl implements CTManager {
  static final _CTManagerImpl _instance = _CTManagerImpl();

  final Map<Object, CancellationToken> _tokens = {};

  @override
  CancellationToken<T, R?> create<T extends Object, R extends Object?>({
    required T token,
    required Future<R> operation,
    FutureOr<void> Function()? onCancel,
  }) {
    final findToken = _tokens[token];
    assert(
      findToken == null,
      'Cannot create a new [CancellationToken]: `$token` already exists',
    );
    final removeTokenFunc = _removeToken(token);
    final registerOperation = operation.whenComplete(removeTokenFunc);
    final FutureOr<void> Function()? onCancelFunc;
    if (onCancel != null) {
      onCancelFunc = () {
        removeTokenFunc();
        onCancel();
      };
    } else {
      onCancelFunc = removeTokenFunc;
    }
    final createCancelableOperation = CancelableOperation.fromFuture(
      registerOperation,
      onCancel: onCancelFunc,
    );
    final createToken = CancellationToken(
      token: token,
      cancel: () => createCancelableOperation.cancel(),
      result: createCancelableOperation.valueOrCancellation(),
      isCompletedFunc: () => createCancelableOperation.isCompleted,
    );
    _tokens[token] = createToken;
    return createToken;
  }

  @override
  Future<R?> run<T extends Object, R extends Object?>({
    required T token,
    required Future<R> operation,
    FutureOr<void> Function()? onCancel,
  }) {
    return create(
      token: token,
      operation: operation,
      onCancel: onCancel,
    ).result;
  }

  void Function() _removeToken<T extends Object>(T token) {
    return () => _tokens.remove(token);
  }

  @override
  CancellationToken<T, R?>? of<T extends Object, R extends Object?>(T token) {
    final findToken = _tokens[token];
    if (findToken != null) {
      return findToken as CancellationToken<T, R?>;
    }
    if (foundation.kDebugMode) {
      dev.log(
        'Cannot find a [CancellationToken] registered with `$token`. '
        'This might be because it had completed, or it was cancelled, or it was never created.',
      );
    }
  }

  @foundation.visibleForTesting
  @override
  bool hasTokenOf<T extends Object>(T token) => _tokens.containsKey(token);

  @foundation.visibleForTesting
  @override
  bool noTokenOf<T extends Object>(T token) => !_tokens.containsKey(token);

  @override
  void cancel<T extends Object>(T token) {
    final findToken = _tokens[token];
    if (foundation.kDebugMode) {
      if (findToken == null) {
        dev.log(
          'Cannot find a [CancellationToken] registered with `$token`. '
          'This might be because it had completed, or it was cancelled, or it was never created.',
        );
      }
    }
    return findToken?.cancel();
  }

  @override
  void cancelAll() {
    _tokens.forEach((_, operation) => operation.cancel());
  }
}
