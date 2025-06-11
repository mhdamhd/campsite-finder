import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/campsite.dart';
import '../../providers/campsite_provider.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/campsite_card.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_bottom_sheet.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_showFab) {
      setState(() => _showFab = true);
    } else if (_scrollController.offset <= 100 && _showFab) {
      setState(() => _showFab = false);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: AppConstants.slowAnimation,
      curve: Curves.easeInOut,
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCampsites = ref.watch(filteredCampsitesProvider);
    final filters = ref.watch(filtersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(context, filters),
          _buildFilterChipBar(),
          _buildCampsiteList(filteredCampsites),
        ],
      ),
      floatingActionButton: _showFab ? FloatingActionButton(
        onPressed: _scrollToTop,
        child: const Icon(Icons.keyboard_arrow_up),
      ) : SizedBox.shrink(),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, filters) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Campsite Finder',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.tune, color: Colors.white),
              if (filters.hasActiveFilters)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '${filters.activeFilterCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: _showFilterBottomSheet,
        ),
      ],
    );
  }

  Widget _buildFilterChipBar() {
    return FilterChipBar();
  }

  Widget _buildCampsiteList(AsyncValue<List<Campsite>> campsitesAsync) {
    return campsitesAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: LoadingWidget(message: AppConstants.loadingCampsites),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: ErrorWidgetCustom(
          message: error.toString(),
          onRetry: () => ref.invalidate(campsitesProvider),
        ),
      ),
      data: (campsites) {
        if (campsites.isEmpty) {
          return const SliverToBoxAdapter(
            child: EmptyState(
              message: "No Campsites Found",
            ),
          );
        }

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Wrap(
              spacing: AppConstants.paddingMedium,
              runSpacing: AppConstants.paddingMedium,
              children: campsites.map((campsite) {
                return SizedBox(
                  width: _getCardWidth(context),
                  child: CampsiteCard(
                    campsite: campsite,
                    onTap: () => context.pushNamed(
                      'campsite_detail',
                      pathParameters: {'id': campsite.id},
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  double _getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = AppConstants.paddingMedium * 2; // Left and right padding

    if (screenWidth > AppConstants.desktopBreakpoint) {
      // 3 cards per row on desktop
      return (screenWidth - padding - (AppConstants.paddingMedium * 2)) / 3;
    } else if (screenWidth > AppConstants.tabletBreakpoint) {
      // 2 cards per row on tablet
      return (screenWidth - padding - AppConstants.paddingMedium) / 2;
    } else {
      // 1 card per row on mobile
      return screenWidth - padding;
    }
  }

  Widget _buildCampsiteLists(AsyncValue<List<Campsite>> campsitesAsync) {
    return campsitesAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: LoadingWidget(message: AppConstants.loadingCampsites),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: ErrorWidgetCustom(
          message: error.toString(),
          onRetry: () => ref.invalidate(campsitesProvider),
        ),
      ),
      data: (campsites) {
        if (campsites.isEmpty) {
          return const SliverToBoxAdapter(
            child: EmptyState(
              message: "No Campsites Found",
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          sliver: SliverGrid(
            gridDelegate: _getGridDelegate(context),

            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final campsite = campsites[index];
                return CampsiteCard(
                  campsite: campsite,
                  onTap: () => context.pushNamed(
                    'campsite_detail',
                    pathParameters: {'id': campsite.id},
                  ),
                );
              },
              childCount: campsites.length,
            ),
          ),
        );
      },
    );
  }

  SliverGridDelegate _getGridDelegate(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > AppConstants.desktopBreakpoint) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppConstants.paddingMedium,
        crossAxisSpacing: AppConstants.paddingMedium,
        childAspectRatio: 0.75,
      );
    } else if (screenWidth > AppConstants.tabletBreakpoint) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppConstants.paddingMedium,
        crossAxisSpacing: AppConstants.paddingMedium,
        childAspectRatio: 0.8,
      );
    } else {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: AppConstants.paddingMedium,
        crossAxisSpacing: AppConstants.paddingMedium,
        childAspectRatio: 1,
      );
    }
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
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          context.pushNamed('map');
        }
      },
    );
  }
}