// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campsite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Campsite _$CampsiteFromJson(Map<String, dynamic> json) => Campsite(
  id: json['id'] as String,
  label: json['label'] as String,
  photo: json['photo'] as String,
  geoLocation: GeoLocation.fromJson(
    json['geoLocation'] as Map<String, dynamic>,
  ),
  isCloseToWater: json['isCloseToWater'] as bool,
  isCampFireAllowed: json['isCampFireAllowed'] as bool,
  hostLanguages: (json['hostLanguages'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  pricePerNight: (json['pricePerNight'] as num).toDouble(),
  suitableFor: (json['suitableFor'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CampsiteToJson(Campsite instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'photo': instance.photo,
  'geoLocation': instance.geoLocation,
  'isCloseToWater': instance.isCloseToWater,
  'isCampFireAllowed': instance.isCampFireAllowed,
  'hostLanguages': instance.hostLanguages,
  'pricePerNight': instance.pricePerNight,
  'suitableFor': instance.suitableFor,
  'createdAt': instance.createdAt.toIso8601String(),
};

GeoLocation _$GeoLocationFromJson(Map<String, dynamic> json) => GeoLocation(
  lat: (json['lat'] as num).toDouble(),
  lng: (json['long'] as num).toDouble(),
);

Map<String, dynamic> _$GeoLocationToJson(GeoLocation instance) =>
    <String, dynamic>{'lat': instance.lat, 'long': instance.lng};
