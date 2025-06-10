import 'package:campsite_finder/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_constants.dart';
import '../../models/campsite.dart';
import '../../providers/campsite_provider.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Local state for filters (to allow cancel functionality)
  String? _searchQuery;
  bool? _closeToWater;
  bool? _campFireAllowed;
  List<String>? _hostLanguages;
  double? _minPrice;
  double? _maxPrice;
  String? _selectedCountry;

  RangeValues? _priceRange;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Initialize with current filter values
    final currentFilters = ref.read(filtersProvider);
    _initializeWithCurrentFilters(currentFilters);

    _animationController.forward();
  }

  void _initializeWithCurrentFilters(CampsiteFilters filters) {
    _searchQuery = filters.searchQuery;
    _closeToWater = filters.closeToWater;
    _campFireAllowed = filters.campFireAllowed;
    _hostLanguages = filters.hostLanguages?.toList();
    _minPrice = filters.minPrice;
    _maxPrice = filters.maxPrice;
    _selectedCountry = filters.country;

    // Initialize price range
    if (_minPrice != null || _maxPrice != null) {
      final priceStats = ref.read(priceRangeProvider);
      if (priceStats != null) {
        _priceRange = RangeValues(
          _minPrice ?? priceStats.min,
          _maxPrice ?? priceStats.max,
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filtersNotifier = ref.read(filtersProvider.notifier);

    filtersNotifier.updateSearchQuery(_searchQuery ?? '');
    filtersNotifier.updateCloseToWater(_closeToWater);
    filtersNotifier.updateCampFireAllowed(_campFireAllowed);
    filtersNotifier.updateHostLanguages(_hostLanguages);
    filtersNotifier.updateCountry(_selectedCountry);

    if (_priceRange != null) {
      filtersNotifier.updatePriceRange(_priceRange!.start, _priceRange!.end);
    } else {
      filtersNotifier.updatePriceRange(null, null);
    }

    Navigator.of(context).pop();
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = null;
      _closeToWater = null;
      _campFireAllowed = null;
      _hostLanguages = null;
      _minPrice = null;
      _maxPrice = null;
      _selectedCountry = null;
      _priceRange = null;
    });
  }

  void _closeBottomSheet() async {
    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * MediaQuery.of(context).size.height),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.radiusLarge),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchSection(),
                        const SizedBox(height: AppConstants.paddingLarge),
                        _buildBooleanFilters(),
                        const SizedBox(height: AppConstants.paddingLarge),
                        _buildPriceRangeSection(),
                        const SizedBox(height: AppConstants.paddingLarge),
                        _buildCountrySection(),
                        const SizedBox(height: AppConstants.paddingLarge),
                        _buildLanguageSection(),
                        const SizedBox(height: 100), // Space for bottom buttons
                      ],
                    ),
                  ),
                ),
                _buildBottomButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLarge),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _closeBottomSheet,
            icon: const Icon(Icons.close),
          ),
          const Expanded(
            child: Text(
              'Filter Campsites',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: _clearAllFilters,
            child: Text(
              'Clear All',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Search', Icons.search),
        const SizedBox(height: AppConstants.paddingSmall),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search campsites, countries, languages...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery?.isNotEmpty == true
                ? IconButton(
              onPressed: () => setState(() => _searchQuery = null),
              icon: const Icon(Icons.clear),
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
          onChanged: (value) => setState(() => _searchQuery = value.isEmpty ? null : value),
          controller: TextEditingController(text: _searchQuery ?? ''),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1);
  }

  Widget _buildBooleanFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Features', Icons.tune),
        const SizedBox(height: AppConstants.paddingSmall),
        _buildBooleanFilterTile(
          'Close to Water',
          Icons.water,
          _closeToWater,
              (value) => setState(() => _closeToWater = value),
          Colors.blue,
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        _buildBooleanFilterTile(
          'Campfire Allowed',
          Icons.local_fire_department,
          _campFireAllowed,
              (value) => setState(() => _campFireAllowed = value),
          Colors.orange,
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1);
  }

  Widget _buildBooleanFilterTile(
      String title,
      IconData icon,
      bool? currentValue,
      ValueChanged<bool?> onChanged,
      Color iconColor,
      ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: iconColor),
            title: Text(title),
            trailing: currentValue != null
                ? IconButton(
              onPressed: () => onChanged(null),
              icon: const Icon(Icons.clear, size: 20),
            )
                : null,
          ),
          if (currentValue != null) const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Yes'),
                  value: true,
                  groupValue: currentValue,
                  onChanged: onChanged,
                  dense: true,
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('No'),
                  value: false,
                  groupValue: currentValue,
                  onChanged: onChanged,
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeSection() {
    final priceStats = ref.watch(priceRangeProvider);

    if (priceStats == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Price Range', Icons.euro),
        const SizedBox(height: AppConstants.paddingSmall),
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _priceRange != null
                        ? '€${_priceRange!.start.round()} - €${_priceRange!.end.round()}'
                        : 'Any price',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (_priceRange != null)
                    TextButton(
                      onPressed: () => setState(() => _priceRange = null),
                      child: const Text('Clear'),
                    ),
                ],
              ),
              RangeSlider(
                values: _priceRange ?? RangeValues(priceStats.min, priceStats.max),
                min: priceStats.min,
                max: priceStats.max,
                divisions: 20,
                labels: RangeLabels(
                  '€${(_priceRange?.start ?? priceStats.min).round()}',
                  '€${(_priceRange?.end ?? priceStats.max).round()}',
                ),
                onChanged: (RangeValues values) {
                  setState(() => _priceRange = values);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('€${priceStats.min.round()}', style: TextStyle(color: Colors.grey[600])),
                  Text('€${priceStats.max.round()}', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1);
  }

  Widget _buildCountrySection() {
    final availableCountries = ref.watch(availableCountriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Country', Icons.location_on),
        const SizedBox(height: AppConstants.paddingSmall),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppConstants.paddingMedium),
            ),
            hint: const Text('Select a country'),
            value: _selectedCountry,
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Any country'),
              ),
              ...availableCountries.map((country) => DropdownMenuItem<String>(
                value: country,
                child: Text(country),
              )),
            ],
            onChanged: (value) => setState(() => _selectedCountry = value),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1);
  }

  Widget _buildLanguageSection() {
    final availableLanguages = ref.watch(availableLanguagesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Host Languages', Icons.language),
        const SizedBox(height: AppConstants.paddingSmall),
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableLanguages.map((language) {
              final isSelected = _hostLanguages?.contains(language) ?? false;
              return FilterChip(
                selected: isSelected,
                label: Text(language.toLanguageName()),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _hostLanguages = (_hostLanguages ?? [])..add(language);
                    } else {
                      _hostLanguages?.remove(language);
                      if (_hostLanguages?.isEmpty ?? false) {
                        _hostLanguages = null;
                      }
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1);
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: AppConstants.paddingSmall),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    final hasChanges = _hasFilterChanges();

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _closeBottomSheet,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: ElevatedButton(
                onPressed: hasChanges ? _applyFilters : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 1, delay: 600.ms);
  }

  bool _hasFilterChanges() {
    final currentFilters = ref.read(filtersProvider);

    return _searchQuery != currentFilters.searchQuery ||
        _closeToWater != currentFilters.closeToWater ||
        _campFireAllowed != currentFilters.campFireAllowed ||
        !_listEquals(_hostLanguages, currentFilters.hostLanguages) ||
        _selectedCountry != currentFilters.country ||
        (_priceRange?.start ?? currentFilters.minPrice) != currentFilters.minPrice ||
        (_priceRange?.end ?? currentFilters.maxPrice) != currentFilters.maxPrice;
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}