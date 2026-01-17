import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/auth/auth_providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;

  @override
  void initState() {
    super.initState();

    final user = ref.read(authProvider).user;
    nameCtrl = TextEditingController(text: user?.name);
    emailCtrl = TextEditingController(text: user?.email);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
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
            _avatarBox(),
            const SizedBox(height: 32),

            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "E-Mail"),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).updateProfile(
                  name: nameCtrl.text,
                  email: emailCtrl.text,
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
                // TODO: Passwort ändern
                // ref.read(authProvider.notifier).changePassword(...)
              },
              child: const Text("Passwort ändern"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarBox() {
    return Center(
      child: GestureDetector(
        onTap: () {
          print("Profile Pic clicked!");
        },
        child: Stack(
          children: [
            CircleAvatar(
              radius: 128,
              backgroundImage: AssetImage("assets/images/Felix PFP.jpg"),
              backgroundColor: Colors.grey.shade200,
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
                child: const Icon(Icons.camera_alt_outlined, size: 40,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
