import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/api_client_provider.dart';
import 'package:frontend/features/data/models/recipe_note.dart';
import 'package:frontend/features/data/services/recipe_note_service.dart';

final recipeNoteServiceProvider = Provider((ref) {
  final client = ref.watch(apiClientProvider);
  return RecipeNoteService(client);
});

final recipeNoteProvider =
    NotifierProvider<RecipeNoteProvider, Map<int, RecipeNote>>(
      RecipeNoteProvider.new,
    );

class RecipeNoteProvider extends Notifier<Map<int, RecipeNote>> {
  late final RecipeNoteService _recipeNoteService = ref.read(
    recipeNoteServiceProvider,
  );

  @override
  Map<int, RecipeNote> build() {
    return {};
  }

  Future<RecipeNote> getById(int noteId) async {
    final cached = state[noteId];
    if (cached != null) return cached;

    final fetched = await _recipeNoteService.getById(noteId);
    state = {...state, fetched.id!: fetched};
    return fetched;
  }

  /// Adds the given RecipeNotes without interacting with the backend. Useful for caching
  Future<void> addRecipeNotes(List<RecipeNote>? notes) async {
    if (notes == null) return;

    state = {...state, for (var note in notes) note.id!: note};
  }

  Future<int> createRecipeNote(RecipeNote note) async {
    final created = await _recipeNoteService.createRecipeNote(note);

    state = {...state, created.id!: created};

    return created.id!;
  }

  Future<RecipeNote> updateRecipeNote(int noteId, String content) async {
    final updated = await _recipeNoteService.updateRecipeNote(noteId, content);

    state = {...state, noteId: updated};

    return updated;
  }

  Future<void> deleteRecipeNote(int noteId) async {
    await _recipeNoteService.deleteRecipeNote(noteId);
    final newState = Map<int, RecipeNote>.from(state);
    newState.remove(noteId);
    state = newState;
  }
}

final recipeNoteByIdProvider = FutureProvider.family<RecipeNote, int>((
  ref,
  noteId,
) async {
  return ref.read(recipeNoteProvider.notifier).getById(noteId);
});
