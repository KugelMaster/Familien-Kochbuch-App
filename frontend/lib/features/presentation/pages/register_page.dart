import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/auth/auth_providers.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _nameError;

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final username = _nameController.text.trim();
      final password = _passwordController.text;
      final email = _emailController.text.trim();

      final errorCode = await ref
          .read(authProvider.notifier)
          .createUser(
            username: username,
            password: password,
            email: email.isNotEmpty ? email : null,
          );

      if (errorCode == "USERNAME_EXISTS") {
        _nameError = "Dieser Name existiert bereits!";
        _formKey.currentState!.validate();
        return;
      } else if (errorCode != null) {
        _nameError = "Unbekannter Fehler: $errorCode";
        _formKey.currentState!.validate();
        return;
      }

      if (mounted) Navigator.pop(context);

      await ref.read(authProvider.notifier).login(username, password);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrieren"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Account erstellen",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _nameController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      prefixIcon: Icon(Icons.perm_identity),
                    ),
                    onChanged: (_) => _nameError = null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Gib einen Namen ein";
                      }
                      return _nameError;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "E-Mail",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value != null && value.isEmpty) return null;
                      if (value == null ||
                          !RegExp(
                            r"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}",
                            caseSensitive: false,
                          ).hasMatch(value)) {
                        return "Ungültige E-Mail-Adresse";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Passwort",
                      prefixIcon: const Icon(Icons.lock_outline),
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Gib ein Passwort ein";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _confirmPasswordController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    obscureText: _obscurePassword,
                    decoration: const InputDecoration(
                      labelText: "Passwort bestätigen",
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return "Passwörter stimmen nicht überein";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Registrieren"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
