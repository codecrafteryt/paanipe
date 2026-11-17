import 'dart:async';

import 'package:get/get.dart';

/// Reactive data + loading + error for one Firestore stream.
/// Pair with `StateView` in the UI.
class StreamState<T> {
  StreamState(T initial) : data = Rx<T>(initial);

  final Rx<T> data;
  final isLoading = true.obs;
  final error = RxnString();
  StreamSubscription<T>? _sub;

  T get value => data.value;

  void bind(Stream<T> stream) {
    cancel();
    isLoading.value = true;
    error.value = null;
    _sub = stream.listen(
      (v) {
        data.value = v;
        isLoading.value = false;
      },
      onError: (Object e) {
        error.value = e.toString();
        isLoading.value = false;
      },
    );
  }

  void cancel() => _sub?.cancel();
}
