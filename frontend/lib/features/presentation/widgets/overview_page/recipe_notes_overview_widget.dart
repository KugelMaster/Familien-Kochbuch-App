import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client_provider.dart';
import 'package:frontend/features/data/models/recipe_note.dart';
import 'package:frontend/features/providers/recipe_note_providers.dart';

class RecipeNotesOverviewWidget extends ConsumerStatefulWidget {
  final int recipeId;
  final List<RecipeNote> recipeNotes;

  const RecipeNotesOverviewWidget({
    super.key,
    required this.recipeId,
    List<RecipeNote>? recipeNotes,
  }) : recipeNotes = recipeNotes ?? const [];

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RecipeNotesSectionState();
}

class _RecipeNotesSectionState extends ConsumerState<RecipeNotesOverviewWidget> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (final note in widget.recipeNotes)
            _RecipeNoteTile(
              note: note,
              isOwnNote: note.userId == currentUserId,
              onDelete: () => ref
                  .read(recipeNoteProvider.notifier)
                  .deleteRecipeNote(note.id!),
              onEdit: (content) => ref
                  .read(recipeNoteProvider.notifier)
                  .updateRecipeNote(note.id!, content),
            ),

          const SizedBox(height: 24),

          _NewNoteInput(
            controller: _controller,
            onSubmit: () {
              final text = _controller.text.trim();
              if (text.isEmpty) return;

              final note = RecipeNote(
                recipeId: widget.recipeId,
                userId: currentUserId,
                content: text,
              );

              ref.read(recipeNoteProvider.notifier).createRecipeNote(note);
              _controller.clear();
            },
          ),
        ],
      ),
    );
  }
}

class _RecipeNoteTile extends StatelessWidget {
  final RecipeNote note;
  final bool isOwnNote;
  final VoidCallback onDelete;
  final ValueChanged<String> onEdit;

  const _RecipeNoteTile({
    required this.note,
    required this.isOwnNote,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      // 'clipBehavior' sorgt dafür, dass Inhalte nicht über abgerundete Ecken ragen
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(theme),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, theme),
                  const SizedBox(height: 4),
                  Text(note.content, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        note.userId.toString().characters.first.toUpperCase(),
        style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            "User ${note.userId}", // Oder note.userName falls vorhanden
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isOwnNote)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, size: 18),
                onPressed: () => _handleEdit(context),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: Icon(Icons.delete, size: 18),
                onPressed: onDelete,
                constraints: const BoxConstraints(), // Entfernt extra Padding
                padding: const EdgeInsets.all(4),
                visualDensity: VisualDensity.compact,
                color: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _handleEdit(BuildContext context) async {
    final controller = TextEditingController(text: note.content);

    final newText = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Notiz bearbeiten"),
        content: TextField(controller: controller, maxLines: null),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Abbrechen"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Speichern"),
          ),
        ],
      ),
    );

    if (newText != null && newText.trim().isNotEmpty) {
      onEdit(newText.trim());
    }
  }
}

class _NewNoteInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _NewNoteInput({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        controller: controller,
        maxLines: null,
        decoration: const InputDecoration(
          hintText: "Neue Notiz hinzufügen...",
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 8),
      ElevatedButton(onPressed: onSubmit, child: const Text("Hinzufügen")),
    ],
  );
}
