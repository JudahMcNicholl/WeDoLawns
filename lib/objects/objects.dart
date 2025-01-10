import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'objects.g.dart';

@JsonSerializable()
class MediaItem {
  @JsonKey(name: "Id")
  final int id;
  @JsonKey(name: "Path")
  final String path;

  MediaItem({required this.id, required this.path});

  factory MediaItem.fromJson(Map<String, dynamic> json) =>
      _$MediaItemFromJson(json);
  Map<String, dynamic> toJson() => _$MediaItemToJson(this);
}

@JsonSerializable()
class Job {
  @JsonKey(name: "Id")
  final int id;
  @JsonKey(name: "Name")
  final String name;
  @JsonKey(name: "Description")
  final String description;
  @JsonKey(name: "Tools")
  final List<String> tools;

  Job({
    required this.id,
    required this.name,
    required this.description,
    required this.tools,
  });

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);
  Map<String, dynamic> toJson() => _$JobToJson(this);
}

@JsonSerializable()
class Location {
  @JsonKey(name: "_latitude")
  final double latitude;
  @JsonKey(name: "_longitude")
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
  // @JsonKey(fromJson: _fromGeoPoint, toJson: _toGeoPoint)
  // final GeoPoint geoPoint;

  // Location({required this.geoPoint});

  // factory Location.fromJson(Map<String, dynamic> json) =>
  //     _$LocationFromJson(json);

  // Map<String, dynamic> toJson() => _$LocationToJson(this);

  // // Custom conversion methods for GeoPoint
  // static GeoPoint _fromGeoPoint(Map<String, dynamic> json) =>
  //     GeoPoint(json['Latitude'], json['Longitude']);

  // static Map<String, dynamic> _toGeoPoint(GeoPoint geoPoint) => {
  //       'Latitude': geoPoint.latitude,
  //       'Longitude': geoPoint.longitude,
  //     };
}
