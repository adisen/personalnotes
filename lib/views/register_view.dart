import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    return Padding(
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
                  final userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: email, password: password);

                  print(userCredential);
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'weak-password') {
                    print('Weak Password');
                  } else if (e.code == 'email-already-in-use') {
                    print('Email already in use');
                  } else if (e.code == 'invalid-email') {
                    print('Invalid Email');
                  }
                }
              },
              child: const Text('Register'),
            ),
          ),
        ],
      ),
    );
  }
}
