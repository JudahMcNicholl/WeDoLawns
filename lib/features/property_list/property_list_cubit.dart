import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wedolawns/objects/base_state.dart';
import 'package:wedolawns/objects/property.dart';

part 'property_list_state.dart';

class PropertyListCubit extends Cubit<PropertyListState> {
  PropertyListCubit() : super(PropertyListStateInitial(count: 0));

  final _collectionRef = FirebaseFirestore.instance.collection('properties').withConverter<Property>(
        fromFirestore: (snapshot, _) {
          final data = snapshot.data()!;
          return Property.fromJson({
            ...data,
            'Id': snapshot.id, // Include the document ID in the data map
          });
        },
        toFirestore: (property, _) => property.toJson(),
      );

  final List<Marker> _markers = [];
  List<Marker> get markers => _markers;

  initialize() async {
    _properties.clear();
    QuerySnapshot querySnapshot = await _collectionRef.get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    for (var data in allData) {
      _properties.add(data as Property);
    }
    _properties.sort((a, b) {
      final now = DateTime.now();
      final aDiff = (a.dateCreated.difference(now)).abs();
      final bDiff = (b.dateCreated.difference(now)).abs();
      return aDiff.compareTo(bDiff);
    });

    _markers.clear();
    for (Property property in properties) {
      _markers.add(
        Marker(
          markerId: MarkerId(property.id!),
          position: LatLng(property.location.latitude, property.location.longitude),
          onTap: () {
            emit(InfoWindowTapped(
              count: state.count + 1,
              property: property,
            ));
          },
          // infoWindow: InfoWindow(
          //     title: property.name,
          //     onTap: () {
          //       emit(InfoWindowTapped(
          //         count: state.count + 1,
          //         property: property,
          //       ));
          //     }),
        ),
      );
    }
    emit(PropertyListStateLoaded(count: state.count + 1));
  }

  final List<Property> _properties = [];
  List<Property> get properties => _properties;

  insertProperty(Property property) {
    _properties.add(property);
  }

  deleteProperty(Property property) async {
    log("Deleting");
    _collectionRef.doc(property.id).delete().then((value) {
      log("Deleted");
      _properties.remove(property);
      emit(PropertyDeleted(count: state.count + 1));
    });
  }
}
