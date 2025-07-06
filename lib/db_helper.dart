import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> initDb() async {
    final path = join(await getDatabasesPath(), 'tugas.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabel Tugas
        await db.execute('''
          CREATE TABLE tugas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT,
            deadline TEXT,
            selesai INTEGER
          )
        ''');

        // Tabel Jadwal
        await db.execute('''
          CREATE TABLE jadwal (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hari TEXT,
            mapel TEXT,
            jam TEXT
          )
        ''');

        // Tabel Profil
        await db.execute('''
          CREATE TABLE profil (
            id INTEGER PRIMARY KEY,
            nama TEXT,
            kelas TEXT,
            jurusan TEXT,
            status TEXT,
            foto TEXT
          )
        ''');
      },
    );
  }

  static Future<Database> get database async {
    _database ??= await initDb();
    return _database!;
  }

  // ------------------- TUGAS ---------------------
  static Future<void> insertTugas(String judul, String deadline) async {
    final db = await database;
    await db.insert('tugas', {
      'judul': judul,
      'deadline': deadline,
      'selesai': 0,
    });
  }

  static Future<List<Map<String, dynamic>>> getTugas() async {
    final db = await database;
    return db.query('tugas', orderBy: 'deadline ASC');
  }

  static Future<void> updateSelesai(int id, int selesai) async {
    final db = await database;
    await db.update('tugas', {'selesai': selesai}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteTugas(int id) async {
    final db = await database;
    await db.delete('tugas', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------- JADWAL ---------------------
  static Future<void> insertJadwal(String hari, String mapel, String jam) async {
    final db = await database;
    await db.insert('jadwal', {
      'hari': hari,
      'mapel': mapel,
      'jam': jam,
    });
  }

  static Future<List<Map<String, dynamic>>> getJadwal() async {
    final db = await database;
    return db.query('jadwal', orderBy: 'jam ASC');
  }

  static Future<void> deleteJadwal(int id) async {
    final db = await database;
    await db.delete('jadwal', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------- PROFIL ---------------------
  static Future<Map<String, dynamic>?> getProfil() async {
    final db = await database;
    final result = await db.query('profil', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  static Future<void> saveProfil(
    String nama,
    String kelas,
    String jurusan,
    String status, {
    String? foto,
  }) async {
    final db = await database;
    final existing = await getProfil();

    if (existing == null) {
        await db.insert('profil', {
        'id': 1,
        'nama': nama,
        'kelas': kelas,
        'jurusan': jurusan,
        'status': status,
        'foto': foto ?? 'assets/images/kowalski.png',
      });
    } else {
      await db.update(
        'profil',
        {
          'nama': nama,
          'kelas': kelas,
          'jurusan': jurusan,
          'status': status,
          'foto': foto ?? existing['foto'], // pertahankan foto sebelumnya jika tidak diubah
        },
        where: 'id = ?',
        whereArgs: [1],
      );
    }
  }
}
