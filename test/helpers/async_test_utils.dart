import 'package:flutter_test/flutter_test.dart';

/// Aguarda [condition] ser verdadeira (útil para init async em ViewModels).
Future<void> waitUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 3),
  Duration interval = const Duration(milliseconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timeout aguardando condição assíncrona.');
    }
    await Future<void>.delayed(interval);
  }
}
