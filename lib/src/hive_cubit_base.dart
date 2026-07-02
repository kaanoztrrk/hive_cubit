import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';

import 'hive_cubit_exception.dart';

/// A [Cubit] that automatically persists its state to a Hive box.
///
/// Extend this class instead of [Cubit] to get zero-boilerplate
/// local persistence. State is loaded from Hive on creation and
/// written back to Hive every time [updateState] is called.
///
/// Example:
/// ```dart
/// class SettingsCubit extends HiveCubit<SettingsModel> {
///   SettingsCubit()
///       : super(
///           boxName: 'settings',
///           key: 'user_settings',
///           initialState: SettingsModel.initial(),
///         );
///
///   void updateTheme(String theme) {
///     updateState(state.copyWith(theme: theme));
///   }
/// }
///
/// // Somewhere during app startup:
/// final cubit = SettingsCubit();
/// await cubit.ready; // ensures persisted state (if any) is loaded
/// ```
///
/// /// Note: closing this cubit via [close] does NOT close the underlying
/// Hive box, since the same box may be shared by other cubits or parts
/// of your app. Close boxes explicitly via `Hive.box(name).close()` if
/// and when appropriate.
abstract class HiveCubit<T> extends Cubit<T> {
  HiveCubit({
    required this.boxName,
    required this.key,
    required T initialState,
  }) : super(initialState) {
    ready = _init();
  }

  /// The name of the Hive box this cubit reads from and writes to.
  final String boxName;

  /// The key under which this cubit's state is stored inside [boxName].
  final String key;

  /// Completes once the persisted state (if any) has been loaded and
  /// emitted. Await this before relying on restored state, e.g. in a
  /// splash screen or app bootstrap step.
  late final Future<void> ready;

  Box? _box;

  Future<void> _init() async {
    try {
      _box = Hive.isBoxOpen(boxName)
          ? Hive.box(boxName)
          : await Hive.openBox(boxName);
    } catch (e) {
      throw HiveCubitException('Failed to open box "$boxName": $e');
    }

    final saved = _box!.get(key);
    if (saved != null && saved is T) {
      emit(saved);
    }
  }

  /// Emits [newState] and persists it to the underlying Hive box.
  ///
  /// If the box has not finished opening yet, the emit still happens
  /// immediately but the write is skipped for this call; the next
  /// call to [updateState] will persist the latest value.
  Future<void> updateState(T newState) async {
    emit(newState);
    await ready;
    await _box?.put(key, newState);
  }
}
