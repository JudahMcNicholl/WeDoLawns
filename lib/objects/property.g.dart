// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Property _$PropertyFromJson(Map<String, dynamic> json) => Property(
      id: json['Id'] as String?,
      name: json['Name'] as String,
      location:
          Property._geoPointFromJson(json['Location'] as Map<String, dynamic>),
      dateCreated: DateTime.parse(json['DateCreated'] as String),
      dateFinished: json['DateFinished'] == null
          ? null
          : DateTime.parse(json['DateFinished'] as String),
      difficulty: (json['Difficulty'] as num).toInt(),
      photos: (json['Photos'] as List<dynamic>)
          .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      jobs: (json['Jobs'] as List<dynamic>)
          .map((e) => Job.fromJson(e as Map<String, dynamic>))
          .toList(),
      hoursWorked: (json['HoursWorked'] as num?)?.toDouble(),
      estimatedWoolsacks: (json['EstimatedWoolsacks'] as num?)?.toDouble(),
      actualWoolsacks: (json['ActualWoolsacks'] as num?)?.toDouble(),
      youtubeUrl: json['YoutubeUrl'] as String? ?? '',
      inProgress: json['InProgress'] as bool? ?? false,
    );

Map<String, dynamic> _$PropertyToJson(Property instance) => <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Location': Property._geoPointToJson(instance.location),
      'Jobs': instance.jobs.map((e) => e.toJson()).toList(),
      'InProgress': instance.inProgress,
      'DateCreated': instance.dateCreated.toIso8601String(),
      'DateFinished': instance.dateFinished?.toIso8601String(),
      'HoursWorked': instance.hoursWorked,
      'EstimatedWoolsacks': instance.estimatedWoolsacks,
      'ActualWoolsacks': instance.actualWoolsacks,
      'Difficulty': instance.difficulty,
      'Photos': instance.photos.map((e) => e.toJson()).toList(),
      'YoutubeUrl': instance.youtubeUrl,
    };
