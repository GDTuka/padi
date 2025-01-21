import 'package:flutter/material.dart';
import 'package:padi/padi.dart';

class UserScope extends Padi {
  @override
  Future<void> initAsync(BuildContext context) async {}

  @override
  Future<void> onError(BuildContext context, Object? error, StackTrace? stackTrace) async {
    //youre hanlde here
    super.onError(context, error, stackTrace);
  }
}
