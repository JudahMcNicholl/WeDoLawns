import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedolawns/objects/objects.dart';
import 'package:wedolawns/objects/property.dart';
import 'package:wedolawns/utils/constants.dart';

part 'property_edit_state.dart';

class PropertyEditCubit extends Cubit<PropertyEditState> {
  final Property _property;
  Property get property => _property;
  Property _originalProperty;
  Property get originalProperty => _originalProperty;

  bool get hasEdited {
    return _property.hasChanged(_originalProperty);
  }

  PropertyEditCubit(
    this._property,
    this._originalProperty,
  ) : super(PropertyEditStateInitial());

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

  // List of icons and their labels

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

  removeJob(Job job) {
    _jobs.remove(job);
  }

  saveProperty() async {
    await _collectionRef.doc(property.id).set(property);
    _originalProperty = Property.fromJson(property.toJson());
  }
}
