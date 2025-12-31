import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

class TagGrid extends ConsumerWidget {
  const TagGrid({super.key});

  final List<String> _categories = const [
    'Frühstück',
    'Mittag',
    'Abendessen',
    'Schnell',
    'Vegetarisch',
    'Vegan',
    'Dessert',
    'Backen',
    'Kinder',
    'Party',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);

    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 4,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        final isSelected = selected == cat;

        return GestureDetector(
          onTap: () {
            ref.read(selectedCategoryProvider.notifier).state = isSelected
                ? null
                : cat;
            // Optionally trigger a search/filter action here using other providers
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Text(
              cat,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}
