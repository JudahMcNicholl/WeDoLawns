// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'objects.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaItem _$MediaItemFromJson(Map<String, dynamic> json) => MediaItem(
      id: (json['Id'] as num).toInt(),
      path: json['Path'] as String,
    );

Map<String, dynamic> _$MediaItemToJson(MediaItem instance) => <String, dynamic>{
      'Id': instance.id,
      'Path': instance.path,
    };

Job _$JobFromJson(Map<String, dynamic> json) => Job(
      id: (json['Id'] as num).toInt(),
      name: json['Name'] as String,
      description: json['Description'] as String,
      tools: (json['Tools'] as List<dynamic>).map((e) => e as String).toList(),
      estimatedHours: (json['EstimatedHours'] as num?)?.toDouble(),
      actualHours: (json['ActualHours'] as num?)?.toDouble(),
      completed: json['Completed'] as bool? ?? false,
    );

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Description': instance.description,
      'Tools': instance.tools,
      'EstimatedHours': instance.estimatedHours,
      'ActualHours': instance.actualHours,
      'Completed': instance.completed,
    };

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      latitude: (json['_latitude'] as num).toDouble(),
      longitude: (json['_longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      '_latitude': instance.latitude,
      '_longitude': instance.longitude,
    };
