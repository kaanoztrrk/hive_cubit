import 'package:hive/hive.dart';
import 'package:hive_cubit/hive_cubit.dart';

// A minimal example showing HiveCubit outside of a Flutter UI.
// In a real Flutter app, wrap this cubit with BlocBuilder/BlocProvider
// as usual — HiveCubit is a drop-in replacement for Cubit.

class CounterCubit extends HiveCubit<int> {
  CounterCubit()
      : super(boxName: 'example_box', key: 'counter', initialState: 0);

  void increment() => updateState(state + 1);
}

Future<void> main() async {
  Hive.init('./.example_hive_data');

  final cubit = CounterCubit();
  await cubit.ready; // loads any previously persisted count

  print('Starting count: ${cubit.state}');

  cubit.increment();
  cubit.increment();

  print('Count after two increments: ${cubit.state}');
  print('Run this example again — the count will keep increasing,');
  print('because it is now persisted to disk.');

  await cubit.close();
}
