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

  Future<void> _onRefresh() async {
    // Invalidate the campsites provider to trigger a fresh fetch
    ref.invalidate(campsitesProvider);

    // Wait for the new data to load
    await ref.read(campsitesProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final filteredCampsites = ref.watch(filteredCampsitesProvider);
    final filters = ref.watch(filtersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(context, filters),
            _buildFilterChipBar(),
            _buildCampsiteList(filteredCampsites),
          ],
        ),
      ),
      floatingActionButton: _showFab ? FloatingActionButton(
        onPressed: _scrollToTop,
        child: const Icon(Icons.keyboard_arrow_up),
      ) : SizedBox.shrink(),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, CampsiteFilters filters) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 140,
      floating: true,
      pinned: true,
      backgroundColor: theme.primaryColor,
      elevation: 6,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 72, bottom: 16),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 14,
              backgroundImage: AssetImage('assets/logo.jpg'), // 🖼️ Your logo here
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(width: 8),
            Text(
              'Campsite Finder',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor,
                theme.primaryColor.withOpacity(0.85),
                theme.primaryColor.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.tune, color: Colors.white, size: 26),
              if (filters.hasActiveFilters)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text(
                      '${filters.activeFilterCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          tooltip: 'Filters',
          onPressed: _showFilterBottomSheet,
        ),
        const SizedBox(width: 8),
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