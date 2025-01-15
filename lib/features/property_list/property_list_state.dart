part of 'property_list_cubit.dart';

abstract class PropertyListState extends BaseState {
  const PropertyListState({super.count});
}

class PropertyListStateInitial extends PropertyListState {
  const PropertyListStateInitial({super.count});
}

class PropertyListStateLoaded extends PropertyListState {
  const PropertyListStateLoaded({super.count});
}

class PropertyDeleted extends PropertyListState {
  const PropertyDeleted({super.count});
}

class InfoWindowTapped extends PropertyListState {
  final Property property;
  const InfoWindowTapped({super.count, required this.property});
}
