import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedolawns/objects/objects.dart';
import 'package:wedolawns/objects/property.dart';
import 'package:wedolawns/utils/constants.dart';

part 'property_create_state.dart';

class PropertyCreateCubit extends Cubit<PropertyCreateState> {
  PropertyCreateCubit() : super(PropertyCreateStateInitial());

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

  final List<Job> _jobs = [];
  List<Job> get jobs => _jobs;
  int get jobCount => _jobs.length;

  bool addJob({required String name, required String description, String estimatedHours = "0"}) {
    if (name.isEmpty || description.isEmpty) return false;
    Job job = Job(
      id: jobCount,
      name: name,
      description: description,
      tools: [],
      estimatedHours: double.parse(estimatedHours),
    );
    for (var i in tools) {
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
    required String estWoolsacks,
    required String difficulty,
    required String contactName,
    required String contactPhoneNumber,
  }) async {
    Property property = Property(
        address: name,
        location: GeoPoint(double.parse(lat), double.parse(lon)),
        dateCreated: DateTime.now(),
        estimatedWoolsacks: double.parse(estWoolsacks),
        difficulty: int.parse(difficulty),
        photos: [],
        jobs: _jobs,
        contactName: contactName,
        contactPhoneNumber: contactPhoneNumber);

    await _collectionRef.add(property);
    emit(PropertyCreateStateCreated());
  }

  removeJob(Job job) {
    _jobs.remove(job);
  }
}
