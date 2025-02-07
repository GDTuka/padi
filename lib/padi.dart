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

  final Padi padi;

  // ignore: unused_element
  static T? maybeOf<T extends Padi>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PadiScope<T>>()! as T;

  // ignore: unused_element
  static T of<T extends Padi>(BuildContext context) {
    final padi = maybeOf<T>(context);
    if (padi == null) {
      throw StateError('No Padi found in context');
    }
    return padi;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

class PadiWidget<T extends Padi> extends StatelessWidget {
  const PadiWidget({
    super.key,
    required this.create,
    required this.child,
    required this.loaderBuilder,
    this.errorBuilder,
  });

  final Widget child;
  final WidgetBuilder loaderBuilder;
  final WidgetBuilder? errorBuilder;
  final T Function() create;

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
        return PadiScope<T>(
          padi: snap.data as T,
          child: child,
        );
      },
    );
  }
}
