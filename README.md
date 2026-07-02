# hive_cubit

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

  void updateTheme(String theme) {
    updateState(state.copyWith(theme: theme));
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

1. Emits `newState` to any `BlocBuilder`/`BlocListener` watching the cubit.
2. Writes `newState` to the Hive box under `key`.

On the next app launch, the cubit reads the persisted value back before
emitting its first state — no extra code required.

## Notes

- Register any custom Hive `TypeAdapter`s for `T` **before** creating the
  cubit, the same way you would for any other Hive-stored type.
- `T` must be a type Hive can store directly (primitives, or a type with
  a registered adapter).
- This package does not call `Hive.init()`/`Hive.initFlutter()` for you —
  call it once during app startup, as you normally would.

## License

MIT
