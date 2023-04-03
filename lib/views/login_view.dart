import 'package:flutter/material.dart';
import 'package:personalnotes/constants/routes.dart';
import 'package:personalnotes/services/auth/auth_exceptions.dart';
import 'package:personalnotes/services/auth/auth_service.dart';
import 'package:personalnotes/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 30),
              child: TextField(
                controller: _email,
                decoration: const InputDecoration(
                    hintText: 'Enter your email here',
                    border: OutlineInputBorder()),
                enableSuggestions: true,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 30),
              child: TextField(
                controller: _password,
                decoration: const InputDecoration(
                    hintText: 'Enter your password here',
                    border: OutlineInputBorder()),
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;

                  try {
                    await AuthService.firebase().login(
                      email: email,
                      password: password,
                    );
                    final user = AuthService.firebase().currentUser;

                    if (user?.isEmailVerified ?? false) {
                      // User is verified
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        notesRoute,
                        (_) => false,
                      );
                    } else {
                      // User is not verified
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        verifyEmailRoute,
                        (_) => false,
                      );
                    }
                  } on UserNotFoundAuthException {
                    await showErrorDialog(
                      context,
                      'User Not Found',
                    );
                  } on WrongPasswordAuthException {
                    await showErrorDialog(
                      context,
                      'Wrong Credentials',
                    );
                  } on GenericAuthException {
                    await showErrorDialog(
                      context,
                      'Authetication Error',
                    );
                  }
                },
                child: const Text('Login'),
              ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    registerRoute,
                    (route) => false,
                  );
                },
                child: const Text('Not Registered yet? Register here'))
          ],
        ),
      ),
    );
  }
}
