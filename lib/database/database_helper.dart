import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/player.dart';
import '../models/game.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('domino_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final dbFile = path.join(dbPath, filePath);

    return await openDatabase(
      dbFile,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE players (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        photoPath TEXT,
        score INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE games (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        playerIds TEXT NOT NULL,
        winnerName TEXT NOT NULL,
        winningScore INTEGER NOT NULL,
        winnerPhotoPath TEXT,
        playerScores TEXT
      )
    ''');
  }

  Future<int> insertPlayer(Player player) async {
    final db = await database;
    return await db.insert('players', player.toMap()..remove('id'));
  }

  Future<List<Player>> getAllPlayers() async {
    final db = await database;
    final result = await db.query('players');
    return result.map((map) => Player.fromMap(map)).toList();
  }

  Future<int> updatePlayer(Player player) async {
    final db = await database;
    return await db.update(
      'players',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  Future<int> deletePlayer(int id) async {
    final db = await database;
    return await db.delete(
      'players',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertGame(Game game) async {
    final db = await database;
    return await db.insert('games', game.toMap()..remove('id'));
  }

  Future<List<Game>> getAllGames() async {
    final db = await database;
    final result = await db.query('games', orderBy: 'date DESC');
    return result.map((map) => Game.fromMap(map)).toList();
  }

  Future<List<Player>> getPlayersByIds(List<int> ids) async {
    final db = await database;
    final placeholders = ids.map((_) => '?').join(',');
    final result = await db.query(
      'players',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return result.map((map) => Player.fromMap(map)).toList();
  }

  Future<String> savePhoto(File imageFile, String playerName) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${playerName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await imageFile.copy('${directory.path}/$fileName');
    return savedImage.path;
  }

  Future<void> resetGame(List<Player> players) async {
    for (var player in players) {
      player.score = 0;
      await updatePlayer(player);
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
