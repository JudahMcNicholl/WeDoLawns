import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  bool addJob({required String name, required String description, String estimatedHours = "0"}) {
    if (name.isEmpty || description.isEmpty) return false;
    Job job = Job(
      id: property.jobs.isEmpty ? 0 : property.jobs.map((job) => job.id).reduce((a, b) => a > b ? a : b),
      name: name,
      description: description,
      tools: [],
      estimatedHours: double.parse(estimatedHours),
    );
    for (var i in items) {
      if (i["isActive"]) {
        job.tools.add(i['label']);
        i['isActive'] = false;
      }
    }

    property.jobs.add(job);
    property.jobs.sort((a, b) => a.id.compareTo(b.id));
    _collectionRef.doc(property.id).set(property);
    return true;
  }

  removeJob(Job job) {
    property.jobs.remove(job);
    _collectionRef.doc(property.id).set(property);
  }

  bool editJob({required Job job, required String name, required String description, required String estimatedHours}) {
    property.jobs.remove(job);
    Job newJob = Job(
      id: job.id,
      name: name,
      description: description,
      tools: [],
      estimatedHours: double.parse(estimatedHours),
    );
    for (var i in items) {
      if (i["isActive"]) {
        newJob.tools.add(i['label']);
        i['isActive'] = false;
      }
    }
    property.jobs.insert(job.id, newJob);
    property.jobs.sort((a, b) => a.id.compareTo(b.id));
    _collectionRef.doc(property.id).set(property);
    return true;
  }

  bool finished({required String hoursWorked, required String woolsacksFilled}) {
    property.dateFinished = DateTime.now();
    property.hoursWorked = double.parse(hoursWorked);
    property.actualWoolsacks = double.parse(woolsacksFilled);
    _collectionRef.doc(property.id).set(property);
    return true;
  }

  bool updateActualHours({required String hoursWorked}) {
    property.hoursWorked = double.parse(hoursWorked);
    _collectionRef.doc(property.id).set(property);
    return true;
  }

  bool updateActualWoolsacks({required String woolsacksUsed}) {
    property.actualWoolsacks = double.parse(woolsacksUsed);
    _collectionRef.doc(property.id).set(property);
    return true;
  }

  bool addMedia({required int index, required String mediaUrl}) {
    if (mediaUrl.contains("youtube")) {
    } else {
      List<String> split = mediaUrl.split("/");
      String id = split[split.length - 2];
      String url = "https://drive.google.com/uc?export=download&id=$id";
      property.photos[index].path = url;
    }

    if (property.photos.isEmpty) {
      property.photos.add(MediaItem(id: 0, path: ""));
      property.photos.add(MediaItem(id: 1, path: ""));
    }

    _collectionRef.doc(property.id).set(property);
    return true;
  }

  bool updateLocation({required LatLng loc}) {
    GeoPoint newLocation = GeoPoint(loc.latitude, loc.longitude);
    property.location = newLocation;
    _collectionRef.doc(property.id).set(property);
    return true;
  }

  bool setYoutubeUrl({required String youtubeUrl}) {
    property.youtubeUrl = youtubeUrl;
    _collectionRef.doc(property.id).set(property);
    return true;
  }
}
