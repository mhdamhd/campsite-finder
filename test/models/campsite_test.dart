import 'package:flutter_test/flutter_test.dart';
import 'package:campsite_finder/models/campsite.dart';

void main() {
  group('Campsite Model Tests', () {
    const mockCampsiteJson = {
      'id': '1',
      'label': 'Beautiful Lake Campsite',
      'photo': 'https://example.com/photo.jpg',
      'geoLocation': {
        'lat': 52520.0,
        'long': 13405.0,
      },
      'isCloseToWater': true,
      'isCampFireAllowed': false,
      'hostLanguages': ['English', 'German'],
      'pricePerNight': 2500.0,
      'suitableFor': ['families', 'couples'],
      'createdAt': '2023-01-01T00:00:00.000Z',
    };

    late Campsite testCampsite;

    setUp(() {
      testCampsite = Campsite.fromJson(mockCampsiteJson);
    });

    test('should create Campsite from JSON correctly', () {
      expect(testCampsite.id, equals('1'));
      expect(testCampsite.label, equals('Beautiful Lake Campsite'));
      expect(testCampsite.photo, equals('https://example.com/photo.jpg'));
      expect(testCampsite.isCloseToWater, isTrue);
      expect(testCampsite.isCampFireAllowed, isFalse);
      expect(testCampsite.hostLanguages, equals(['English', 'German']));
      expect(testCampsite.pricePerNight, equals(2500.0));
      expect(testCampsite.suitableFor, equals(['families', 'couples']));
    });

    test('should convert Campsite to JSON correctly', () {
      final json = testCampsite.toJson();

      expect(json['id'], equals('1'));
      expect(json['label'], equals('Beautiful Lake Campsite'));
      expect(json['isCloseToWater'], isTrue);
      expect(json['isCampFireAllowed'], isFalse);
      expect(json['hostLanguages'], equals(['English', 'German']));
      expect(json['pricePerNight'], equals(2500.0));
    });

    test('should calculate priceInEuros correctly', () {
      expect(testCampsite.priceInEuros, equals(25.0));
    });

    test('should support equality comparison', () {
      final campsite1 = Campsite.fromJson(mockCampsiteJson);
      final campsite2 = Campsite.fromJson(mockCampsiteJson);

      expect(campsite1, equals(campsite2));
    });
  });

  group('GeoLocation Tests', () {
    test('should create GeoLocation from JSON correctly', () {
      const json = {'lat': 52520.0, 'long': 13405.0};
      final geoLocation = GeoLocation.fromJson(json);

      expect(geoLocation.lat, equals(52520.0));
      expect(geoLocation.lng, equals(13405.0));
    });

    test('should calculate normalized coordinates', () {
      const geoLocation = GeoLocation(lat: 52520.0, lng: 13405.0);

      expect(geoLocation.normalizedLat, equals(52.52));
      expect(geoLocation.normalizedLng, equals(13.405));
    });

    test('should support equality comparison', () {
      const geo1 = GeoLocation(lat: 52520.0, lng: 13405.0);
      const geo2 = GeoLocation(lat: 52520.0, lng: 13405.0);

      expect(geo1, equals(geo2));
    });

    test('should convert to JSON correctly', () {
      const geoLocation = GeoLocation(lat: 52520.0, lng: 13405.0);
      final json = geoLocation.toJson();

      expect(json['lat'], equals(52520.0));
      expect(json['long'], equals(13405.0));
    });
  });

  group('CampsiteFilters Tests', () {
    late Campsite testCampsite;

    setUp(() {
      testCampsite = Campsite(
        id: '1',
        label: 'Test Campsite',
        photo: 'photo.jpg',
        geoLocation: GeoLocation(lat: 50000.0, lng: 10000.0),
        isCloseToWater: true,
        isCampFireAllowed: false,
        hostLanguages: ['English', 'German'],
        pricePerNight: 2000.0,
        suitableFor: ['families'],
        createdAt: DateTime(2023, 1, 1),
      );
    });

    test('should have no active filters by default', () {
      const filters = CampsiteFilters();

      expect(filters.hasActiveFilters, isFalse);
      expect(filters.activeFilterCount, equals(0));
    });

    test('should detect active filters correctly', () {
      const filters = CampsiteFilters(
        searchQuery: 'test',
        closeToWater: true,
        maxPrice: 50.0,
      );

      expect(filters.hasActiveFilters, isTrue);
      expect(filters.activeFilterCount, equals(3));
    });

    test('should match campsite with no filters', () {
      const filters = CampsiteFilters();

      expect(filters.matches(testCampsite), isTrue);
    });

    test('should filter by search query correctly', () {
      const matchingFilters = CampsiteFilters(searchQuery: 'test');
      const nonMatchingFilters = CampsiteFilters(searchQuery: 'beach');

      expect(matchingFilters.matches(testCampsite), isTrue);
      expect(nonMatchingFilters.matches(testCampsite), isFalse);
    });

    test('should filter by closeToWater correctly', () {
      const waterFilters = CampsiteFilters(closeToWater: true);
      const noWaterFilters = CampsiteFilters(closeToWater: false);

      expect(waterFilters.matches(testCampsite), isTrue);
      expect(noWaterFilters.matches(testCampsite), isFalse);
    });

    test('should filter by campFireAllowed correctly', () {
      const fireFilters = CampsiteFilters(campFireAllowed: false);
      const noFireFilters = CampsiteFilters(campFireAllowed: true);

      expect(fireFilters.matches(testCampsite), isTrue);
      expect(noFireFilters.matches(testCampsite), isFalse);
    });

    test('should filter by host languages correctly', () {
      const matchingLangFilters = CampsiteFilters(hostLanguages: ['English']);
      const nonMatchingLangFilters = CampsiteFilters(hostLanguages: ['French']);

      expect(matchingLangFilters.matches(testCampsite), isTrue);
      expect(nonMatchingLangFilters.matches(testCampsite), isFalse);
    });

    test('should filter by price range correctly', () {
      const validPriceFilters = CampsiteFilters(minPrice: 15.0, maxPrice: 25.0);
      const tooHighMinPrice = CampsiteFilters(minPrice: 25.0);
      const tooLowMaxPrice = CampsiteFilters(maxPrice: 15.0);

      expect(validPriceFilters.matches(testCampsite), isTrue);
      expect(tooHighMinPrice.matches(testCampsite), isFalse);
      expect(tooLowMaxPrice.matches(testCampsite), isFalse);
    });

    test('should filter by country correctly', () {
      const germanyFilters = CampsiteFilters(country: 'Germany');
      const italyFilters = CampsiteFilters(country: 'Italy');

      expect(germanyFilters.matches(testCampsite), isTrue);
      expect(italyFilters.matches(testCampsite), isFalse);
    });

    test('should copy with new values correctly', () {
      const originalFilters = CampsiteFilters(searchQuery: 'test');
      final newFilters = originalFilters.copyWith(
        closeToWater: true,
        maxPrice: 50.0,
      );

      expect(newFilters.searchQuery, equals('test'));
      expect(newFilters.closeToWater, isTrue);
      expect(newFilters.maxPrice, equals(50.0));
    });

    test('should handle complex filter combinations', () {
      const complexFilters = CampsiteFilters(
        searchQuery: 'test',
        closeToWater: true,
        campFireAllowed: false,
        hostLanguages: ['English'],
        minPrice: 15.0,
        maxPrice: 25.0,
        country: 'Germany',
      );

      expect(complexFilters.matches(testCampsite), isTrue);
      expect(complexFilters.activeFilterCount, equals(7));
    });
  });
}