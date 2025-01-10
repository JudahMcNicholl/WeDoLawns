import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedolawns/objects/objects.dart';
import 'package:wedolawns/objects/property.dart';

part 'property_create_state.dart';

class PropertyCreateCubit extends Cubit<PropertyCreateState> {
  PropertyCreateCubit() : super(PropertyCreateStateInitial());

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

  // List of icons and their labels
  final List<Map<String, dynamic>> items = [
    {'icon': Icons.grass, 'label': 'Chainsaw', 'isActive': false},
    {'icon': Icons.grass, 'label': 'Hedgetrimmer', 'isActive': false},
    {'icon': Icons.grass, 'label': 'Lawnmower', 'isActive': false},
  ];

  final List<Job> _jobs = [];
  List<Job> get jobs => _jobs;
  int get jobCount => _jobs.length;

  bool addJob(String name, String description) {
    if (name.isEmpty || description.isEmpty) return false;
    Job job = Job(
      id: jobCount,
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

    _jobs.add(job);

    return true;
  }

  createProperty({
    required String name,
    required String lat,
    required String lon,
    required String estDuration,
    required String estWoolsacks,
    required String difficulty,
  }) async {
    Property property = Property(
      name: name,
      location: GeoPoint(double.parse(lat), double.parse(lon)),
      dateCreated: DateTime.now(),
      difficulty: int.parse(difficulty),
      photos: [],
      jobs: _jobs,
    );

    await _collectionRef.add(property);
    emit(PropertyCreateStateCreated());
  }

  removeJob(Job job) {
    _jobs.remove(job);
  }
}
