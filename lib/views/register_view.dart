import 'package:flutter/material.dart';
import 'package:personalnotes/constants/routes.dart';
import 'package:personalnotes/services/auth/auth_exceptions.dart';
import 'package:personalnotes/services/auth/auth_service.dart';
import 'package:personalnotes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text('Register')),
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
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
              child: ElevatedButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;

                  try {
                    await AuthService.firebase().createUser(
                      email: email,
                      password: password,
                    );

                    await AuthService.firebase().sendEmailVerification();
                    Navigator.of(context).pushNamed(verifyEmailRoute);
                  } on WeakPasswordAuthException {
                    await showErrorDialog(
                      context,
                      'Weak Password',
                    );
                  } on EmailAlreadyInUseAuthException {
                    await showErrorDialog(
                      context,
                      'Email is already in use',
                    );
                  } on InvalidEmailAuthException {
                    await showErrorDialog(
                      context,
                      'This is an invalid Email Address',
                    );
                  } on GenericAuthException {
                    await showErrorDialog(
                      context,
                      'Registration Failed',
                    );
                  }
                },
                child: const Text('Register'),
              ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                },
                child: const Text('Already Registered? Login here'))
          ],
        ),
      ),
    );
  }
}
