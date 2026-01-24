import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/auth/auth_providers.dart';
import 'package:frontend/core/auth/auth_state.dart';
import 'package:frontend/features/presentation/pages/register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  final bool closeOnLogin;

  const LoginPage({super.key, this.closeOnLogin = true});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      await ref
          .read(authProvider.notifier)
          .login(_userController.text, _passwordController.text);

      if (mounted && widget.closeOnLogin) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openRegisterPage() {
    if (widget.closeOnLogin) Navigator.pop(context);

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterPage()));
  }

  void _continueAsGuest() {
    ref.read(authProvider.notifier).continueAsGuest();

    if (widget.closeOnLogin) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    String? errorText = switch (auth.failure) {
      AuthFailure.invalidCredentials => "Benutzername oder Passwort ist falsch",
      AuthFailure.sessionExpired =>
        "Deine Sitzung ist abgelaufen. Bitte melde dich erneut an.",
      AuthFailure.networkError =>
        "Netzwerkfehler. Bitte versuche es später erneut.",
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text("Login"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Anmelden",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),

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
                decoration: const InputDecoration(
                  labelText: "Benutzername",
                  prefixIcon: Icon(Icons.perm_identity),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Passwort",
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              FilledButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Login"),
              ),
              const SizedBox(height: 32),

              TextButton(
                onPressed: _openRegisterPage,
                child: const Text("Noch kein Account? Registiere dich hier"),
              ),
              TextButton(
                onPressed: _continueAsGuest,
                child: const Text("Ohne Login fortfahren"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
