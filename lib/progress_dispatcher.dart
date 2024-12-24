import 'package:rxdart/rxdart.dart';

class ProgressDispatcher {
  final BehaviorSubject<double> _controller;

  ProgressDispatcher({
    required double initialValue,
  }) : _controller = BehaviorSubject<double>.seeded(initialValue);

  Stream<double> get stream => _controller.stream;

  double get value => _controller.value;

  void put(double percent) => _controller.add(percent);

  Future<void> dispose() => _controller.close();
}
