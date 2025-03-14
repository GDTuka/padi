## Features

This PADI - Async Dependency Injection - simple async DI

## Usage

Create new Padi scope
```dart
class UserScope extends Padi {
  @override
  Future<void> initAsync(BuildContext context) async {}
}
```
Add some deps
```dart
class UserScope extends Padi {
  late final String yourDep;
  @override
  Future<void> initAsync(BuildContext context) async {
    yourDep = "hello di";
  }

  @override
  Future<void> onError(BuildContext context, Object? error, StackTrace? stackTrace) async {
    //your hanlde here
    super.onError(context, error, stackTrace);
  }
}
```
Create Padi Widget that will wrap your dependency

```dart
runApp(
 PadiWidget<UserScope>(
        create: UserScope.new,
        loaderBuilder: (context) => Container(),
        errorBuilder: (context) => Container(),
        child: const App(),
      ),
)
```

get dependency from your di

```dart
PadiScope.of<UserScope>(context);
```

PadiWidget arguments  explanation

```dart
  PadiWidget<UserScope>(
    // Function that returns a PadiScope
    create: UserScope.new,
    // Widget shown while `initAsync` method is running
    loaderBuilder: (context) => Container(),
    // Widget shown when an error occurs in initAsync
    errorBuilder: (context) => Container(),
    // Called after instance of Padi is created. Contains instance of created scope in function arguments
    onCreated: (padi) {},
    // Child widget that will be displayed
    child: const App(),
  ),
```
