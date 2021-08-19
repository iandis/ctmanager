A helper capable of managing multiple cancellation tokens.

## Usage
`CTManager` can be used either as a singleton or as a new instance. Let's take a look at this example.
### with singleton
```dart
final newCancelToken = CTManager.I.create(
    token: 'ct1',
    operation: Future.delayed(
        const Duration(seconds: 5), 
        () => 'done',
    ),
    // optional
    onCancel: () => print('cancelled'),
);
...
```
### without singleton
```dart
final ctManager = CTManager();
final newCancelToken = ctManager.create(
    token: 'ct1',
    operation: Future.delayed(
        const Duration(seconds: 5), 
        () => 'done',
    ),
    // optional
    onCancel: () => print('cancelled'),
);
...
```
note: the `token` field can be anything except `null`.

Here both `result` have a new instance of `CancellationToken<String, String?>` since the `token` is a `String` and the return value of `operation` will be a `String`. 

You might be wondering why it's CancellationToken<String, **String?**> and not CancellationToken<String, **String**>. Let's take a look at the following.
##### example 1
```dart
...
// the operation will be cancelled after 3 seconds.
Future.delayed(
    const Duration(seconds: 3), 
    newCancelToken.cancel,
);

final result = await newCancelToken.result;

// since the operation will never return `null`, 
// we just need to check if it's `null` or not.
// if it is then it was cancelled.
if(result == null) {
    print('operation was cancelled after 3 seconds');
}else{
    print('operation succeeded');
}
```
However if the `operation` can also return `null`, then you have to check whether it's completed or not.
##### example 2
```dart
final nullableValueCancelToken = CTManager.I.create(
    token: 'ct1',
    operation: Future.delayed(
        const Duration(seconds: 5), 
        () => 1 < 2 ? null : 'done',
    ),
);
// the operation will be cancelled after 3 seconds.
Future.delayed(
    const Duration(seconds: 3), 
    newCancelToken.cancel,
);

final result = await nullableValueCancelToken.result;
```
Here we have to check `isCompleted` first, before checking the value.
```dart

if(nullableValueCancelToken.isCompleted) {
    if(result == null) {
        print('operation suceeded with null value');
    }else{
        print('operation succeeded with a value');
    }
}else{
    print('operation was cancelled after 3 seconds.');
}
```
Now you might say `CancelabeOperation` from [async](https://pub.dev/packages/async) can also do all these things in a more simple way. That's correct since this package uses it, but `CTManager` is able find those `CancellationToken`s via
```dart
final findToken = CTManager.I.of<String, String?>('ct1');
// note: before checking the token, 
// make sure to check [findToken] is null or not.
// if it is then the token you're finding can be
// either had ben cancelled, had completed, or never created.
```
and if you just want to cancel
```dart
CTManager.I.cancel('ct1');
```
Regarding **example 1**, if you already know that the `operation` will never return `null`, instead of creating it, you can directly run it.
```dart
final result = await CTManager.I.run(
    token: 'ct1',
    operation: Future.delayed(
        const Duration(seconds: 5), 
        () => 1 < 2 ? null : 'done',
    ),
);
// and to cancel it, just call
//
// CTManager.I.cancel('ct1');
//
// just like the above example.
```