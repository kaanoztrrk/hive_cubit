// ignore_for_file: avoid_print
//
// Copy this whole file, run it with `dart run hive_cubit_example.dart`,
// and read the printed output top to bottom — it walks you through
// exactly what HiveCubit is doing and when.
//
// Run it a SECOND time afterwards. The count will pick up where it
// left off, because it was persisted to disk on your first run.

import 'package:hive/hive.dart';
import 'package:hive_cubit/hive_cubit.dart';

// This is a normal Cubit, except it extends HiveCubit instead of Cubit.
// boxName + key together decide *where on disk* this cubit's state lives.
class CounterCubit extends HiveCubit<int> {
  CounterCubit()
      : super(boxName: 'example_box', key: 'counter', initialState: 0);

  // updateState() does two things: emits the new value (like emit() does
  // in a normal Cubit) AND writes it to disk. It's async because it waits
  // for the box to finish opening before writing.
  Future<void> increment() => updateState(state + 1);
}

Future<void> main() async {
  _section('STEP 1 — Initialize Hive');
  // In a Flutter app you'd normally call Hive.initFlutter() instead.
  // This just tells Hive where on disk to store its files.
  Hive.init('./.example_hive_data');
  print('Hive will store data in ./.example_hive_data');

  _section('STEP 2 — Create the cubit');
  final cubit = CounterCubit();
  // The constructor returns IMMEDIATELY with initialState (0), even
  // though HiveCubit is opening the box and reading from disk in the
  // background. This is why we print the state right away below —
  // to prove it starts at 0 no matter what's saved on disk.
  print('Cubit created. State right now: ${cubit.state}');
  print('(This is always 0 here, even on the second run — the box '
      "hasn't finished opening yet.)");

  _section('STEP 3 — Wait for the box to open (cubit.ready)');
  print('Awaiting cubit.ready ...');
  await cubit.ready;
  print('Done. State after loading from disk: ${cubit.state}');
  print('(On your first run this is 0. On later runs, this is '
      'whatever you left it at last time.)');

  _section('STEP 4 — Increment a couple of times');
  await cubit.increment();
  print('After 1st increment: ${cubit.state}');

  await cubit.increment();
  print('After 2nd increment: ${cubit.state}');
  print('Each increment() call was awaited, which means we know for '
      'sure the value was written to disk before moving on.');

  _section('STEP 5 — Close the cubit');
  await cubit.close();
  print('Cubit closed. The last value written to disk was: ${cubit.state}');

  _section('DONE');
  print('Run this file again — cubit.state after STEP 3 will start '
      'from ${cubit.state}, not from 0, because it was persisted.');
}

void _section(String title) {
  print('\n--- $title ---');
}
