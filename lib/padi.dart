library padi;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// DI container
abstract class Padi extends IPadi {
  final Completer<void> _inited = Completer();
  @override
  void init(BuildContext context) {
    initAsync(context).then((value) => _inited.complete()).onError((e, st) => onError(context, e, st));
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
  void init(BuildContext context);

  static T of<T extends IPadi>(BuildContext context) => context.read<T>();

  static T depend<T extends IPadi>(BuildContext context) => context.watch<T>();
}

/// Padi widget
class PadiWidget<T extends Padi> extends ChangeNotifierProvider<T> {
  PadiWidget({
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

