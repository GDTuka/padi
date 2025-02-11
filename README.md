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
