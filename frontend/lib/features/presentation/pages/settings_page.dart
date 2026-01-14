import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/auth/auth_providers.dart';
import 'package:frontend/core/auth/auth_state.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final notifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("Einstellungen")),
      body: ListView(
        children: [
          _AccountSection(auth: auth),
          const Divider(),
          _ActionsSection(onLogout: notifier.logout),
        ],
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  final AuthState auth;

  const _AccountSection({required this.auth});

  @override
  Widget build(BuildContext context) {
    if (auth.status != AuthStatus.authenticated) {
      return const ListTile(
        title: Text("Nicht eingeloggt"),
        subtitle: Text("Melde dich an, um dein Konto zu sehen"),
      );
    }

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text("Benutzername"),
          subtitle: Text(auth.username ?? "-"),
        ),
        ListTile(
          leading: const Icon(Icons.badge),
          title: const Text("User ID"),
          subtitle: Text(auth.userId?.toString() ?? "-"),
        ),
      ],
    );
  }
}

class _ActionsSection extends StatelessWidget {
  final VoidCallback onLogout;

  const _ActionsSection({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text("Logout", style: TextStyle(color: Colors.red)),
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Möchtest du dich wirklich abmelden?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Abbrechen'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Logout'),
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
