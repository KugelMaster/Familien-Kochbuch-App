import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/providers/recipe_providers.dart';

class AnimatedAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final ScrollController scrollController;
  final int recipeId;
  final String title;
  final double triggerOffset;

  const AnimatedAppBar({
    super.key,
    required this.scrollController,
    required this.recipeId,
    required this.title,
    required this.triggerOffset,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnimatedAppBarState();
}

class _AnimatedAppBarState extends ConsumerState<AnimatedAppBar> {
  bool scrolled = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final shouldBeScrolled =
        widget.scrollController.offset > widget.triggerOffset;

    if (shouldBeScrolled != scrolled) {
      setState(() => scrolled = shouldBeScrolled);
    }
  }

  void _onDeletePressed() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 40), //TODO: Vllt doch ohne Icon?
        title: const Text(
          "Rezept löschen",
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Willst du das Rezept "${widget.title}" wirklich unwiderruflich löschen?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actionsPadding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text("Abbrechen"),
            onPressed: () => Navigator.pop(context, false),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Ja, löschen"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      )
    );

    if (!(confirmed ?? false)) return;

    await ref.read(recipeProvider(widget.recipeId).notifier).deleteRecipe();

    // Return to the original caller who opened the RecipeOverviewPage
    // "true" means, that the recipe changed (in this case deleted)
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: scrolled ? Colors.white : Colors.transparent,
        border: scrolled
            ? const Border(
                bottom: BorderSide(color: Colors.black12, width: 0.8),
              )
            : null,
      ),
      child: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: scrolled ? Colors.black : Colors.white,
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: AnimatedOpacity(
          opacity: scrolled ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _onDeletePressed,
            icon: Icon(
              Icons.delete,
              color: scrolled ? Colors.black : Colors.white,
            ),
          ),
        ],
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
