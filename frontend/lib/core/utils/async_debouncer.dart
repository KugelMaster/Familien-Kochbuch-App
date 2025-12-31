import 'dart:async';

class AsyncDebouncer<T> {
  final Duration duration;
  Timer? _timer;
  Completer<T>? _completer;

  AsyncDebouncer(this.duration);

  Future<T> run(Future<T> Function() action) {
    _timer?.cancel();
    if (_completer != null && !_completer!.isCompleted) {
      _completer?.completeError(const Debounced());
    }

    _completer = Completer<T>();

    _timer = Timer(duration, () async {
      try {
        final result = await action();
        _completer?.complete(result);
      } catch (e, st) {
        _completer?.completeError(e, st);
      }
    });

    return _completer!.future;
  }

  void dispose() {
    _timer?.cancel();
    _completer?.completeError(const Debounced());
  }
}

class Debounced implements Exception {
  const Debounced();
}
