import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/async_value_handler.dart';
import 'package:frontend/features/data/models/tag.dart';
import 'package:frontend/features/providers/tag_providers.dart';

class TagEditSheet extends ConsumerStatefulWidget {
  final List<Tag>? selected;

  const TagEditSheet({super.key, this.selected});

  @override
  ConsumerState<TagEditSheet> createState() => _TagEditSheetState();
}

class _TagEditSheetState extends ConsumerState<TagEditSheet> {
  late final Set<Tag> selected;

  @override
  void initState() {
    super.initState();
    selected = widget.selected != null ? {...widget.selected!} : {};
  }

  void _createTagDialog() {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final tagsAsync = ref.watch(tagsProvider);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Neue Kategorie erstellen"),
        content: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: "Kategorie Name"),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return "Name darf nicht leer sein";
              }
              if (tagsAsync.value?.any((t) => t.name == v) ?? false) {
                return "Diesen Namen gibt es bereits";
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Abbrechen"),
          ),
          ElevatedButton(
            onPressed: () async {
              bool success = await _tryCreateTag(controller.text.trim());
              if (success && mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("Erstellen"),
          ),
        ],
      ),
    );
  }

  Future<bool> _tryCreateTag(String name) async {
    if (name.isEmpty) return false;

    try {
      await ref.read(tagServiceProvider).createTag(name);
      ref.invalidate(tagsProvider);
    } catch (e) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 16;

    return SafeArea(
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(),
            const SizedBox(height: 12),
            _tagList(),
            const SizedBox(height: 16),
            _actions(context),
          ],
        ),
      ),
    );
  }

  Widget _header() => Row(
    children: [
      const Expanded(
        child: Text(
          "Tags auswählen",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      IconButton(
        icon: const Icon(Icons.add),
        tooltip: "Neuen Tag erstellen",
        onPressed: _createTagDialog,
      ),
    ],
  );

  Widget _tagList() {
    final tagsAsync = ref.watch(tagsProvider);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        child: AsyncValueHandler(
          asyncValue: tagsAsync,
          onData: (tags) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              final isSelected = selected.contains(tag);

              return FilterChip(
                label: Text(tag.name),
                selected: isSelected,
                onSelected: (v) {
                  setState(() => v ? selected.add(tag) : selected.remove(tag));
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _actions(BuildContext context) => Row(
    children: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Abbrechen"),
      ),
      const Spacer(),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, selected.toList()),
        child: const Text("Übernehmen"),
      ),
    ],
  );
}
