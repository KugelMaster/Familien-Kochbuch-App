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
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text("Error: $e"),
      data: onData,
    );
  }
}
