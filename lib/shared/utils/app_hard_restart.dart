import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

typedef SoftRestartCallback = Future<void> Function();

/// Reinício **total** do aplicativo (anti-bug).
///
/// - **Release/Profile:** relança o .exe e encerra o processo (reset real).
/// - **Debug (flutter run / IDE):** usa [registerSoftRestartFallback] para não
///   matar a sessão de debug nem deixar processo órfão bloqueando o build.
abstract final class AppHardRestart {
  static SoftRestartCallback? _softRestartFallback;

  /// Registrado no [main] — obrigatório em debug; fallback em release se o .exe falhar.
  static void registerSoftRestartFallback(SoftRestartCallback callback) {
    _softRestartFallback = callback;
  }

  static Future<void> restart() async {
    if (kIsWeb) {
      debugPrint('AppHardRestart: reinício de processo não suportado na web.');
      return;
    }

    if (kDebugMode) {
      await _runSoftRestart();
      return;
    }

    final launched = await _tryLaunchNewProcess();
    if (launched) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      exit(0);
      return;
    }

    await _runSoftRestart();
  }

  static Future<void> _runSoftRestart() async {
    if (_softRestartFallback != null) {
      debugPrint('AppHardRestart: soft restart.');
      await _softRestartFallback!();
      return;
    }
    debugPrint('AppHardRestart: nenhum fallback registrado.');
  }

  static Future<bool> _tryLaunchNewProcess() async {
    try {
      final executable = Platform.resolvedExecutable;
      final workingDir = p.dirname(executable);

      if (Platform.isWindows) {
        final result = await Process.run(
          'cmd.exe',
          ['/c', 'start', '', executable],
          workingDirectory: workingDir,
        );
        return result.exitCode == 0;
      }

      await Process.start(
        executable,
        const [],
        mode: ProcessStartMode.detached,
        workingDirectory: workingDir,
      );
      return true;
    } catch (e, st) {
      debugPrint('AppHardRestart: falha ao lançar processo: $e\n$st');
      return false;
    }
  }
}
