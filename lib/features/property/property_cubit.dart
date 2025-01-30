import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wedolawns/objects/drive_item.dart';
import 'package:wedolawns/objects/objects.dart';
import 'package:wedolawns/objects/property.dart';
import 'package:wedolawns/utils/common.dart';

part 'property_state.dart';

enum SwapType { leftToRight, rightToLeft, upwards, downwards }

class PropertyCubit extends Cubit<PropertyState> {
  PropertyCubit(this.property) : super(PropertyStateInitial());

  Property property;

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
    property.actualWoolsacks = double.parse(woolsacksFilled);
    _collectionRef.doc(property.id).set(property);
    return true;
  }

  bool updateActualWoolsacks({required String woolsacksUsed}) {
    property.actualWoolsacks = double.parse(woolsacksUsed);
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

  bool deleteMedia({required int index}) {
    property.photos.removeAt(index);
    _collectionRef.doc(property.id).set(property);
    return true;
  }

  bool swapMedia({
    required int index,
    required SwapType swapType,
  }) {
    switch (swapType) {
      case SwapType.leftToRight:
        swapItems(property.photos, index, index + 1);
        break;
      case SwapType.rightToLeft:
        swapItems(property.photos, index, index - 1);
      case SwapType.upwards:
        swapItems(property.photos, index, index - 2);
      case SwapType.downwards:
        swapItems(property.photos, index, index + 2);
    }
    _collectionRef.doc(property.id).set(property);
    return true;
  }

  completeJob(Job job, String actualHours) async {
    job.completed = true;
    job.actualHours = double.tryParse(actualHours);
    await _collectionRef.doc(property.id).set(property);
    return true;
  }

  updateMedia(List<List<DriveItem>> value) async {
    List<List<DriveItem>> removed = value
        .where((group) => group.any((e) => !e.isSelected && property.photos.any((v) => v.path.contains(e.id)) && !e.isTitle))
        .toList(); // Keep the entire group if at least one was removed

    List<List<DriveItem>> added = value
        .where((group) => group.any((e) => e.isSelected && !property.photos.any((v) => v.path.contains(e.id)) && !e.isTitle))
        .toList(); // Keep the entire group if at least one was added

    // List<DriveItem> kept = value.where((e) => property.photos.any((v) => v.path.contains(e.id)) && !e.isTitle).toList();
    for (List<DriveItem> item in removed) {
      DriveItem? first = item.isNotEmpty ? item[0] : null;
      DriveItem? second = item.length > 1 ? item[1] : null;
      if (first != null && !first.isSelected && second != null && !second.isSelected) {
        int indexOf = property.photos.indexWhere((e) => e.path.contains(first.path) || e.path.contains(second.path));
        if (indexOf != -1) {
          deleteMedia(index: indexOf);
        }
      }
    }
    for (List<DriveItem> item in added) {
      DriveItem? first = item.isNotEmpty ? item[0] : null;
      DriveItem? second = item.length > 1 ? item[1] : null;
      int indexOf = property.photos.indexWhere((e) => e.path.contains(first?.id ?? "") || (second != null && e.path.contains(second.id)));
      MediaItem mediaItem = MediaItem(id: property.photos.length, path: "");
      if (indexOf != -1) {
        mediaItem = property.photos[indexOf];
      }
      if (first != null) {
        if (first.mimeType == "image/heif") {
          mediaItem.path = first.path;
        } else {
          mediaItem.androidPath = first.path;
        }
      }
      if (second != null) {
        if (second.mimeType == "image/heif") {
          mediaItem.path = second.path;
        } else {
          mediaItem.androidPath = second.path;
        }
      }
      if (indexOf == -1) {
        property.photos.add(
          mediaItem,
        );
      }
    }

    await _collectionRef.doc(property.id).set(property);
  }
}
