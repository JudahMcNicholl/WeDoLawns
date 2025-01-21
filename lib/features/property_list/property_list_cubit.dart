import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swipe_refresh/swipe_refresh.dart';
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
          icon: property.isNew
              ? await svgToBitmapDescriptor(svgString: """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
  <path d="M12 2C8.13 2 5 5.13 5 8.5c0 3.64 3.88 7.67 7 12 3.12-4.33 7-8.36 7-12 0-3.37-3.13-6.5-7-6.5zm0 9.5c-1.66 0-3-1.34-3-3s1.34-3 3-3 3 1.34 3 3-1.34 3-3 3z" fill="#8F9563"/>
</svg>
""")
              : property.isComplete
                  ? await svgToBitmapDescriptor(svgString: """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
  <path d="M12 2C8.13 2 5 5.13 5 8.5c0 3.64 3.88 7.67 7 12 3.12-4.33 7-8.36 7-12 0-3.37-3.13-6.5-7-6.5zm0 9.5c-1.66 0-3-1.34-3-3s1.34-3 3-3 3 1.34 3 3-1.34 3-3 3z" fill="#236002"/>
</svg>
""")
                  : await svgToBitmapDescriptor(svgString: """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
  <path d="M12 2C8.13 2 5 5.13 5 8.5c0 3.64 3.88 7.67 7 12 3.12-4.33 7-8.36 7-12 0-3.37-3.13-6.5-7-6.5zm0 9.5c-1.66 0-3-1.34-3-3s1.34-3 3-3 3 1.34 3 3-1.34 3-3 3z" fill="#62B6CB"/>
</svg>
"""),
          onTap: () {
            emit(InfoWindowTapped(
              count: state.count + 1,
              property: property,
            ));
          },
        ),
      );
    }
    emit(PropertyListStateLoaded(count: state.count + 1));
  }

  final List<Property> _properties = [];
  List<Property> get properties => _properties;

  final StreamController<SwipeRefreshState> _controller = StreamController<SwipeRefreshState>.broadcast();
  Stream<SwipeRefreshState> get propertyLoadingStream => _controller.stream;
  final StreamController<bool> _propertyOverlayLoadingController = StreamController<bool>.broadcast();
  Stream<bool> get propertyOverlayLoadingStream => _propertyOverlayLoadingController.stream;

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

  reloadPropertiesSessions() async {
    emit(PropertiesReloading());
    _controller.sink.add(SwipeRefreshState.loading);
    await initialize();
    _controller.sink.add(SwipeRefreshState.hidden);
  }

  Future<BitmapDescriptor> svgToBitmapDescriptor({required String svgString, int width = 92, int height = 92}) async {
    DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, "");

    final picture = svgDrawableRoot.toPicture(size: Size(width.toDouble(), height.toDouble()));
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  findAndReplaceProperty(Property property) {
    int indexOf = _properties.indexOf(property);
    _properties.removeAt(indexOf);
    _properties.insert(indexOf, Property.fromJson(property.toJson()));
    emit(PropertyListStateLoaded(count: state.count + 1));
  }
}
