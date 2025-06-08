
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'campsite.g.dart';

@JsonSerializable()
class Campsite extends Equatable {
  final String id;
  final String label;
  final String photo;
  final GeoLocation geoLocation;
  final String? country;
  @JsonKey(name: 'isCloseToWater')
  final bool isCloseToWater;
  @JsonKey(name: 'isCampFireAllowed')
  final bool isCampFireAllowed;
  @JsonKey(name: 'hostLanguages')
  final List<String> hostLanguages;

  final double pricePerNight;
  final List<String> suitableFor;
  final DateTime createdAt;

  const Campsite({
    required this.id,
    required this.label,
    required this.photo,
    required this.geoLocation,
    this.country,
    required this.isCloseToWater,
    required this.isCampFireAllowed,
    required this.hostLanguages,
    required this.pricePerNight,
    required this.suitableFor,
    required this.createdAt,
  });

  factory Campsite.fromJson(Map<String, dynamic> json) => _$CampsiteFromJson(json);
  Map<String, dynamic> toJson() => _$CampsiteToJson(this);

  double get priceInEuros => pricePerNight / 100;

  @override
  List<Object?> get props => [
    id,
    label,
    photo,
    geoLocation,
    country,
    isCloseToWater,
    isCampFireAllowed,
    hostLanguages,
    pricePerNight,
    suitableFor,
    createdAt,
  ];
}

@JsonSerializable()
class GeoLocation extends Equatable{
  final double lat;
  @JsonKey(name: 'long')
  final double lng;

  const GeoLocation({required this.lat, required this.lng});

  factory GeoLocation.fromJson(Map<String, dynamic> json) => _$GeoLocationFromJson(json);
  Map<String, dynamic> toJson() => _$GeoLocationToJson(this);

  @override
  // TODO: implement props
  List<Object?> get props => [lat, lng];
}
