import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedolawns/objects/objects.dart';
import 'package:wedolawns/objects/property.dart';

part 'property_state.dart';

class PropertyCubit extends Cubit<PropertyState> {
  PropertyCubit(this.property) : super(PropertyStateInitial());

  final Property property;

  // List of icons and their labels
  final List<Map<String, dynamic>> items = [
    {'icon': Icons.grass, 'label': 'Chainsaw', 'isActive': false},
    {'icon': Icons.grass, 'label': 'Hedgetrimmer', 'isActive': false},
    {'icon': Icons.grass, 'label': 'Lawnmower', 'isActive': false},
  ];

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

  bool addJob(String name, String description) {
    if (name.isEmpty || description.isEmpty) return false;
    Job job = Job(
      id: property.jobs.length,
      name: name,
      description: description,
      tools: [],
    );
    for (var i in items) {
      if (i["isActive"]) {
        job.tools.add(i['label']);
        i['isActive'] = false;
      }
    }

    property.jobs.add(job);
    _collectionRef.doc(property.id).set(property);
    return true;
  }

  removeJob(Job job) {
    property.jobs.remove(job);
    _collectionRef.doc(property.id).set(property);
  }
}
