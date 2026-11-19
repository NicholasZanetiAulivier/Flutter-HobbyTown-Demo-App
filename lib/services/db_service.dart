import 'package:hobby_town_demo/models/address.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbService {
  static Future<Database> openAppDatabase() async {
    // Android: /data/data/<package>/databases, iOS and macOS: Documents.
    var path = join(await getDatabasesPath(), 'app.db');
    return openDatabase(
      path,
      // Increment the version (and handle it in onUpgrade) on schema changes.
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE addresses ('
          'id INTEGER PRIMARY KEY,'
          'first_name TEXT NOT NULL,'
          'last_name TEXT NOT NULL,'
          'phone TEXT NOT NULL,'
          'address TEXT NOT NULL,'
          'post_code TEXT NOT NULL,'
          'pin_point_lat REAL NOT NULL,'
          'pin_point_lng REAL NOT NULL'
          ')',
        );
      },
    );
  }

  static Future<List<ShippingAddress>> getAddresses() async {
    Database db = await openAppDatabase();
    List<Map<String, Object?>> rows = await db.query('addresses');
    return rows
        .map((row) {
          return ShippingAddress.fromRow(row);
        })
        .toList(growable: false);
  }
}
