import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueHandler<T> extends StatelessWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(T data) onData;

  const AsyncValueHandler({
    super.key,
    required this.asyncValue,
    required this.onData,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Text("In: Async Value Handler\nError: $e\nStack Trace: $st"),
      data: onData,
    );
  }
}
