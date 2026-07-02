class HiveCubitException implements Exception {
  final String message;
  HiveCubitException(this.message);

  @override
  String toString() => 'HiveCubitException: $message';
}
