import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:hive_cubit/hive_cubit.dart';
import 'package:test/test.dart';

// A tiny cubit under test — mirrors how a real user would extend HiveCubit.
class CounterCubit extends HiveCubit<int> {
  CounterCubit()
      : super(boxName: 'counter_box', key: 'count', initialState: 0);

  void increment() => updateState(state + 1);
}

void main() {
  setUp(() async {
    // Sets up an in-memory Hive instance — no real files touched.
    await setUpTestHive();
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('starts with initialState when box is empty', () async {
    final cubit = CounterCubit();
    await cubit.ready;

    expect(cubit.state, 0);
  });

  test('updateState emits new value and persists it', () async {
    final cubit = CounterCubit();
    await cubit.ready;

    cubit.increment();

    expect(cubit.state, 1);

    final box = Hive.box('counter_box');
    expect(box.get('count'), 1);
  });

  test('restores persisted state on next creation', () async {
    final first = CounterCubit();
    await first.ready;
    first.increment();
    first.increment();
    await first.close();

    final second = CounterCubit();
    await second.ready;

    expect(second.state, 2);
  });
}
