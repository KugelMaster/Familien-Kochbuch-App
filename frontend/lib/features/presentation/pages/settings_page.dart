import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/auth/auth_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void onClickProfile() {
    print("Clicked profile card!");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final notifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("Einstellungen")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListView(
          children: [
            _ProfileCard(
              username: auth.username,
              pfpId: auth.pfpId,
              isAdmin: auth.isAdmin,
              onClickProfile: onClickProfile,
            ),
            //_AccountSection(auth: auth),
            const Divider(),
            _ActionsSection(onLogout: notifier.logout),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String? username;
  final String? email = "not-yet-implemented@lol.com";
  final int? pfpId;
  final bool? isAdmin;

  final VoidCallback onClickProfile;

  const _ProfileCard({
    required this.username,
    required this.pfpId,
    required this.isAdmin,
    required this.onClickProfile,
  });

  @override
  Widget build(BuildContext context) {
    final username = this.username ?? "<Benutzername>";
    final email = this.email ?? "<Email-Adresse>";
    final isAdmin = this.isAdmin ?? false;

    final isLoggedIn = this.username != null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onClickProfile,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: isLoggedIn
              ? ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    // TODO: Use avatar picture
                    backgroundImage: AssetImage("assets/images/Felix PFP.jpg"),
                    backgroundColor: Colors.grey[200],
                  ),
                  title: Row(
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Admin Badge
                      if (isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
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
                  subtitle: Text(email),
                  trailing: const Icon(Icons.chevron_right),
                )
              : ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.person),
                  ),
                  title: const Text("Nicht eingeloggt"),
                  subtitle: const Text("Melde dich an, um dein Konto zu sehen"),
                ),
        ),
      ),
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
