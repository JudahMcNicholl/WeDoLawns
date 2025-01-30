import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'objects.g.dart';

@JsonSerializable()
class MediaItem {
  @JsonKey(name: "Id")
  final int id;
  @JsonKey(name: "Path") //https://drive.google.com/drive/folders/1e3w96UxWVK_Sdbc19MAV5UoaF4ZURi98?usp=share_link
  String path;

  @JsonKey(name: "AndroidPath", defaultValue: "")
  String androidPath;

  String get pathByPlatform {
    if (Platform.isIOS) {
      if (path.isNotEmpty) return path;
      return androidPath;
    } else {
      if (androidPath.isNotEmpty) return androidPath;
      return path;
    }
  }

  MediaItem({
    required this.id,
    required this.path,
    this.androidPath = "",
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) => _$MediaItemFromJson(json);
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
  @JsonKey(name: "EstimatedHours")
  final double? estimatedHours;
  @JsonKey(name: "ActualHours")
  double? actualHours;
  @JsonKey(name: "Completed", defaultValue: false)
  bool completed;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get estimatedHoursString {
    if (estimatedHours == null) return "N/A";
    if (estimatedHours! % 1 == 0) {
      return estimatedHours!.toStringAsFixed(0); // No decimals for whole numbers
    }

    // Return the number as is (with decimals) for non-whole numbers
    return estimatedHours.toString();
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  String get actualHoursString {
    if (actualHours == null) return "-";
    if (actualHours! % 1 == 0) {
      return actualHours!.toStringAsFixed(0); // No decimals for whole numbers
    }

    // Return the number as is (with decimals) for non-whole numbers
    return actualHours.toString();
  }

  Job({
    required this.id,
    required this.name,
    required this.description,
    required this.tools,
    required this.estimatedHours,
    this.actualHours,
    this.completed = false,
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

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
