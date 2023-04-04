import 'dart:math';

import 'package:personalnotes/services/auth/auth_exceptions.dart';
import 'package:personalnotes/services/auth/auth_provider.dart';
import 'package:personalnotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authetication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, isFalse);
    });

    test('Cannot logout if not initialized', () async {
      expect(provider.logout(), throwsA(isA<NotInitializedException>()));
    });

    test('Should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, isTrue);
    });

    test('User should be null after initialization', () {
      expect(provider.currentUser, isNull);
    });

    test('Should be able to initialize in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('Create user should delegate to login function', () async {
      final badEmailUser = provider.createUser(
        email: 'foo@bar.com',
        password: 'anypassword',
      );

      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPasswordUser = provider.createUser(
        email: 'someone@bar.com',
        password: 'foobar',
      );

      expect(badPasswordUser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(
        email: 'test',
        password: 'foadhd',
      );

      expect(provider.currentUser, user);
      expect(user.isEmailVerified, isFalse);
    });

    test('Logged in user should be able to get verified', () async {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, isTrue);
    });

    test('Should be able to log out and log in again', () async {
      await provider.logout();
      expect(provider.currentUser, isNull);
      final user = await provider.login(
        email: 'email',
        password: 'password',
      );
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return login(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logout() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
