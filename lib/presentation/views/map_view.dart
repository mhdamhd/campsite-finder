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
  double _currentZoom = 6.0;
  bool _useClusteringMode = true;

  @override
  void initState() {
    super.initState();
    _currentZoom = _defaultZoom;
  }

  @override
  Widget build(BuildContext context) {
    final filteredCampsites = ref.watch(filteredCampsitesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campsite Map', style: TextStyle(color: Colors.white),),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_useClusteringMode ? Icons.scatter_plot : Icons.location_on),
            onPressed: () {
              setState(() {
                _useClusteringMode = !_useClusteringMode;
              });
            },
            tooltip: _useClusteringMode ? 'Disable clustering' : 'Enable clustering',
          ),
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
        initialZoom: _defaultZoom,
        minZoom: 3.0,
        maxZoom: 18.0,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
        onMapEvent: (MapEvent mapEvent) {
          if (mapEvent is MapEventMove || mapEvent is MapEventScrollWheelZoom  || mapEvent is MapEventDoubleTapZoom) {
            setState(() {
              _currentZoom = mapEvent.camera.zoom;
            });
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.campsite_finder',
          maxZoom: 19,
        ),
        // Use clustering or regular markers based on settings and campsite count
        if (_useClusteringMode && campsites.length > 10)
          _buildClusterLayer(campsites)
        else
          MarkerLayer(markers: _buildMarkers(campsites)),
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
    final clusters = _createClusters(campsites, _currentZoom);

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
        } else {
          // Cluster marker
          final clusterSize = _getClusterSize(cluster.campsites.length);
          return Marker(
            point: cluster.center,
            width: clusterSize,
            height: clusterSize,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _zoomToCluster(cluster),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getClusterColor(cluster.campsites.length),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${cluster.campsites.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
    // More aggressive clustering at lower zoom levels
    if (zoom <= 4) return 500; // 600km
    if (zoom <= 6) return 300; // 300km
    if (zoom <= 8) return 50;  // 50km
    if (zoom <= 10) return 25; // 25km
    if (zoom <= 12) return 10; // 10km
    if (zoom <= 14) return 5;  // 5km
    return 2; // 2km for high zoom levels
  }

  double _getClusterSize(int clusterSize) {
    if (clusterSize < 5) return 50.0;
    if (clusterSize < 10) return 60.0;
    if (clusterSize < 20) return 70.0;
    if (clusterSize < 50) return 80.0;
    return 90.0;
  }

  Color _getClusterColor(int clusterSize) {
    if (clusterSize < 5) return Colors.blue;
    if (clusterSize < 10) return Colors.green;
    if (clusterSize < 20) return Colors.orange;
    if (clusterSize < 50) return Colors.red;
    return Colors.purple;
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
    final cameraFit = CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.all(50),
    );
    _mapController.fitCamera(cameraFit);
  }

  LatLngBounds _calculateBounds(List<Campsite> campsites) {
    if (campsites.isEmpty) {
      return LatLngBounds(_defaultCenter, _defaultCenter);
    }

    double minLat = campsites.first.geoLocation.normalizedLat;
    double maxLat = campsites.first.geoLocation.normalizedLat;
    double minLng = campsites.first.geoLocation.normalizedLng;
    double maxLng = campsites.first.geoLocation.normalizedLng;

    for (final campsite in campsites) {
      final lat = campsite.geoLocation.normalizedLat;
      final lng = campsite.geoLocation.normalizedLng;

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
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
        final cameraFit = CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        );
        _mapController.fitCamera(cameraFit);
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