import 'package:flutter/material.dart';
import 'package:padi/padi.dart';

class SomeScope extends Padi {
  late final String name;

  @override
  Future<void> initAsync(BuildContext context) async {
    name = 'GDTuka';
  }
}

extension SomeScopeExtension on BuildContext {
  SomeScope get someScope => PadiScope.of<SomeScope>(this);
}
