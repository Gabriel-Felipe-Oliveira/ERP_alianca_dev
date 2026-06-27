import 'package:flutter/foundation.dart';

/// Base para ViewModels com lifecycle seguro após [dispose].
abstract class BaseViewModel extends ChangeNotifier {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
