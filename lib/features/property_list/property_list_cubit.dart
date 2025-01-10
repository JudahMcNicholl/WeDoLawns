import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedolawns/objects/objects.dart';
import 'package:wedolawns/objects/property.dart';

part 'property_list_state.dart';

class PropertyListCubit extends Cubit<PropertyListState> {
  PropertyListCubit() : super(PropertyListStateInitial());

  final _collectionRef = FirebaseFirestore.instance
      .collection('properties')
      .withConverter<Property>(
        fromFirestore: (snapshot, _) {
          final data = snapshot.data()!;
          return Property.fromJson({
            ...data,
            'Id': snapshot.id, // Include the document ID in the data map
          });
        },
        toFirestore: (property, _) => property.toJson(),
      );

  initialize() async {
    _properties.clear();
    QuerySnapshot querySnapshot = await _collectionRef.get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    for (var data in allData) {
      _properties.add(data as Property);
    }
    emit(PropertyListStateLoaded());
  }

  final List<Property> _properties = [];
  List<Property> get properties => _properties;

  insertProperty(Property property) {
    _properties.add(property);
  }
}
