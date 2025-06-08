import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/campsite_provider.dart';
import '../../models/campsite.dart';
import '../widgets/campsite_card.dart';
import '../widgets/loading_widget.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>{

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final campsitesAsync = ref.watch(campsitesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Capmsite Finder'),
      ),
      body: campsitesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (campsites) {
          List<Campsite> filtered = campsites;


          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () {

                    },
                    child: CampsiteCard(campsite: filtered[i]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}