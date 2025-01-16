import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wedolawns/objects/objects.dart';
import 'package:wedolawns/utils/double_utils.dart';

part 'property.g.dart';

DateFormat dateFormat = DateFormat("MMMM d, yyyy");

@JsonSerializable(explicitToJson: true)
class Property {
  @JsonKey(name: "Id")
  final String? id;
  @JsonKey(name: "Name")
  final String name;
  @JsonKey(name: "Location", fromJson: _geoPointFromJson, toJson: _geoPointToJson)
  GeoPoint location;
  @JsonKey(name: "Jobs")
  final List<Job> jobs;

  @JsonKey(name: "InProgress", defaultValue: false)
  bool inProgress;

  @JsonKey(name: "DateCreated")
  final DateTime dateCreated;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get dateCreatedString {
    return dateFormat.format(dateCreated);
  }

  @JsonKey(name: "DateFinished")
  DateTime? dateFinished;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get dateFinishedString {
    if (dateFinished == null) return "N/A";
    return dateFormat.format(dateFinished!);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get estimatedHoursString {
    double totalHours = jobs.fold(0.0, (sum, job) => sum + (job.estimatedHours ?? 0 as num));

    if (totalHours == 0) return "N/A";
    return totalHours.formatWithOptionalDecimal();
  }

  @JsonKey(name: "HoursWorked")
  double? hoursWorked;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get hoursWorkedString {
    if (hoursWorked == null) return "N/A";
    return hoursWorked!.formatWithOptionalDecimal();
  }

  @JsonKey(name: "EstimatedWoolsacks")
  final double? estimatedWoolsacks;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get estimatedWoolsacksString {
    if (estimatedWoolsacks == null) return "N/A";
    return estimatedWoolsacks!.formatWithOptionalDecimal();
  }

  @JsonKey(name: "ActualWoolsacks")
  double? actualWoolsacks;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get actualWoolsacksString {
    if (actualWoolsacks == null) return "N/A";
    return actualWoolsacks!.formatWithOptionalDecimal();
  }

  @JsonKey(name: "Difficulty")
  final int difficulty;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get difficultyString {
    return difficulty.toStringAsFixed(0);
  }

  @JsonKey(name: "Photos")
  final List<MediaItem> photos;

  @JsonKey(name: "YoutubeUrl", defaultValue: "")
  String youtubeUrl;

  String get description {
    int remainingJobs = jobs.where((e) => e.completed).length;
    return "${jobs.length} Job${jobs.length > 1 ? "s" : ""}, $remainingJobs Remaining";
  }

  String get remainingJobString {
    int remainingJobs = jobs.where((e) => !e.completed).length;
    return "$remainingJobs Remaining";
  }

  String get totalJobString {
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
    this.hoursWorked,
    this.estimatedWoolsacks,
    this.actualWoolsacks,
    this.youtubeUrl = "",
    this.inProgress = false,
  });

  factory Property.fromJson(Map<String, dynamic> json) => _$PropertyFromJson(json);

  Color get statusColor {
    if (inProgress) return Color(0x3862B6CB);
    if ((jobs.isNotEmpty && jobs.length == jobs.where((e) => e.completed).length) || dateFinished != null) {
      return Color(0xFFCBD9C3);
    }
    return Color(0x358F9563);
  }

  Color get statusIconColor {
    if (inProgress) return Color(0xFF62B6CB);
    if ((jobs.isNotEmpty && jobs.length == jobs.where((e) => e.completed).length) || dateFinished != null) {
      return Color(0xFF236002);
    }
    return Color(0xFF8F9563);
  }

  Color get remainingColor {
    if (inProgress) return Color(0xFF62B6CB);
    if ((jobs.isNotEmpty && jobs.length == jobs.where((e) => e.completed).length) || dateFinished != null) {
      return Color(0xFF236002);
    }
    return Color(0xFF8F9563);
  }

  Map<String, dynamic> toJson() => _$PropertyToJson(this);

  static GeoPoint _geoPointFromJson(Map<String, dynamic> json) => GeoPoint(json['latitude'], json['longitude']);

  static Map<String, dynamic> _geoPointToJson(GeoPoint geoPoint) => {
        'latitude': geoPoint.latitude,
        'longitude': geoPoint.longitude,
      };
}
