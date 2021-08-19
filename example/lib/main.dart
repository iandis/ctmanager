import 'package:flutter/material.dart';

import 'package:ctmanager/ctmanager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isBusy = false;
  bool _isToBeCancelledOperation = false;
  String _operationState = 'waiting';

  void _normalOperation() {
    if (_isBusy) return;
    setState(() {
      _operationState = 'normal operation executed';
      _isBusy = true;
    });
    CTManager.I.run(
      token: 'normal',
      operation: Future.delayed(
        const Duration(seconds: 3),
        () => setState(() {
          _operationState = 'normal operation finished';
          _isBusy = false;
        }),
      ),
    );
  }

  void _toBeCancelledOperation() {
    if (_isBusy) return;
    setState(() {
      _operationState = 'toBeCancelled operation executed';
      _isBusy = true;
      _isToBeCancelledOperation = true;
    });
    CTManager.I.run(
      token: 'toBeCancelled',
      operation: Future.delayed(
        const Duration(seconds: 5),
        () => setState(() {
          _operationState = 'toBeCancelled operation finished';
          _isBusy = false;
          _isToBeCancelledOperation = false;
        }),
      ),
      onCancel: () {
        setState(() {
          _operationState = 'toBeCancelled operation cancelled';
          _isBusy = false;
          _isToBeCancelledOperation = false;
        });
      },
    );
  }

  void _cancelToBeCancelledOperation() {
    CTManager.I.cancel('toBeCancelled');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CTManager example app'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_operationState),
              TextButton(
                onPressed: _isBusy ? null : _normalOperation,
                child: const Text('Run Normal Operation'),
              ),
              TextButton(
                onPressed: _isBusy ? null : _toBeCancelledOperation,
                child: const Text('Run To-Be-Cancelled Operation'),
              ),
              TextButton(
                onPressed: _isBusy && _isToBeCancelledOperation ? _cancelToBeCancelledOperation : null,
                child: const Text('Cancel To-Be-Cancelled Operation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
