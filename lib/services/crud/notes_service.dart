import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectory implements Exception {}

class DatabaseIsNotOpen implements Exception {}

class CouldNotDeleteUser implements Exception {}

class UserAlreadyExists implements Exception {}

class CouldNotFindUser implements Exception {}

class NotesService {
  Database? _db;

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      userTable,
      limit: 1,
      where: '$emailColumn ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: '$emailColumn ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final id = await db.insert(
      userTable,
      {
        emailColumn: email.toLowerCase(),
      },
    );

    return DatabaseUser(
      id: id,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final dbPath = await getApplicationDocumentsDirectory();
      final path = join(dbPath.path, dbName);
      final db = await openDatabase(path);
      _db = db;

      // Create user table
      await _db!.execute('''
        CREATE TABLE IF NOT EXISTS $userTable (
          $idColumn INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT ,
          $emailColumn TEXT NOT NULL UNIQUE
        )
      ''');

      // Create note table
      await _db!.execute('''
        CREATE TABLE IF NOT EXISTS $noteTable (
          $idColumn INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT ,
          $textColumn TEXT,
          $userIdColumn INTEGER NOT NULL,
          FOREIGN KEY ($userIdColumn) REFERENCES $userTable ($idColumn)
        )
      ''');
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : this(
          id: map[idColumn] as int,
          email: map[emailColumn] as String,
        );

  @override
  String toString() {
    return 'Person, ID= $id, Email= $email';
  }

  @override
  bool operator ==(covariant DatabaseUser other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final String text;
  final int userId;

  DatabaseNote({
    required this.id,
    required this.text,
    required this.userId,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : this(
          id: map[idColumn] as int,
          text: map[textColumn] as String,
          userId: map[userIdColumn] as int,
        );

  @override
  String toString() {
    return 'Note, ID= $id, User ID= $userId, Text= $text,';
  }

  @override
  bool operator ==(covariant DatabaseNote other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

const idColumn = 'id';
const emailColumn = 'email';
const textColumn = 'text';
const userIdColumn = 'user_id';
const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
