## 0.0.1

- Initial release.
- `HiveCubit<T>` base class with automatic load-on-create and
  persist-on-update.

## 0.1.0

- Widened `bloc` version constraint to support 8.x and 9.x.
- Fixed a race condition where `updateState` could silently skip
  persisting if called before the underlying box finished opening.
- Added `HiveCubitException` for clearer error messages.
- Documented that closing a `HiveCubit` does not close its Hive box.

## 0.1.1

- Rewrote the example with step-by-step console output explaining
  the `ready` pattern.
- Updated README examples and notes to match the async `updateState`
  signature, `HiveCubitException`, and box-close behavior from 0.1.0.