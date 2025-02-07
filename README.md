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
  late final String youreDep;
  @override
  Future<void> initAsync(BuildContext context) async {
    youreDep = "hello di";
  }

  @override
  Future<void> onError(BuildContext context, Object? error, StackTrace? stackTrace) async {
    //youre hanlde here
    super.onError(context, error, stackTrace);
  }
}
```
Create Padi Widget that will wrap youre dependency

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

get dependency from youre di

```dart
PadiScope.of<GlobalScope>(this);
```
