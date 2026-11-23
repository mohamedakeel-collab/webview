part of '../imports/store_imports.dart';

class CartTracker {
  int? _lastCount;

  bool get hasCount => _lastCount != null;

  int? get count => _lastCount;

  void updateCount(int count) {
    if (count < 0 || count == _lastCount) return;

    if (count == 0) {
      OneSignal.User.removeTags(['cart_items', 'cart_at']);
    } else {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      OneSignal.User.addTags({
        'cart_items': count.toString(),
        'cart_at': timestamp.toString(),
      });
    }

    _lastCount = count;
  }
}
