import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// Binding que desativa semântica no Windows desktop.
///
/// O engine Windows envia updates `AXTree` em resize/hover e dessincroniza a
/// ponte de acessibilidade ([flutter#98099](https://github.com/flutter/flutter/issues/98099)).
/// ERP interno não precisa de leitor de tela no Windows.
class ErpWidgetsFlutterBinding extends WidgetsFlutterBinding {
  static WidgetsBinding ensureInitialized() {
    if (BindingBase.debugBindingType() == null) {
      ErpWidgetsFlutterBinding();
    } else if (WidgetsBinding.instance is! ErpWidgetsFlutterBinding) {
      throw FlutterError(
        'Binding já inicializado como ${BindingBase.debugBindingType()}, '
        'mas o app requer ErpWidgetsFlutterBinding.',
      );
    }
    return WidgetsBinding.instance;
  }
  @override
  void initInstances() {
    super.initInstances();
    if (!Platform.isWindows) return;

    final dispatcher = platformDispatcher;
    dispatcher
      ..onSemanticsEnabledChanged = () {
        dispatcher.setSemanticsTreeEnabled(false);
      }
      ..setSemanticsTreeEnabled(false);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      dispatcher.setSemanticsTreeEnabled(false);
    });
  }

  @override
  bool get semanticsEnabled {
    if (Platform.isWindows) return false;
    return super.semanticsEnabled;
  }

  @override
  SemanticsHandle ensureSemantics() {
    if (Platform.isWindows) {
      return const _WindowsNoopSemanticsHandle();
    }
    return super.ensureSemantics();
  }
}

final class _WindowsNoopSemanticsHandle implements SemanticsHandle {
  const _WindowsNoopSemanticsHandle();

  @override
  void dispose() {}
}
