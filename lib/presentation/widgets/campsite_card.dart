import 'package:campsite_finder/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/campsite.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';

class CampsiteCard extends StatefulWidget {
  final Campsite campsite;
  final VoidCallback? onTap;

  const CampsiteCard({
    super.key,
    required this.campsite,
    this.onTap,
  });

  @override
  State<CampsiteCard> createState() => _CampsiteCardState();
}

class _CampsiteCardState extends State<CampsiteCard>
    with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(),
                _buildContentSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    // return AspectRatio(
      // aspectRatio: 4 / 3,
    return Expanded(
      flex: 3,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusLarge),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusLarge),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: widget.campsite.photo,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.landscape,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
              _buildPriceTag(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceTag() {
    return Positioned(
      top: AppConstants.paddingSmall,
      right: AppConstants.paddingSmall,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingSmall,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
        child: Text(
          '${Formatters.formatPrecisePrice(widget.campsite.priceInEuros)}/night',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildLocation(),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildFeatures(),
            const SizedBox(height: AppConstants.paddingSmall),
            // const Spacer(),
            _buildLanguages(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.campsite.label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLocation() {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            widget.campsite.country ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    final hasFeatures = widget.campsite.isCloseToWater ||
        widget.campsite.isCampFireAllowed;

    if (!hasFeatures) return const SizedBox.shrink();
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        if (widget.campsite.isCloseToWater)
          _buildFeatureChip(Icons.water, 'Water nearby', Colors.blue),
        if (widget.campsite.isCampFireAllowed)
          _buildFeatureChip(Icons.local_fire_department, 'Campfire', Colors.orange),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguages() {
    if (widget.campsite.hostLanguages.isEmpty) return SizedBox.shrink();
    return Row(
      children: [
        Icon(
          Icons.language,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            widget.campsite.hostLanguages.map((code) => code.toLanguageName()).join(', '),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}