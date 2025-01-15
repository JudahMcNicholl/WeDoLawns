import 'package:equatable/equatable.dart';

class BaseState extends Equatable {
  const BaseState({this.count = 0});
  final int count;

  @override
  List<Object?> get props => [count];
}
