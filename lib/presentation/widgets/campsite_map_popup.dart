import 'package:cached_network_image/cached_network_image.dart';
import 'package:campsite_finder/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import '../../models/campsite.dart';
import '../../core/constants/app_constants.dart';

class CampsiteMapPopup extends StatelessWidget {
  final Campsite campsite;
  final VoidCallback onViewDetails;

  const CampsiteMapPopup({
    super.key,
    required this.campsite,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Campsite image
          Flexible(child: ListView(
            shrinkWrap: true,
            children: [ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.radiusMedium),
              ),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Hero(
                  tag: "Campsite:${campsite.id}",
                  child: CachedNetworkImage(
                    imageUrl: campsite.photo,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                    placeholder: (context, url) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campsite name
                    Text(
                      campsite.label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppConstants.paddingSmall),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${campsite.country} • ${campsite.geoLocation.lat.toStringAsFixed(4)}, ${campsite.geoLocation.lng.toStringAsFixed(4)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.paddingSmall),

                    // Price
                    Row(
                      children: [
                        Icon(
                          Icons.euro,
                          size: 16,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${campsite.priceInEuros.toStringAsFixed(2)} per night',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.paddingMedium),

                    // Features row
                    Wrap(
                      spacing: AppConstants.paddingSmall,
                      runSpacing: AppConstants.paddingSmall,
                      children: [
                        if (campsite.isCloseToWater)
                          _buildFeatureChip(
                            icon: Icons.water,
                            label: 'Near Water',
                            color: Colors.blue,
                          ),
                        if (campsite.isCampFireAllowed)
                          _buildFeatureChip(
                            icon: Icons.local_fire_department,
                            label: 'Campfire',
                            color: Colors.orange,
                          ),
                        if (campsite.hostLanguages.isNotEmpty)
                          _buildFeatureChip(
                            icon: Icons.language,
                            label: campsite.hostLanguages.first.toLanguageName(),
                            color: Colors.purple,
                          ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.paddingMedium),

                    // View details button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onViewDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.paddingMedium,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                          ),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )],
          )),
        ],
      ),
    );
  }

  Widget _buildFeatureChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}