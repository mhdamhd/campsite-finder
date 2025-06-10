import 'package:campsite_finder/models/campsite.dart';
import 'package:campsite_finder/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final campsitesProvider = FutureProvider<List<Campsite>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getCampsites();
});


// Provider for campsite filters
final filtersProvider = StateNotifierProvider<FiltersNotifier, CampsiteFilters>((ref) {
  return FiltersNotifier();
});

class FiltersNotifier extends StateNotifier<CampsiteFilters> {
  FiltersNotifier() : super(const CampsiteFilters());

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.isEmpty ? null : query);
  }

  void updateCloseToWater(bool? value) {
    state = state.copyWith(closeToWater: value);
  }

  void updateCampFireAllowed(bool? value) {
    state = state.copyWith(campFireAllowed: value);
  }

  void updateHostLanguages(List<String>? languages) {
    state = state.copyWith(hostLanguages: languages?.isEmpty == true ? null : languages);
  }

  void updatePriceRange(double? minPrice, double? maxPrice) {
    state = state.copyWith(minPrice: minPrice, maxPrice: maxPrice);
  }

  void updateCountry(String? country) {
    state = state.copyWith(country: country?.isEmpty == true ? null : country);
  }

  void clearFilters() {
    state = const CampsiteFilters();
  }

  void clearFilter(String filterType) {
    switch (filterType) {
      case 'search':
        state = state.copyWith(searchQuery: null);
        break;
      case 'water':
        state = state.copyWith(closeToWater: null);
        break;
      case 'fire':
        state = state.copyWith(campFireAllowed: null);
        break;
      case 'languages':
        state = state.copyWith(hostLanguages: null);
        break;
      case 'price':
        state = state.copyWith(minPrice: null, maxPrice: null);
        break;
      case 'country':
        state = state.copyWith(country: null);
        break;
    }
  }
}

// Provider for filtered and sorted campsites
final filteredCampsitesProvider = Provider<AsyncValue<List<Campsite>>>((ref) {
  final campsitesAsync = ref.watch(campsitesProvider);
  final filters = ref.watch(filtersProvider);

  return campsitesAsync.when(
    data: (campsites) {
      var filtered = campsites.where((campsite) => filters.matches(campsite)).toList();

      // Sort by name (label)
      filtered.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Provider for getting a single campsite by ID
final campsiteByIdProvider = Provider.family<AsyncValue<Campsite?>, String>((ref, id) {
  final campsitesAsync = ref.watch(campsitesProvider);

  return campsitesAsync.when(
    data: (campsites) {
      final campsite = campsites.cast<Campsite?>().firstWhere(
            (c) => c?.id == id,
        orElse: () => null,
      );
      return AsyncValue.data(campsite);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Provider for available countries
final availableCountriesProvider = Provider<List<String>>((ref) {
  final campsitesAsync = ref.watch(campsitesProvider);

  return campsitesAsync.when(
    data: (campsites) {
      final countries = campsites.map((c) => c.country).whereType<String>().toSet().toList();
      countries.sort();
      return countries;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider for available languages
final availableLanguagesProvider = Provider<List<String>>((ref) {
  final campsitesAsync = ref.watch(campsitesProvider);

  return campsitesAsync.when(
    data: (campsites) {
      final languages = <String>{};
      for (final campsite in campsites) {
        languages.addAll(campsite.hostLanguages);
      }
      final sortedLanguages = languages.toList()..sort();
      return sortedLanguages;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider for price range statistics
final priceRangeProvider = Provider<PriceRange?>((ref) {
  final campsitesAsync = ref.watch(campsitesProvider);

  return campsitesAsync.when(
    data: (campsites) {
      if (campsites.isEmpty) return null;

      final prices = campsites.map((c) => c.priceInEuros).toList()..sort();
      return PriceRange(
        min: prices.first,
        max: prices.last,
        average: prices.reduce((a, b) => a + b) / prices.length,
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

class PriceRange {
  final double min;
  final double max;
  final double average;

  const PriceRange({
    required this.min,
    required this.max,
    required this.average,
  });
}