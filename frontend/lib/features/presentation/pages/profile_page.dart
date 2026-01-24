import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/auth/auth_providers.dart';
import 'package:frontend/features/presentation/shared/async_image_widget.dart';
import 'package:frontend/features/presentation/shared/image_picker_sheet.dart';
import 'package:frontend/features/presentation/shared/prompts.dart';
import 'package:frontend/features/providers/image_providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final confirmed = await Prompts.openDeleteDialog(
      context: context,
      title: "Konto löschen",
      content:
          "Möchtest du wirklich dein gesamtes Konto löschen? Dabei gehen Daten verloren, die ich im Moment nicht weiß, welche es sind...",
    );

    if (!confirmed) return;

    await ref.read(authProvider.notifier).deleteProfile();

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AvatarBox(),
            const SizedBox(height: 32),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "E-Mail"),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                ref
                    .read(authProvider.notifier)
                    .updateProfile(
                      name: _nameController.text,
                      email: _emailController.text,
                    );
              },
              child: const Text("Änderungen speichern"),
            ),

            const SizedBox(height: 32),
            const Divider(),

            Text("Sicherheit", style: textTheme.titleMedium),
            const SizedBox(height: 8),

            OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const _ChangePasswordDialog(),
                );
              },
              child: const Text("Passwort ändern"),
            ),

            FilledButton(
              onPressed: _deleteAccount,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Konto löschen"),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarBox extends ConsumerWidget {
  const _AvatarBox();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Center(
      child: GestureDetector(
        onTap: () async {
          final image = await pickUserImage(context);

          if (image == null) return;

          final id = await ref
              .read(imageRepositoryProvider.notifier)
              .uploadImage(image, "avatar");

          ref.read(authProvider.notifier).updateProfile(avatarId: id);
        },
        child: Stack(
          children: [
            AsyncImageWidget(
              imageId: auth.user?.avatarId,
              placeholder: CircleAvatar(
                radius: 128,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person),
              ),
              onData: (image) => CircleAvatar(
                radius: 128,
                backgroundImage: FileImage(File(image.path)),
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white),
                ),
                child: const Icon(Icons.camera_alt_outlined, size: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final currentPasswordCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool obscureCurrentPassword = true;
  bool obscurePassword = true;

  bool currentPasswordCorrect = true;
  bool get passwordsMatch =>
      passwordCtrl.text.isNotEmpty && passwordCtrl.text == confirmCtrl.text;

  @override
  void dispose() {
    currentPasswordCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Passwort ändern"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: currentPasswordCtrl,
            obscureText: obscureCurrentPassword,
            decoration: InputDecoration(
              labelText: "Aktuelles Passwort",
              errorText: currentPasswordCorrect
                  ? null
                  : "Das Passwort ist falsch",
              suffixIcon: IconButton(
                icon: Icon(
                  obscureCurrentPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(
                    () => obscureCurrentPassword = !obscureCurrentPassword,
                  );
                },
              ),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
          TextField(
            controller: passwordCtrl,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: "Neues Passwort",
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => obscurePassword = !obscurePassword);
                },
              ),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: confirmCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Passwort bestätigen",
              errorText: confirmCtrl.text.isEmpty || passwordsMatch
                  ? null
                  : "Passwörter stimmen nicht überein",
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Abbrechen"),
        ),
        FilledButton(
          onPressed: () async {
            if (!passwordsMatch) return;

            final correct = await ref
                .read(authProvider.notifier)
                .updatePassword(currentPasswordCtrl.text, passwordCtrl.text);

            setState(() => currentPasswordCorrect = correct);

            if (correct && context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text("Speichern"),
        ),
      ],
    );
  }
}
