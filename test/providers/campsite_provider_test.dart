import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:campsite_finder/models/campsite.dart';
import 'package:campsite_finder/providers/campsite_provider.dart';
import 'package:campsite_finder/services/api_service.dart';

// Generate mocks
@GenerateMocks([ApiService])
import 'campsite_provider_test.mocks.dart';

void main() {
  group('FiltersNotifier Tests', () {
    late ProviderContainer container;
    late FiltersNotifier filtersNotifier;

    setUp(() {
      container = ProviderContainer();
      filtersNotifier = container.read(filtersProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('should have empty filters by default', () {
      final filters = container.read(filtersProvider);

      expect(filters.searchQuery, isNull);
      expect(filters.closeToWater, isNull);
      expect(filters.campFireAllowed, isNull);
      expect(filters.hostLanguages, isNull);
      expect(filters.minPrice, isNull);
      expect(filters.maxPrice, isNull);
      expect(filters.country, isNull);
      expect(filters.hasActiveFilters, isFalse);
      expect(filters.activeFilterCount, equals(0));
    });

    test('should update search query correctly', () {
      filtersNotifier.updateSearchQuery('test query');

      final filters = container.read(filtersProvider);
      expect(filters.searchQuery, equals('test query'));
      expect(filters.hasActiveFilters, isTrue);
      expect(filters.activeFilterCount, equals(1));
    });

    test('should update closeToWater filter correctly', () {
      filtersNotifier.updateCloseToWater(true);

      final filters = container.read(filtersProvider);
      expect(filters.closeToWater, isTrue);
      expect(filters.hasActiveFilters, isTrue);
      expect(filters.activeFilterCount, equals(1));
    });

    test('should update campFireAllowed filter correctly', () {
      filtersNotifier.updateCampFireAllowed(false);

      final filters = container.read(filtersProvider);
      expect(filters.campFireAllowed, isFalse);
      expect(filters.hasActiveFilters, isTrue);
      expect(filters.activeFilterCount, equals(1));
    });

    test('should update host languages correctly', () {
      const languages = ['English', 'German'];
      filtersNotifier.updateHostLanguages(languages);

      final filters = container.read(filtersProvider);
      expect(filters.hostLanguages, equals(languages));
      expect(filters.hasActiveFilters, isTrue);
      expect(filters.activeFilterCount, equals(1));
    });

    test('should update price range correctly', () {
      filtersNotifier.updatePriceRange(10.0, 50.0);

      final filters = container.read(filtersProvider);
      expect(filters.minPrice, equals(10.0));
      expect(filters.maxPrice, equals(50.0));
      expect(filters.hasActiveFilters, isTrue);
      expect(filters.activeFilterCount, equals(2));
    });

    test('should update country correctly', () {
      filtersNotifier.updateCountry('Germany');

      final filters = container.read(filtersProvider);
      expect(filters.country, equals('Germany'));
      expect(filters.hasActiveFilters, isTrue);
      expect(filters.activeFilterCount, equals(1));
    });

    test('should clear all filters', () {
      // Set multiple filters
      filtersNotifier.updateSearchQuery('test');
      filtersNotifier.updateCloseToWater(true);
      filtersNotifier.updateCampFireAllowed(false);
      filtersNotifier.updateHostLanguages(['English']);
      filtersNotifier.updatePriceRange(10.0, 50.0);
      filtersNotifier.updateCountry('Germany');

      // Verify filters are set
      var filters = container.read(filtersProvider);
      expect(filters.hasActiveFilters, isTrue);
      expect(filters.activeFilterCount, equals(7));

      // Clear all filters
      filtersNotifier.clearFilters();

      // Verify filters are cleared
      filters = container.read(filtersProvider);
      expect(filters.searchQuery, isNull);
      expect(filters.closeToWater, isNull);
      expect(filters.campFireAllowed, isNull);
      expect(filters.hostLanguages, isNull);
      expect(filters.minPrice, isNull);
      expect(filters.maxPrice, isNull);
      expect(filters.country, isNull);
      expect(filters.hasActiveFilters, isFalse);
      expect(filters.activeFilterCount, equals(0));
    });
  });

  group('Campsite Providers Tests', () {
    late ProviderContainer container;
    late MockApiService mockApiService;

    final testCampsites = [
      Campsite(
        id: '1',
        label: 'Lake Campsite',
        photo: 'photo1.jpg',
        geoLocation: GeoLocation(lat: 50000.0, lng: 10000.0),
        isCloseToWater: true,
        isCampFireAllowed: false,
        hostLanguages: ['English', 'German'],
        pricePerNight: 2000.0,
        suitableFor: ['families'],
        createdAt: DateTime(2023, 1, 1),
      ),
      Campsite(
        id: '2',
        label: 'Mountain View',
        photo: 'photo2.jpg',
        geoLocation: GeoLocation(lat: 40000.0, lng: 10000.0),
        isCloseToWater: false,
        isCampFireAllowed: true,
        hostLanguages: ['German', 'French'],
        pricePerNight: 3000.0,
        suitableFor: ['couples'],
        createdAt: DateTime(2023, 1, 2),
      ),
      Campsite(
        id: '3',
        label: 'Beach Paradise',
        photo: 'photo3.jpg',
        geoLocation: GeoLocation(lat: 60000.0, lng: 20000.0),
        isCloseToWater: true,
        isCampFireAllowed: true,
        hostLanguages: ['English'],
        pricePerNight: 4000.0,
        suitableFor: ['families', 'couples'],
        createdAt: DateTime(2023, 1, 3),
      ),
    ];

    setUp(() {
      mockApiService = MockApiService();
      container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApiService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('campsitesProvider', () {
      test('should return campsites on successful API call', () async {
        // Arrange
        when(mockApiService.getCampsites()).thenAnswer((_) async => testCampsites);

        // Act
        final result = await container.read(campsitesProvider.future);

        // Assert
        expect(result, equals(testCampsites));
        verify(mockApiService.getCampsites()).called(1);
      });

      test('should handle API errors', () async {
        // Arrange
        const apiException = ApiException('Network error', 500);
        when(mockApiService.getCampsites()).thenThrow(apiException);

        // Act & Assert
        expect(
              () async => await container.read(campsitesProvider.future),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('filteredCampsitesProvider', () {
      setUp(() {
        when(mockApiService.getCampsites()).thenAnswer((_) async => testCampsites);
      });

      test('should return all campsites when no filters are applied', () async {
        // Act
        final asyncValue = container.read(filteredCampsitesProvider);

        // Wait for the async value to resolve
        await container.read(campsitesProvider.future);
        final result = container.read(filteredCampsitesProvider);

        // Assert
        expect(result.hasValue, isTrue);
        final campsites = result.value!;
        expect(campsites.length, equals(3));
        // Should be sorted by name
        expect(campsites[0].label, equals('Beach Paradise'));
        expect(campsites[1].label, equals('Lake Campsite'));
        expect(campsites[2].label, equals('Mountain View'));
      });

      test('should filter by search query', () async {
        // Arrange
        container.read(filtersProvider.notifier).updateSearchQuery('Lake');

        // Wait for campsites to load first
        await container.read(campsitesProvider.future);

        // Act
        final result = container.read(filteredCampsitesProvider);

        // Assert
        expect(result.hasValue, isTrue);
        final campsites = result.value!;
        expect(campsites.length, equals(1));
        expect(campsites[0].label, equals('Lake Campsite'));
      });

      test('should filter by closeToWater', () async {
        // Arrange
        container.read(filtersProvider.notifier).updateCloseToWater(true);

        // Wait for campsites to load first
        await container.read(campsitesProvider.future);

        // Act
        final result = container.read(filteredCampsitesProvider);

        // Assert
        expect(result.hasValue, isTrue);
        final campsites = result.value!;
        expect(campsites.length, equals(2));
        expect(campsites.every((c) => c.isCloseToWater), isTrue);
      });

      test('should filter by campFireAllowed', () async {
        // Arrange
        container.read(filtersProvider.notifier).updateCampFireAllowed(true);

        // Wait for campsites to load first
        await container.read(campsitesProvider.future);

        // Act
        final result = container.read(filteredCampsitesProvider);

        // Assert
        expect(result.hasValue, isTrue);
        final campsites = result.value!;
        expect(campsites.length, equals(2));
        expect(campsites.every((c) => c.isCampFireAllowed), isTrue);
      });

      test('should filter by host languages', () async {
        // Arrange
        container.read(filtersProvider.notifier).updateHostLanguages(['French']);

        // Wait for campsites to load first
        await container.read(campsitesProvider.future);

        // Act
        final result = container.read(filteredCampsitesProvider);

        // Assert
        expect(result.hasValue, isTrue);
        final campsites = result.value!;
        expect(campsites.length, equals(1));
        expect(campsites[0].label, equals('Mountain View'));
      });

      test('should filter by price range', () async {
        // Arrange
        container.read(filtersProvider.notifier).updatePriceRange(25.0, 35.0);

        // Wait for campsites to load first
        await container.read(campsitesProvider.future);

        // Act
        final result = container.read(filteredCampsitesProvider);

        // Assert
        expect(result.hasValue, isTrue);
        final campsites = result.value!;
        expect(campsites.length, equals(1));
        expect(campsites[0].label, equals('Mountain View'));
      });

      test('should filter by country', () async {
        // Arrange
        container.read(filtersProvider.notifier).updateCountry('Italy');

        // Wait for campsites to load first
        await container.read(campsitesProvider.future);

        // Act
        final result = container.read(filteredCampsitesProvider);

        // Assert
        expect(result.hasValue, isTrue);
        final campsites = result.value!;
        expect(campsites.length, equals(1));
        expect(campsites[0].label, equals('Mountain View'));
      });

      test('should handle multiple filters', () async {
        // Arrange
        container.read(filtersProvider.notifier).updateCloseToWater(true);
        container.read(filtersProvider.notifier).updateCampFireAllowed(true);

        // Wait for campsites to load first
        await container.read(campsitesProvider.future);

        // Act
        final result = container.read(filteredCampsitesProvider);

        // Assert
        expect(result.hasValue, isTrue);
        final campsites = result.value!;
        expect(campsites.length, equals(1));
        expect(campsites[0].label, equals('Beach Paradise'));
      });

      test('should return empty list when no campsites match filters', () async {
        // Arrange
        container.read(filtersProvider.notifier).updateSearchQuery('NonExistent');

        // Wait for campsites to load first
        await container.read(campsitesProvider.future);

        // Act
        final result = container.read(filteredCampsitesProvider);

        // Assert
        expect(result.hasValue, isTrue);
        final campsites = result.value!;
        expect(campsites.length, equals(0));
      });

      test('should handle loading state', () {
        // Arrange
        when(mockApiService.getCampsites()).thenAnswer(
              (_) => Future.delayed(const Duration(seconds: 1), () => testCampsites),
        );

        // Act
        final asyncValue = container.read(filteredCampsitesProvider);

        // Assert
        expect(asyncValue.isLoading, isTrue);
      });

    });

    group('campsiteByIdProvider', () {
      setUp(() {
        when(mockApiService.getCampsites()).thenAnswer((_) async => testCampsites);
      });

      test('should return campsite with matching ID', () async {
        // Wait for campsites to load first
        await container.read(campsitesProvider.future);

        // Act
        final asyncValue = container.read(campsiteByIdProvider('1'));

        // Assert
        expect(asyncValue.hasValue, isTrue);
        final result = asyncValue.value;
        expect(result, isNotNull);
        expect(result!.id, equals('1'));
        expect(result.label, equals('Lake Campsite'));
      });

      test('should return null for non-existent ID', () async {
        // Wait for campsites to load first
        await container.read(campsitesProvider.future);

        // Act
        final asyncValue = container.read(campsiteByIdProvider('999'));

        // Assert
        expect(asyncValue.hasValue, isTrue);
        final result = asyncValue.value;
        expect(result, isNull);
      });

    });

    test('should return all campsites when no filters are applied', () async {

      when(mockApiService.getCampsites()).thenAnswer((_) async => testCampsites);


      // Act
      final asyncValue = container.read(filteredCampsitesProvider);

      // Wait for the async value to resolve
      await container.read(campsitesProvider.future);
      final result = container.read(filteredCampsitesProvider);

      // Assert
      expect(result.hasValue, isTrue);
      final campsites = result.value!;
      expect(campsites.length, equals(3));
      // Should be sorted by name
      expect(campsites[0].label, equals('Beach Paradise'));
      expect(campsites[1].label, equals('Lake Campsite'));
      expect(campsites[2].label, equals('Mountain View'));
    });

    test('should filter by search query', () async {
      when(mockApiService.getCampsites()).thenAnswer((_) async => testCampsites);
      // Arrange
      container.read(filtersProvider.notifier).updateSearchQuery('Lake');

      // Wait for campsites to load first
      await container.read(campsitesProvider.future);

      // Act
      final result = container.read(filteredCampsitesProvider);

      // Assert
      expect(result.hasValue, isTrue);
      final campsites = result.value!;
      expect(campsites.length, equals(1));
      expect(campsites[0].label, equals('Lake Campsite'));
    });

    test('should filter by closeToWater', () async {
      when(mockApiService.getCampsites()).thenAnswer((_) async => testCampsites);
      // Arrange
      container.read(filtersProvider.notifier).updateCloseToWater(true);

      // Wait for campsites to load first
      await container.read(campsitesProvider.future);

      // Act
      final result = container.read(filteredCampsitesProvider);

      // Assert
      expect(result.hasValue, isTrue);
      final campsites = result.value!;
      expect(campsites.length, equals(2));
      expect(campsites.every((c) => c.isCloseToWater), isTrue);
    });

    test('should filter by campFireAllowed', () async {
      when(mockApiService.getCampsites()).thenAnswer((_) async => testCampsites);
      // Arrange
      container.read(filtersProvider.notifier).updateCampFireAllowed(true);

      // Wait for campsites to load first
      await container.read(campsitesProvider.future);

      // Act
      final result = container.read(filteredCampsitesProvider);

      // Assert
      expect(result.hasValue, isTrue);
      final campsites = result.value!;
      expect(campsites.length, equals(2));
      expect(campsites.every((c) => c.isCampFireAllowed), isTrue);
    });

    test('should filter by host languages', () async {
      when(mockApiService.getCampsites()).thenAnswer((_) async => testCampsites);
      // Arrange
      container.read(filtersProvider.notifier).updateHostLanguages(['French']);

      // Wait for campsites to load first
      await container.read(campsitesProvider.future);

      // Act
      final result = container.read(filteredCampsitesProvider);

      // Assert
      expect(result.hasValue, isTrue);
      final campsites = result.value!;
      expect(campsites.length, equals(1));
      expect(campsites[0].label, equals('Mountain View'));
    });

    test('should filter by price range', () async {
      when(mockApiService.getCampsites()).thenAnswer((_) async => testCampsites);
      // Arrange
      container.read(filtersProvider.notifier).updatePriceRange(25.0, 35.0);

      // Wait for campsites to load first
      await container.read(campsitesProvider.future);

      // Act
      final result = container.read(filteredCampsitesProvider);

      // Assert
      expect(result.hasValue, isTrue);
      final campsites = result.value!;
      expect(campsites.length, equals(1));
      expect(campsites[0].label, equals('Mountain View'));
    });

    test('should filter by country', () async {
      when(mockApiService.getCampsites()).thenAnswer((_) async => testCampsites);
      // Arrange
      container.read(filtersProvider.notifier).updateCountry('Italy');

      // Wait for campsites to load first
      await container.read(campsitesProvider.future);

      // Act
      final result = container.read(filteredCampsitesProvider);

      // Assert
      expect(result.hasValue, isTrue);
      final campsites = result.value!;
      expect(campsites.length, equals(1));
      expect(campsites[0].label, equals('Mountain View'));
    });

    test('should handle multiple filters', () async {
      when(mockApiService.getCampsites()).thenAnswer((_) async => testCampsites);
      // Arrange
      container.read(filtersProvider.notifier).updateCloseToWater(true);
      container.read(filtersProvider.notifier).updateCampFireAllowed(true);

      // Wait for campsites to load first
      await container.read(campsitesProvider.future);

      // Act
      final result = container.read(filteredCampsitesProvider);

      // Assert
      expect(result.hasValue, isTrue);
      final campsites = result.value!;
      expect(campsites.length, equals(1));
      expect(campsites[0].label, equals('Beach Paradise'));
    });

    test('should return empty list when no campsites match filters', () async {
      when(mockApiService.getCampsites()).thenAnswer((_) async => testCampsites);
      // Arrange
      container.read(filtersProvider.notifier).updateSearchQuery('NonExistent');

      // Wait for campsites to load first
      await container.read(campsitesProvider.future);

      // Act
      final result = container.read(filteredCampsitesProvider);

      // Assert
      expect(result.hasValue, isTrue);
      final campsites = result.value!;
      expect(campsites.length, equals(0));
    });

    test('should handle loading state', () {
      // Arrange
      when(mockApiService.getCampsites()).thenAnswer(
            (_) => Future.delayed(const Duration(seconds: 1), () => testCampsites),
      );

      // Act
      final asyncValue = container.read(filteredCampsitesProvider);

      // Assert
      expect(asyncValue.isLoading, isTrue);
    });


    group('availableCountriesProvider', () {
      setUp(() {
        when(mockApiService.getCampsites()).thenAnswer((_) async => testCampsites);
      });

      test('should return sorted list of unique countries', () async {
        // Wait for campsites to be fetched
        await container.read(campsitesProvider.future);
        // Act
        final result = container.read(availableCountriesProvider);

        // Assert
        expect(result, equals(['Germany', 'Italy', 'Other']));
      });

      test('should return empty list on API error', () {
        // Arrange
        when(mockApiService.getCampsites()).thenThrow(const ApiException('Error', 500));

        // Act
        final result = container.read(availableCountriesProvider);

        // Assert
        expect(result, equals([]));
      });
    });
    //
    group('availableLanguagesProvider', () {
      setUp(() {
        when(mockApiService.getCampsites()).thenAnswer((_) async => testCampsites);
      });

      test('should return sorted list of unique languages', () async {
        // Wait for campsites to be fetched
        await container.read(campsitesProvider.future);
        // Act
        final result = container.read(availableLanguagesProvider);

        // Assert
        expect(result, equals(['English', 'French', 'German']));
      });

      test('should return empty list on API error', () {
        // Arrange
        when(mockApiService.getCampsites()).thenThrow(const ApiException('Error', 500));

        // Act
        final result = container.read(availableLanguagesProvider);

        // Assert
        expect(result, equals([]));
      });
    });
    //
    group('priceRangeProvider', () {
      setUp(() {
        when(mockApiService.getCampsites()).thenAnswer((_) async => testCampsites);
      });

      test('should return correct price range statistics', () async {
        // Wait for campsites to be fetched
        await container.read(campsitesProvider.future);
        // Act
        final result = container.read(priceRangeProvider);

        // Assert
        expect(result, isNotNull);
        expect(result!.min, equals(20.0));
        expect(result.max, equals(40.0));
        expect(result.average, equals(30.0));
      });

      test('should return null for empty campsites list', () {
        // Arrange
        when(mockApiService.getCampsites()).thenAnswer((_) async => []);

        // Act
        final result = container.read(priceRangeProvider);

        // Assert
        expect(result, isNull);
      });

      test('should return null on API error', () {
        // Arrange
        when(mockApiService.getCampsites()).thenThrow(const ApiException('Error', 500));

        // Act
        final result = container.read(priceRangeProvider);

        // Assert
        expect(result, isNull);
      });
    });
  });

  group('PriceRange Tests', () {
    test('should create PriceRange with correct values', () {
      const priceRange = PriceRange(min: 10.0, max: 50.0, average: 25.0);

      expect(priceRange.min, equals(10.0));
      expect(priceRange.max, equals(50.0));
      expect(priceRange.average, equals(25.0));
    });
  });
}