import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/auth/auth_providers.dart';
import 'package:frontend/core/network/api_client_provider.dart';
import 'package:frontend/features/data/models/user.dart';
import 'package:frontend/features/presentation/pages/login_page.dart';
import 'package:frontend/features/presentation/pages/profile_page.dart';
import 'package:frontend/features/presentation/shared/async_image_widget.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void onClickProfile(BuildContext context, User? user) {
    if (user == null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Einstellungen")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListView(
          children: [
            _ProfileCard(
              user: auth.user,
              onClickProfile: () => onClickProfile(context, auth.user),
            ),
            const Divider(),
            _ApiClientActions(),
            const Divider(),
            _ActionsSection(
              isLoggedIn: auth.isAuthenticated,
              onLogout: ref.read(authProvider.notifier).logout,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final User? user;
  final VoidCallback onClickProfile;

  const _ProfileCard({required this.user, required this.onClickProfile});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onClickProfile,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: user != null
              ? _content()
              : ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.person),
                  ),
                  title: const Text("Nicht eingeloggt"),
                  subtitle: const Text("Melde dich an, um dein Konto zu sehen"),
                ),
        ),
      ),
    );
  }

  Widget _content() {
    return ListTile(
      leading: AsyncImageWidget(
        imageId: user?.avatarId,
        placeholder: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person),
        ),
        onData: (image) => CircleAvatar(
          radius: 30,
          backgroundImage: FileImage(File(image.path)),
          backgroundColor: Colors.grey.shade200,
        ),
      ),
      title: Row(
        children: [
          Text(
            user!.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(width: 8),

          // Admin Badge
          if (user!.role == "admin")
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.1),
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Admin',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(user!.email ?? ""),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _ApiClientActions extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ApiClientActionsState();
}

class _ApiClientActionsState extends ConsumerState<_ApiClientActions> {
  late final controller = TextEditingController(
    text: ref.read(apiClientProvider).baseUrl,
  );
  String? _errorText;

  bool _isValidUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  void _onChanged(String value) {
    setState(() => _errorText = _isValidUrl(value) ? null : "Ungültige URL");
  }

  void _save() {
    if (_errorText != null) return;

    ref.read(apiClientProvider).baseUrl = controller.text.trim();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Gespeichert")));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("API Base URL", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onChanged: _onChanged,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: "https://api.example.com",
            errorText: _errorText,
            prefixIcon: const Icon(Icons.link),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: _errorText == null ? _save : null,
            child: const Text("Speichern"),
          ),
        ),
      ],
    );
  }
}

class _ActionsSection extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback onLogout;

  const _ActionsSection({required this.isLoggedIn, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isLoggedIn)
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Abmelden", style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Möchtest du dich wirklich abmelden?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Abbrechen"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                onLogout();
              }
            },
          ),
      ],
    );
  }
}
