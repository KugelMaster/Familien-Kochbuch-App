import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/presentation/widgets/delete_prompt.dart';
import 'package:frontend/features/providers/recipe_providers.dart';

class AnimatedAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final ScrollController scrollController;
  final int recipeId;
  final String title;
  final double triggerOffset;

  final void Function(bool) onClose;

  const AnimatedAppBar({
    super.key,
    required this.scrollController,
    required this.recipeId,
    required this.title,
    required this.triggerOffset,
    required this.onClose,
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
    final confirmed = await DeletePrompt.open(
      context: context,
      title: "Rezept löschen",
      content: 'Willst du das Rezept "${widget.title}" wirklich unwiderruflich löschen?',
    );

    if (!confirmed) return;

    await ref.read(recipeRepositoryProvider.notifier).deleteRecipe(widget.recipeId);

    widget.onClose(true);
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
          onPressed: () => widget.onClose(false),
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
