import 'package:campsite_finder/presentation/views/campsite_detail_view.dart';
import 'package:campsite_finder/presentation/views/home_view.dart';
import 'package:campsite_finder/presentation/views/map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const ProviderScope(child: CampsiteFinderApp()));
}

class CampsiteFinderApp extends ConsumerWidget {
  const CampsiteFinderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Campsite Finder',
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: '/map',
      name: 'map',
      builder: (context, state) {
        final latStr = state.uri.queryParameters['lat'];
        final lngStr = state.uri.queryParameters['lng'];

        LatLng? center;
        if (latStr != null && lngStr != null) {
          final lat = double.tryParse(latStr);
          final lng = double.tryParse(lngStr);
          if (lat != null && lng != null) {
            center = LatLng(lat, lng);
          }
        }
        return MapView(specifiedSite: center);
      },
    ),
    GoRoute(
          path: '/campsite/:id',
          name: 'campsite_detail',
          builder: (context, state) {
            final campsiteId = state.pathParameters['id']!;
            return CampsiteDetailView(campsiteId: campsiteId);
          },
        ),
  ],
);