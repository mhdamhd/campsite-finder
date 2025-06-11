import 'dart:ui';

import 'package:campsite_finder/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/campsite.dart';
import '../../providers/campsite_provider.dart';

class FilterChipBar extends ConsumerWidget {
  const FilterChipBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filtersProvider);

    if (!filters.hasActiveFilters) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final activeFilters = _getActiveFilters(filters);

    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
        child: ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: activeFilters.length + 1, // +1 for clear all chip
            separatorBuilder: (context, index) =>
            const SizedBox(width: AppConstants.paddingSmall),
            itemBuilder: (context, index) {
              if (index == activeFilters.length) {
                return _buildClearAllChip(context, ref);
              }

              final filter = activeFilters[index];
              return _buildFilterChip(
                context,
                ref,
                filter['label'] as String,
                filter['type'] as String,
                filter['icon'] as IconData?,
              ).animate().fadeIn(
                delay: Duration(milliseconds: 100 * index),
              ).slideX(begin: 0.3);
            },
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getActiveFilters(CampsiteFilters filters) {
    final activeFilters = <Map<String, dynamic>>[];

    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      activeFilters.add({
        'label': 'Search: "${filters.searchQuery}"',
        'type': 'search',
        'icon': Icons.search,
      });
    }

    if (filters.closeToWater != null) {
      activeFilters.add({
        'label': filters.closeToWater! ? 'Near Water' : 'Not Near Water',
        'type': 'water',
        'icon': Icons.water,
      });
    }

    if (filters.campFireAllowed != null) {
      activeFilters.add({
        'label': filters.campFireAllowed! ? 'Campfire OK' : 'No Campfire',
        'type': 'fire',
        'icon': Icons.local_fire_department,
      });
    }

    if (filters.hostLanguages != null && filters.hostLanguages!.isNotEmpty) {
      final languageText = filters.hostLanguages!.length == 1
          ? filters.hostLanguages!.first
          : '${filters.hostLanguages!.length} languages';
      activeFilters.add({
        'label': 'Lang: ${languageText.toLanguageName()}',
        'type': 'languages',
        'icon': Icons.language,
      });
    }

    if (filters.minPrice != null || filters.maxPrice != null) {
      String priceLabel;
      if (filters.minPrice != null && filters.maxPrice != null) {
        priceLabel = '€${filters.minPrice!.toInt()}-€${filters.maxPrice!.toInt()}';
      } else if (filters.minPrice != null) {
        priceLabel = 'From €${filters.minPrice!.toInt()}';
      } else {
        priceLabel = 'Up to €${filters.maxPrice!.toInt()}';
      }
      activeFilters.add({
        'label': priceLabel,
        'type': 'price',
        'icon': Icons.euro,
      });
    }

    if (filters.country != null && filters.country!.isNotEmpty) {
      activeFilters.add({
        'label': filters.country!,
        'type': 'country',
        'icon': Icons.location_on,
      });
    }

    return activeFilters;
  }

  Widget _buildFilterChip(
      BuildContext context,
      WidgetRef ref,
      String label,
      String type,
      IconData? icon,
      ) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => ref.read(filtersProvider.notifier).clearFilter(type),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearAllChip(BuildContext context, WidgetRef ref) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => ref.read(filtersProvider.notifier).clearFilters(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.clear_all,
                size: 16,
                color: Colors.red,
              ),
              const SizedBox(width: 6),
              Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 200),
    ).scale(begin: const Offset(0.8, 0.8));
  }
}