import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../models/campsite.dart';
import '../../providers/campsite_provider.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/campsite_map_popup.dart';

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key, this.specifiedSite});
  final LatLng? specifiedSite;

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  final MapController _mapController = MapController();
  final double _defaultZoom = 6.0;
  final LatLng _defaultCenter = LatLng(51.1657, 10.4515); // Germany center


  @override
  Widget build(BuildContext context) {
    final filteredCampsites = ref.watch(filteredCampsitesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campsite Map'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerMapOnCampsites,
            tooltip: 'Center on campsites',
          ),
        ],
      ),
      body: filteredCampsites.when(
        loading: () => const LoadingWidget(message: AppConstants.loadingCampsites),
        error: (error, stackTrace) => ErrorWidgetCustom(
          message: error.toString(),
          onRetry: () => ref.invalidate(campsitesProvider),
        ),
        data: (campsites) => _buildMap(campsites),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildMap(List<Campsite> campsites) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _getMapCenter(campsites),
        // initialCenter: LatLng(campsites.first.geoLocation.normalizedLat, campsites.first.geoLocation.normalizedLng),
        initialZoom: _defaultZoom,
        minZoom: 3.0,
        maxZoom: 18.0,
        interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.campsite_finder',
          maxZoom: 19,
        ),
        MarkerLayer(
          markers:  _buildMarkers(campsites),
        ),
        // Add clustering markers for better performance with many campsites
        if (campsites.length > 50) _buildClusterLayer(campsites),
      ],
    );
  }

  LatLng _getMapCenter(List<Campsite> campsites) {
    if (widget.specifiedSite != null) return widget.specifiedSite!;
    if (campsites.isEmpty) return _defaultCenter;

    double totalLat = 0;
    double totalLng = 0;

    for (final campsite in campsites) {
      totalLat += campsite.geoLocation.normalizedLat;
      totalLng += campsite.geoLocation.normalizedLng;
    }

    return LatLng(
      totalLat / campsites.length,
      totalLng / campsites.length,
    );
  }

  List<Marker> _buildMarkers(List<Campsite> campsites) {
    return campsites.map((campsite) {
      return Marker(
        point: LatLng(campsite.geoLocation.normalizedLat, campsite.geoLocation.normalizedLng),
        width: 40,
        height: 40,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _showCampsitePopup(context, campsite),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_pin,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildClusterLayer(List<Campsite> campsites) {
    final clusters = _createClusters(campsites, _mapController.camera.zoom);

    return MarkerLayer(
      markers: clusters.map((cluster) {
        if (cluster.campsites.length == 1) {
          // Single campsite - show regular marker
          final campsite = cluster.campsites.first;
          return Marker(
            point: LatLng(campsite.geoLocation.normalizedLat, campsite.geoLocation.normalizedLng),
            width: 40,
            height: 40,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showCampsitePopup(context, campsite),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ) ,
          );
        } else {
          // Cluster marker
          return Marker(
            point: cluster.center,
            width: 60,
            height: 60,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _zoomToCluster(cluster),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      '${cluster.campsites.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  List<CampsiteCluster> _createClusters(List<Campsite> campsites, double zoom) {
    // Simple clustering algorithm - group campsites within a certain distance
    final clusters = <CampsiteCluster>[];
    final processed = <String>{};
    final double clusterDistance = _getClusterDistance(zoom);

    for (final campsite in campsites) {
      if (processed.contains(campsite.id)) continue;

      final cluster = CampsiteCluster(
        center: LatLng(campsite.geoLocation.normalizedLat, campsite.geoLocation.normalizedLng),
        campsites: [campsite],
      );

      processed.add(campsite.id);

      // Find nearby campsites to cluster
      for (final other in campsites) {
        if (processed.contains(other.id)) continue;

        final distance = Distance().as(
          LengthUnit.Kilometer,
          LatLng(campsite.geoLocation.normalizedLat, campsite.geoLocation.normalizedLng),
          LatLng(other.geoLocation.normalizedLat, other.geoLocation.normalizedLng),
        );

        if (distance <= clusterDistance) {
          cluster.campsites.add(other);
          processed.add(other.id);
        }
      }

      // Recalculate center if multiple campsites
      if (cluster.campsites.length > 1) {
        double totalLat = 0;
        double totalLng = 0;
        for (final c in cluster.campsites) {
          totalLat += c.geoLocation.normalizedLat;
          totalLng += c.geoLocation.normalizedLng;
        }
        cluster.center = LatLng(
          totalLat / cluster.campsites.length,
          totalLng / cluster.campsites.length,
        );
      }

      clusters.add(cluster);
    }

    return clusters;
  }

  double _getClusterDistance(double zoom) {
    // Adjust clustering distance based on zoom level
    if (zoom <= 5) return 100; // 100km
    if (zoom <= 8) return 50;  // 50km
    if (zoom <= 10) return 25; // 25km
    if (zoom <= 12) return 10; // 10km
    return 5; // 5km
  }

  void _showCampsitePopup(BuildContext context, Campsite campsite) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CampsiteMapPopup(
        campsite: campsite,
        onViewDetails: () {
          Navigator.of(context).pop();
          context.pushNamed(
            'campsite_detail',
            pathParameters: {'id': campsite.id},
          );
        },
      ),
    );
  }

  void _zoomToCluster(CampsiteCluster cluster) {
    // Calculate bounds for the cluster
    final bounds = _calculateBounds(cluster.campsites);
    final cameraFit = CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(50));
    _mapController.fitCamera(cameraFit);
    // _mapController.camera.fitBounds(bounds, options: const FitBoundsOptions(
    //   padding: EdgeInsets.all(50),
    // ));
  }

  LatLngBounds _calculateBounds(List<Campsite> campsites) {
    double minLat = campsites.first.geoLocation.normalizedLat;
    double maxLat = campsites.first.geoLocation.normalizedLat;
    double minLng = campsites.first.geoLocation.normalizedLng;
    double maxLng = campsites.first.geoLocation.normalizedLng;

    for (final campsite in campsites) {
      minLat = minLat < campsite.geoLocation.normalizedLat ? minLat : campsite.geoLocation.normalizedLat;
      maxLat = maxLat > campsite.geoLocation.normalizedLat ? maxLat : campsite.geoLocation.normalizedLat;
      minLng = minLng < campsite.geoLocation.normalizedLng ? minLng : campsite.geoLocation.normalizedLng;
      maxLng = maxLng > campsite.geoLocation.normalizedLng ? maxLng : campsite.geoLocation.normalizedLng;
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  void _centerMapOnCampsites() {
    final filteredCampsites = ref.read(filteredCampsitesProvider);
    filteredCampsites.whenData((campsites) {
      if (campsites.isNotEmpty) {
        final bounds = _calculateBounds(campsites);
        final cameraFit = CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(50));
        // _mapController.fitBounds(bounds, options: const FitBoundsOptions(
        //   padding: EdgeInsets.all(50),
        // ));
      }
    });
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Campsites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Map',
        ),
      ],
      currentIndex: 1,
      onTap: (index) {
        if (index == 0) {
          context.pop();
        }
      },
    );
  }
}

class CampsiteCluster {
  LatLng center;
  final List<Campsite> campsites;

  CampsiteCluster({
    required this.center,
    required this.campsites,
  });
}