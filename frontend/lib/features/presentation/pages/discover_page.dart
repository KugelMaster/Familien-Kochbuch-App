import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/presentation/widgets/cookbook_search_bar.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const CookbookSearchBar(),
              const SizedBox(height: 20),
              const TagList(),
            ],
          ),
        ),
      ),
    );
  }
}

class TagList extends ConsumerWidget {
  const TagList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final selectedTags = ref.read(tagsProvider);
    return Text("Noch nicht implementiert :-/");
  }
}
