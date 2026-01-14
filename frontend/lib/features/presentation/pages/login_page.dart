import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/auth/auth_providers.dart';
import 'package:frontend/core/auth/auth_state.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final notifier = ref.read(authProvider.notifier);

    String? errorText = switch (auth.failure) {
      AuthFailure.invalidCredentials => "Benutzername oder Passwort ist falsch",
      AuthFailure.sessionExpired =>
        "Deine Sitzung ist abgelaufen. Bitte melde dich erneut an.",
      AuthFailure.networkError =>
        "Netzwerkfehler. Bitte versuche es später erneut.",
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  errorText,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: "Benutzername"),
            ),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Passwort"),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                notifier.login(_userController.text, _passController.text);
              },
              child: const Text("Login"),
            ),

            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const RegisterPage()));
              },
              child: const Text("Noch kein Account? Registiere dich hier"),
            ),
            TextButton(
              onPressed: () {
                ref.read(authProvider.notifier).continueAsGuest();
              },
              child: const Text("Ohne Login fortfahren"),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrieren")),
      body: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Schließen"),
        ),
      ),
    );
  }
}
