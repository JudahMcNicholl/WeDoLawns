import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:wedolawns/objects/objects.dart';
import 'package:json_annotation/json_annotation.dart';

part 'property.g.dart';

DateFormat dateFormat = DateFormat("MMMM d, yyyy");

@JsonSerializable(explicitToJson: true)
class Property {
  @JsonKey(name: "Id")
  final String? id;
  @JsonKey(name: "Name")
  final String name;
  @JsonKey(
      name: "Location", fromJson: _geoPointFromJson, toJson: _geoPointToJson)
  final GeoPoint location;
  @JsonKey(name: "Jobs")
  final List<Job> jobs;
  @JsonKey(name: "DateCreated")
  final DateTime dateCreated;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get dateCreatedString {
    return dateFormat.format(dateCreated);
  }

  @JsonKey(name: "DateFinished")
  final DateTime? dateFinished;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get dateFinishedString {
    if (dateFinished == null) return "N/A";
    return dateFormat.format(dateFinished!);
  }

  @JsonKey(name: "EstimatedHours")
  final double? estimatedHours;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get estimatedHoursString {
    if (estimatedHours == null) return "N/A";
    return estimatedHours!.toStringAsFixed(0);
  }

  @JsonKey(name: "HoursWorked")
  final double? hoursWorked;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get hoursWorkedString {
    if (hoursWorked == null) return "N/A";
    return hoursWorked!.toStringAsFixed(0);
  }

  @JsonKey(name: "EstimatedWoolsacks")
  final double? estimatedWoolsacks;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get estimatedWoolsacksString {
    if (estimatedWoolsacks == null) return "N/A";
    return estimatedWoolsacks!.toStringAsFixed(0);
  }

  @JsonKey(name: "ActualWoolsacks")
  final double? actualWoolsacks;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get actualWoolsacksString {
    if (actualWoolsacks == null) return "N/A";
    return actualWoolsacks!.toStringAsFixed(0);
  }

  @JsonKey(name: "Difficulty")
  final int difficulty;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get difficultyString {
    if (difficulty == null) return "N/A";
    return difficulty!.toStringAsFixed(0);
  }

  @JsonKey(name: "Photos")
  final List<MediaItem> photos;

  String get description {
    return "${jobs.length} Job${jobs.length > 1 ? "s" : ""}";
  }

  Property({
    this.id,
    required this.name,
    required this.location,
    required this.dateCreated,
    this.dateFinished,
    required this.difficulty,
    required this.photos,
    required this.jobs,
    this.estimatedHours,
    this.hoursWorked,
    this.estimatedWoolsacks,
    this.actualWoolsacks,
  });

  factory Property.fromJson(Map<String, dynamic> json) =>
      _$PropertyFromJson(json);
  Map<String, dynamic> toJson() => _$PropertyToJson(this);

  static GeoPoint _geoPointFromJson(Map<String, dynamic> json) =>
      GeoPoint(json['latitude'], json['longitude']);

  static Map<String, dynamic> _geoPointToJson(GeoPoint geoPoint) => {
        'latitude': geoPoint.latitude,
        'longitude': geoPoint.longitude,
      };
}
