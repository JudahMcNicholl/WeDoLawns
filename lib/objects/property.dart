import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wedolawns/objects/objects.dart';
import 'package:wedolawns/utils/constants.dart';
import 'package:wedolawns/utils/double_utils.dart';

part 'property.g.dart';

DateFormat dateFormat = DateFormat("yy.MM.dd");
NumberFormat currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

@JsonSerializable(explicitToJson: true)
class Property {
  @JsonKey(name: "Id")
  final String? id;
  @JsonKey(name: "Name")
  final String name;
  @JsonKey(name: "ContactName", defaultValue: "")
  final String contactName;
  @JsonKey(name: "ContactPhoneNumber", defaultValue: "")
  final String contactPhoneNumber;
  @JsonKey(name: "TotalCost", defaultValue: 0.0)
  final double totalCost;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get totalCostString {
    return currencyFormat.format(totalCost);
  }

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

    if (totalHours == 0) return "-";
    return totalHours.formatWithOptionalDecimal();
  }

  @JsonKey(name: "HoursWorked")
  double? hoursWorked;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get hoursWorkedString {
    if (hoursWorked == null) return "-";
    return hoursWorked!.formatWithOptionalDecimal();
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get hoursConcatenatedString {
    return "$estimatedHoursString/$hoursWorkedString";
  }

  @JsonKey(name: "EstimatedWoolsacks")
  final double? estimatedWoolsacks;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get estimatedWoolsacksString {
    if (estimatedWoolsacks == null) return "-";
    return estimatedWoolsacks!.formatWithOptionalDecimal();
  }

  @JsonKey(name: "ActualWoolsacks")
  double? actualWoolsacks;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get actualWoolsacksString {
    if (actualWoolsacks == null) return "-";
    return actualWoolsacks!.formatWithOptionalDecimal();
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get woolsacksConcatenatedString {
    return "$estimatedWoolsacksString/$actualWoolsacksString";
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
    this.contactName = "",
    this.contactPhoneNumber = "",
    this.totalCost = 0.0,
  });

  factory Property.fromJson(Map<String, dynamic> json) => _$PropertyFromJson(json);

  bool get isNew => !isInProgress && !isComplete;
  bool get isInProgress => inProgress;
  bool get isComplete => (jobs.isNotEmpty && jobs.length == jobs.where((e) => e.completed).length) || dateFinished != null;

  Color get statusColor {
    if (isInProgress) return inProgressColorOpaque;
    if (isComplete) {
      return isCompletedColorOpaque;
    }
    return isNewColorOpaque;
  }

  Color get statusIconColor {
    if (isInProgress) return inProgressColor;
    if (isComplete) {
      return isCompletedColor;
    }
    return isNewColor;
  }

  Color get remainingColor {
    if (isInProgress) return inProgressColor;
    if (isComplete) {
      return isCompletedColor;
    }
    return isNewColor;
  }

  Map<String, dynamic> toJson() => _$PropertyToJson(this);

  static GeoPoint _geoPointFromJson(Map<String, dynamic> json) => GeoPoint(json['latitude'], json['longitude']);

  static Map<String, dynamic> _geoPointToJson(GeoPoint geoPoint) => {
        'latitude': geoPoint.latitude,
        'longitude': geoPoint.longitude,
      };
}
