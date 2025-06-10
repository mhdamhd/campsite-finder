import 'package:campsite_finder/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/campsite.dart';
import '../../providers/campsite_provider.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';

class CampsiteDetailView extends ConsumerWidget {
  final String campsiteId;

  const CampsiteDetailView({
    super.key,
    required this.campsiteId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campsiteAsync = ref.watch(campsiteByIdProvider(campsiteId));

    return Scaffold(
      body: campsiteAsync.when(
        loading: () => const LoadingWidget(message: 'Loading campsite details...'),
        error: (error, stackTrace) => ErrorWidgetCustom(
          message: error.toString(),
          onRetry: () => ref.invalidate(campsitesProvider),
        ),
        data: (campsite) {
          if (campsite == null) {
            return const Center(
              child: Text('Campsite not found'),
            );
          }
          return _buildResponsiveLayout(context, campsite);
        },
      ),
    );
  }

  Widget _buildResponsiveLayout(BuildContext context, Campsite campsite) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > AppConstants.desktopBreakpoint;
    final isTablet = screenWidth > AppConstants.tabletBreakpoint && !isDesktop;

    if (isDesktop) {
      return _buildDesktopLayout(context, campsite);
    } else if (isTablet) {
      return _buildTabletLayout(context, campsite);
    } else {
      return _buildMobileLayout(context, campsite);
    }
  }

  Widget _buildDesktopLayout(BuildContext context, Campsite campsite) {
    return Scaffold(
      appBar: AppBar(
        title: Text(campsite.label),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Left side - Image
            Expanded(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 4 / 3,
                // height: double.infinity,
                child: ClipRRect(
                  child: Image.network(
                    campsite.photo,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Right side - Content
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCampsiteHeader(context, campsite),
                      const SizedBox(height: 32),
                      _buildDesktopContentGrid(context, campsite),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, Campsite campsite) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 4/3,
                child: Image.network(
                  campsite.photo,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 100),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
              Positioned(
                top: 40,
                left: 24,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCampsiteHeader(context, campsite),
                  const SizedBox(height: 24),
                  _buildTabletContentGrid(context, campsite),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, Campsite campsite) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 4/3,
                child: Image.network(
                  campsite.photo,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 100),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 300,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
              Positioned(
                top: 40,
                left: 16,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCampsiteHeader(context, campsite),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildPriceSection(context, campsite),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildFeaturesSection(context, campsite),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildLocationSection(context, campsite),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildLanguagesSection(context, campsite),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildSuitableForSection(context, campsite),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildCreatedSection(context, campsite),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopContentGrid(BuildContext context, Campsite campsite) {
    return Column(
      children: [
        // Top row - Price and quick features
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildPriceSection(context, campsite),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 3,
              child: _buildFeaturesSection(context, campsite),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Middle row - Location and languages
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildLocationSection(context, campsite),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: [
                  _buildLanguagesSection(context, campsite),
                  const SizedBox(height: 24),
                  _buildCreatedSection(context, campsite),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Bottom - Suitable for section
        _buildSuitableForSection(context, campsite),
      ],
    );
  }

  Widget _buildTabletContentGrid(BuildContext context, Campsite campsite) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildPriceSection(context, campsite),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildFeaturesSection(context, campsite),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildLocationSection(context, campsite),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildLanguagesSection(context, campsite),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildSuitableForSection(context, campsite),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildCreatedSection(context, campsite),
      ],
    );
  }

  Widget _buildCampsiteHeader(BuildContext context, Campsite campsite) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          campsite.label,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 20,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                campsite.country,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context, Campsite campsite) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.euro,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campsite.priceInEuros.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'per night',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, Campsite campsite) {
    return _buildSection(
      context,
      title: 'Features & Amenities',
      icon: Icons.featured_play_list,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildFeatureChip(
            icon: campsite.isCloseToWater ? Icons.water : Icons.water_outlined,
            label: campsite.isCloseToWater ? 'Near Water' : 'Not Near Water',
            color: campsite.isCloseToWater ? Colors.blue : Colors.grey,
            isActive: campsite.isCloseToWater,
          ),
          _buildFeatureChip(
            icon: campsite.isCampFireAllowed
                ? Icons.local_fire_department
                : Icons.local_fire_department_outlined,
            label: campsite.isCampFireAllowed ? 'Campfire Allowed' : 'No Campfire',
            color: campsite.isCampFireAllowed ? Colors.orange : Colors.grey,
            isActive: campsite.isCampFireAllowed,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context, Campsite campsite) {
    return _buildSection(
      context,
      title: 'Location',
      icon: Icons.location_on,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.public,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Country: ${campsite.country}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Coordinates: ${campsite.geoLocation.lat.toStringAsFixed(6)}, ${campsite.geoLocation.lng.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openInMaps(context, campsite),
              icon: const Icon(Icons.map),
              label: const Text('Open in Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSection(BuildContext context, Campsite campsite) {
    if (campsite.hostLanguages.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      context,
      title: 'Host Languages',
      icon: Icons.language,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: campsite.hostLanguages.map((language) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.purple.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language,
                  size: 16,
                  color: Colors.purple[600],
                ),
                const SizedBox(width: 4),
                Text(
                  language.toLanguageName(),
                  style: TextStyle(
                    color: Colors.purple[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSuitableForSection(BuildContext context, Campsite campsite) {
    if (campsite.suitableFor.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      context,
      title: 'Suitable For',
      icon: Icons.groups,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: campsite.suitableFor.map((category) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.teal.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: Colors.teal[600],
                ),
                const SizedBox(width: 4),
                Text(
                  category,
                  style: TextStyle(
                    color: Colors.teal[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCreatedSection(BuildContext context, Campsite campsite) {
    return _buildSection(
      context,
      title: 'Listing Information',
      icon: Icons.info_outline,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              'Listed on: ${_formatDate(campsite.createdAt)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Widget child,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildFeatureChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? color : Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? color : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _openInMaps(BuildContext context, Campsite campsite) {
    context.pushNamed(
      'map',
      queryParameters: {
        'lat': campsite.geoLocation.normalizedLat.toString(),
        'lng': campsite.geoLocation.normalizedLng.toString(),
      },
    );
  }
}