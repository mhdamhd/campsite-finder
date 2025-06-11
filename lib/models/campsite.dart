
import 'package:campsite_finder/core/utils/extensions.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:math';

part 'campsite.g.dart';


final _random = Random();

@JsonSerializable()
class Campsite extends Equatable {
  final String id;
  final String label;
  final String photo;
  final GeoLocation geoLocation;
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

  String get country => geoLocation.country;


  @override
  List<Object?> get props => [
    id,
    label,
    photo,
    geoLocation,
    isCloseToWater,
    isCampFireAllowed,
    hostLanguages,
    pricePerNight,
    suitableFor,
    createdAt,
  ];
}

class GeoLocation extends Equatable{
  final double lat;
  @JsonKey(name: 'long')
  final double lng;

  const GeoLocation({required this.lat, required this.lng});

  /// Factory to generate a random GeoLocation inside Europe
  factory GeoLocation.random() {
    final lat = 35 + _random.nextDouble() * (70 - 35); // 35 to 70 N
    final lng = -10 + _random.nextDouble() * (30 - (-10)); // -10 to 30 E
    return GeoLocation(lat: lat, lng: lng);
  }

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation.random(); // Always use random lat/lng
  }

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'long': lng,
  };

  /// Normalized latitude
  double get normalizedLat => lat;

  /// Normalized longitude
  double get normalizedLng => lng;

  @override
  // TODO: implement props
  List<Object?> get props => [lat, lng];
}


class CampsiteFilters {
  final String? searchQuery;
  final bool? closeToWater;
  final bool? campFireAllowed;
  final List<String>? hostLanguages;
  final double? maxPrice;
  final double? minPrice;
  final String? country;

  const CampsiteFilters({
    this.searchQuery,
    this.closeToWater,
    this.campFireAllowed,
    this.hostLanguages,
    this.maxPrice,
    this.minPrice,
    this.country,
  });

  static const _undefined = Object();

  CampsiteFilters copyWith({
    Object? searchQuery = _undefined,
    Object? closeToWater = _undefined,
    Object? campFireAllowed = _undefined,
    Object? hostLanguages = _undefined,
    Object? maxPrice = _undefined,
    Object? minPrice = _undefined,
    Object? country = _undefined,
  }) {
    return CampsiteFilters(
      searchQuery: searchQuery == _undefined ? this.searchQuery : searchQuery as String?,
      closeToWater: closeToWater == _undefined ? this.closeToWater : closeToWater as bool?,
      campFireAllowed: campFireAllowed == _undefined ? this.campFireAllowed : campFireAllowed as bool?,
      hostLanguages: hostLanguages == _undefined ? this.hostLanguages : hostLanguages as List<String>?,
      maxPrice: maxPrice == _undefined ? this.maxPrice : maxPrice as double?,
      minPrice: minPrice == _undefined ? this.minPrice : minPrice as double?,
      country: country == _undefined ? this.country : country as String?,
    );
  }

  bool get hasActiveFilters =>
      searchQuery?.isNotEmpty == true ||
          closeToWater != null ||
          campFireAllowed != null ||
          hostLanguages?.isNotEmpty == true ||
          maxPrice != null ||
          minPrice != null ||
          country?.isNotEmpty == true;

  int get activeFilterCount {
    int count = 0;
    if (searchQuery?.isNotEmpty == true) count++;
    if (closeToWater != null) count++;
    if (campFireAllowed != null) count++;
    if (hostLanguages?.isNotEmpty == true) count++;
    if (maxPrice != null) count++;
    if (minPrice != null) count++;
    if (country?.isNotEmpty == true) count++;
    return count;
  }

  bool matches(Campsite campsite) {
    if (searchQuery?.isNotEmpty == true) {
      final query = searchQuery!.toLowerCase();
      if (!campsite.label.toLowerCase().contains(query) &&
          !campsite.country.toLowerCase().contains(query)) {
        return false;
      }
    }

    if (closeToWater != null && campsite.isCloseToWater != closeToWater) {
      return false;
    }

    if (campFireAllowed != null && campsite.isCampFireAllowed != campFireAllowed) {
      return false;
    }

    if (hostLanguages?.isNotEmpty == true) {
      final hasMatchingLanguage = hostLanguages!.any(
            (lang) => campsite.hostLanguages.contains(lang),
      );
      if (!hasMatchingLanguage) return false;
    }

    if (minPrice != null && campsite.priceInEuros < minPrice!) {
      return false;
    }

    if (maxPrice != null && campsite.priceInEuros > maxPrice!) {
      return false;
    }

    if (country?.isNotEmpty == true && campsite.country != country) {
      return false;
    }

    return true;
  }
}