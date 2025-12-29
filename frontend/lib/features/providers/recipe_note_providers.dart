import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client_provider.dart';
import 'package:frontend/features/data/models/recipe_note.dart';
import 'package:frontend/features/data/services/recipe_note_service.dart';
import 'package:frontend/features/providers/recipe_providers.dart';

final recipeNoteServiceProvider = Provider((ref) {
  final client = ref.watch(apiClientProvider);
  return RecipeNoteService(client);
});

final recipeNoteRepositoryProvider =
    NotifierProvider<RecipeNoteRepositoryNotifier, Map<int, List<RecipeNote>>>(
      RecipeNoteRepositoryNotifier.new,
    );

class RecipeNoteRepositoryNotifier
    extends Notifier<Map<int, List<RecipeNote>>> {
  late final RecipeNoteService _recipeNoteService = ref.read(
    recipeNoteServiceProvider,
  );

  @override
  Map<int, List<RecipeNote>> build() {
    ref.watch(recipeRepositoryInvalidationProvider);
    return {};
  }

  Future<List<RecipeNote>> getByRecipeId(int recipeId) async {
    final cached = state[recipeId];
    if (cached != null) return cached;

    final notes = await _recipeNoteService.getByRecipeId(recipeId);
    state = {...state, recipeId: notes};
    return notes;
  }

  Future<int> createRecipeNote(RecipeNoteCreate note) async {
    final created = await _recipeNoteService.createRecipeNote(note);

    final notes = state[created.recipeId] ?? [];
    notes.add(created);
    state = {...state, created.recipeId: notes};

    return created.id;
  }

  Future<RecipeNote> updateRecipeNote(RecipeNote note) async {
    final updated = await _recipeNoteService.updateRecipeNote(
      note.id,
      note.content,
    );

    final notes = state[note.recipeId] ?? [];
    final noteIndex = notes.indexWhere((oldNote) => oldNote.id == note.id);
    if (noteIndex != -1) {
      notes[noteIndex] = note;
      state = {...state, note.recipeId: notes};
    }

    return updated;
  }

  Future<void> deleteRecipeNote(int recipeId, int noteId) async {
    await _recipeNoteService.deleteRecipeNote(noteId);

    final notes = state[recipeId] ?? [];
    notes.removeWhere((note) => note.id == noteId);
    state = {...state, recipeId: notes};
  }
}

final recipeNotesProvider = FutureProvider.family<List<RecipeNote>, int>((
  ref,
  recipeId,
) async {
  ref.watch(recipeNoteRepositoryProvider);
  return ref
      .read(recipeNoteRepositoryProvider.notifier)
      .getByRecipeId(recipeId);
});
