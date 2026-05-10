// lib/core/services/cache_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CacheService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, 'livego_cache.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  static Future<void> _createDB(Database db, int version) async {
    // 1. Tabel Continue Watching (Riwayat Menonton dengan koordinat menit/detik terakhir)
    await db.execute('''
      CREATE TABLE watch_history (
        drama_id TEXT NOT NULL,
        episode_id TEXT NOT NULL,
        platform TEXT NOT NULL,
        title TEXT NOT NULL,
        poster TEXT NOT NULL,
        episode_number INTEGER NOT NULL,
        position_ms INTEGER NOT NULL,
        duration_ms INTEGER NOT NULL,
        last_watched INTEGER NOT NULL,
        PRIMARY KEY (drama_id, platform)
      )
    ''');

    // 2. Tabel Favorit (Watchlist) per Platform
    await db.execute('''
      CREATE TABLE favorites (
        drama_id TEXT NOT NULL,
        platform TEXT NOT NULL,
        title TEXT NOT NULL,
        poster TEXT NOT NULL,
        added_at INTEGER NOT NULL,
        PRIMARY KEY (drama_id, platform)
      )
    ''');
  }

  // ==================== OPERASI CONTINUE WATCHING ====================
  
  // Simpan atau perbarui riwayat menonton
  static Future<void> saveWatchHistory(Map<String, dynamic> history) async {
    final db = await database;
    await db.insert(
      'watch_history',
      history,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Ambil semua daftar "Continue Watching" diurutkan dari yang paling baru ditonton
  static Future<List<Map<String, dynamic>>> getWatchHistory() async {
    final db = await database;
    return await db.query('watch_history', orderBy: 'last_watched DESC');
  }

  // Ambil detail riwayat spesifik drama untuk fitur "Resume Prompt" saat player dibuka
  static Future<Map<String, dynamic>?> getProgress(String dramaId, String platform) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'watch_history',
      where: 'drama_id = ? AND platform = ?',
      whereArgs: [dramaId, platform],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Hapus riwayat jika user menandai selesai (di atas 90% durasi) atau menghapus manual
  static Future<void> deleteHistory(String dramaId, String platform) async {
    final db = await database;
    await db.delete(
      'watch_history',
      where: 'drama_id = ? AND platform = ?',
      whereArgs: [dramaId, platform],
    );
  }

  // ==================== OPERASI FAVORIT ====================

  static Future<void> addFavorite(Map<String, dynamic> drama) async {
    final db = await database;
    await db.insert(
      'favorites',
      drama,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> removeFavorite(String dramaId, String platform) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'drama_id = ? AND platform = ?',
      whereArgs: [dramaId, platform],
    );
  }

  static Future<bool> isFavorite(String dramaId, String platform) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'drama_id = ? AND platform = ?',
      whereArgs: [dramaId, platform],
    );
    return maps.isNotEmpty;
  }
}
