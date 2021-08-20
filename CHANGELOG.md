## 0.0.1+2

* fixed CTManager's `create` method
    * bugs:
        * [1] isCompleted returns true when operation was actually cancelled
        * [2] assert not working
    * fixes:
        * [1] rely on CancelableOperation's `isCanceled`
        * [2] now throws AssertionError
* removed **flutter_test** in pubspec
    * changed to **test**
* updated example
    * no longer uses flutter sdk
* updated README
    * fixed error on example 2
    * updated second example 1 (last example)
    * added clarification about the package
## 0.0.1+1

* updated README
* updated pubspec
* formatted files according to dartfmt
## 0.0.1

* added CancellationToken class
* added CTManager helper class
* added test
* added example widget
* added test for the example
