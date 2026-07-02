# hive_cubit

[![pub package](https://img.shields.io/pub/v/hive_cubit.svg)](https://pub.dev/packages/hive_cubit)

A lightweight [`Cubit`](https://pub.dev/packages/bloc) that automatically
persists its state to a [Hive](https://pub.dev/packages/hive) box —
zero boilerplate, no manual `box.put()` calls.

## Why

If you use Cubit for state management and Hive for local storage, you've
probably written the same pattern many times: read from a box on startup,
write to it on every state change. `hive_cubit` extracts that pattern into
a single base class.

## Usage

```dart
class SettingsCubit extends HiveCubit<SettingsModel> {
  SettingsCubit()
      : super(
          boxName: 'settings',
          key: 'user_settings',
          initialState: SettingsModel.initial(),
        );

  // updateState returns a Future — await it if you want to be sure
  // the write to disk has completed before moving on.
  Future<void> updateTheme(String theme) {
    return updateState(state.copyWith(theme: theme));
  }
}
```

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // or Hive.init(path) on non-Flutter platforms

  final settingsCubit = SettingsCubit();
  await settingsCubit.ready; // waits for any persisted state to load

  runApp(MyApp(settingsCubit: settingsCubit));
}
```

Every call to `updateState(newState)` does two things:

1. Emits `newState` immediately to any `BlocBuilder`/`BlocListener` watching
   the cubit.
2. Waits for the underlying box to be ready, then writes `newState` to the
   Hive box under `key`.

Because step 2 is asynchronous, `updateState` returns a `Future<void>`.
You don't have to await it — the emit already happened synchronously — but
awaiting it guarantees the write finished, which is useful right before
closing the app or navigating away.

On the next app launch, the cubit reads the persisted value back before
emitting its first state — no extra code required. See
[`example/hive_cubit_example.dart`](example/hive_cubit_example.dart) for a
runnable, step-by-step walkthrough of this loading behavior.

## Notes

- Register any custom Hive `TypeAdapter`s for `T` **before** creating the
  cubit, the same way you would for any other Hive-stored type.
- `T` must be a type Hive can store directly (primitives, or a type with
  a registered adapter).
- This package does not call `Hive.init()`/`Hive.initFlutter()` for you —
  call it once during app startup, as you normally would.
- Closing a `HiveCubit` (via `close()`) does **not** close its underlying
  Hive box, since the box may be shared elsewhere in your app. Close boxes
  explicitly with `Hive.box(name).close()` if and when appropriate.
- If the box fails to open, `HiveCubit` throws a `HiveCubitException`
  with a descriptive message instead of a raw `HiveError`.

## License

MIT