library padi;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// DI container
abstract class Padi extends IPadi {
  final Completer<void> _inited = Completer();

  @override
  Future<void> init(BuildContext context) async {
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

/// interface for DI container
abstract class IPadi extends ChangeNotifier {
  Future<void> init(BuildContext context);

  static T of<T extends IPadi>(BuildContext context) => context.read<T>();

  static T depend<T extends IPadi>(BuildContext context) => context.watch<T>();
}

class OldPadiWidget<T extends Padi> extends ChangeNotifierProvider<T> {
  OldPadiWidget({
    super.key,
    required T Function() create,
    required WidgetBuilder loaderBuilder,
    WidgetBuilder? errorBuilder,
    required super.child,
  }) : super(
          create: (context) => create()..init(context),
          builder: (context, child) => FutureBuilder(
            future: context.read<T>()._inited.future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return loaderBuilder(context);
              }
              if (snap.hasError && errorBuilder != null) {
                return errorBuilder(context);
              }
              return child!;
            },
          ),
        );
}

class PadiScope<T extends IPadi> extends InheritedWidget {
  const PadiScope({
    super.key,
    required this.padi,
    required super.child,
  });

  final IPadi padi;

  // ignore: unused_element
  static T? maybeOf<T extends IPadi>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PadiScope<T>>()! as T;

  // ignore: unused_element
  static T of<T extends IPadi>(BuildContext context) {
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

class PadiWidget<T extends IPadi> extends StatelessWidget {
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
    await padi.init(context);
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
