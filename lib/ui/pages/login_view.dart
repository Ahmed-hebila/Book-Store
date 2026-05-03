import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../widgets/app_input.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final email = TextEditingController(text: 'ahmed@email.com');
  final password = TextEditingController(text: '12345678');
  final name = TextEditingController();
  String selectedRole = 'customer'; 
  bool loading = false;
  bool registerMode = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.menu_book_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  registerMode ? 'Create an account' : 'Welcome Back',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                if (registerMode) ...[
                  AppInput(controller: name, hint: 'Full Name'),
                  const SizedBox(height: 16),
                ],
                AppInput(
                  controller: email,
                  hint: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                ),
                AppInput(
                  controller: password,
                  hint: 'Password',
                  obscure: true,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: loading ? null : _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            registerMode ? 'Sign Up' : 'Login',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => registerMode = !registerMode),
                  child: Text(
                    registerMode ? 'Have an account? Login' : 'New user? Regester here',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAuth() async {
    try {
      setState(() => loading = true);
      final app = context.read<AppState>();
      if (registerMode) {
        await app.register(name.text, email.text, password.text, role: selectedRole);
      } else {
        await app.login(email.text, password.text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception:', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}
