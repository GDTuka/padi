library padi;

import 'dart:async';
import 'package:flutter/material.dart';

/// DI container
abstract class Padi {
  final Completer<void> _inited = Completer();

  Future<void> _init(BuildContext context) async {
    // ignore: use_build_context_synchronously
    await initAsync(context).then((value) => _inited.complete()).onError((e, st) => onError(context, e, st));
  }

  Future<void> initAsync(BuildContext context);

  Future<void> onError(BuildContext context, Object? error, StackTrace? stackTrace) async {
    debugPrint(error.toString());
    debugPrintStack(stackTrace: stackTrace);
    _inited.completeError(error ?? '');
  }
}

class PadiScope<T extends Padi> extends InheritedWidget {
  const PadiScope({
    super.key,
    required this.padi,
    required super.child,
  });

  final T padi;

  static T? maybeOf<T extends Padi>(BuildContext context) {
    final padiScope = context.dependOnInheritedWidgetOfExactType<PadiScope<T>>();
    return padiScope?.padi;
  }

  static T of<T extends Padi>(BuildContext context) {
    final T? padi = maybeOf<T>(context);
    if (padi == null) {
      throw StateError('No PadiScope of type $T found in context');
    }
    return padi;
  }

  @override
  bool updateShouldNotify(covariant PadiScope<T> oldWidget) {
    return oldWidget.padi != padi;
  }
}

class PadiWidget<T extends Padi> extends StatelessWidget {
  const PadiWidget({
    super.key,
    required this.create,
    required this.child,
    required this.loaderBuilder,
    this.onCreated,
    this.errorBuilder,
  });

  final Widget child;
  final WidgetBuilder loaderBuilder;
  final WidgetBuilder? errorBuilder;
  final T Function() create;
  final void Function(T)? onCreated;

  Future<T> _init(BuildContext context) async {
    final padi = create();
    await padi._init(context);
    return padi;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _init(context),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return loaderBuilder(context);
        }
        if (snap.hasError && errorBuilder != null) {
          return errorBuilder!(context);
        }
        onCreated?.call(snap.data as T);
        return PadiScope(
          padi: snap.data as T,
          child: child,
        );
      },
    );
  }
}
