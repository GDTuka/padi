import 'package:flutter/material.dart';
import 'package:padi/padi.dart';

import 'scope.dart';

void main() {
  runApp(
    PadiWidget(
      create: SomeScope.new,
      child: const Home(),
      errorBuilder: (context) => const Center(
        child: Text('Error'),
      ),
      loaderBuilder: (context) => const Center(
        child: SizedBox(
          height: 30,
          width: 30,
          child: CircularProgressIndicator(),
        ),
      ),
    ),
  );
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Hello ${context.someScope.name}',
        ),
      ),
    );
  }
}
