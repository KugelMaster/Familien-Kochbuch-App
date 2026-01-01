import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/presentation/widgets/cookbook_search_bar.dart';
import 'package:frontend/features/presentation/widgets/tag_grid.dart';

class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(pinned: true, delegate: _SearchHeader()),
            const SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Entdecken",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Kategorien",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: TagGrid(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHeader extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 110;

  @override
  double get maxExtent => 110;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Container(
    color: Theme.of(context).scaffoldBackgroundColor,
    padding: const EdgeInsets.all(16),
    alignment: Alignment.center,
    child: const CookbookSearchBar(),
  );

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
