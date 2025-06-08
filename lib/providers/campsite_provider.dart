import 'package:campsite_finder/models/campsite.dart';
import 'package:campsite_finder/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final campsitesProvider = FutureProvider<List<Campsite>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getCampsites();
});