import 'dart:io';

import 'package:ashal/core/controllers/shared_perferences.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/models/meter_collection.dart';
import 'package:ashal/core/models/meter_reading.dart';
import 'package:ashal/core/network/api_exception.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final String CLIENT_TABLE = 'client';
  static final String METER_READING_TABLE = 'meter_reading';
  static final String METER_COLLECTION_TABLE = 'meter_collection';
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database == null) _database = await initDB();
    // Delete the database
    return _database;
  }

  reCreateDatabase() async {
    await DBProvider.db.database;
    if (_database != null) {
      var result = await deleteDatabase(_database.path);
      await _database.close();
      _database = null;
    }
    await DBProvider.db.database;
  }

  changeDatabaseVesion() async {
    if (_database != null) {
      await _database.close();
      _database = null;
    }
    await reCreateDatabase();
  }

  dropDatabase() async {
    if (_database != null) {
      var result = await deleteDatabase(_database.path);
      await _database.close();
      _database = null;
    }
  }

  createTables(Database db) async {
    await db.execute('CREATE TABLE `$CLIENT_TABLE` (`id` TEXT NOT NULL,'
        '`referenceId` INTEGER NOT NULL PRIMARY KEY,'
        '`category` VARCHAR(100),'
        '`organizationName` VARCHAR(100),'
        '`sharedDescription` VARCHAR(100),'
        '`prefix` VARCHAR(100),'
        '`firstName` VARCHAR(100),'
        '`familyName` VARCHAR(100),'
        '`name` VARCHAR(100),'
        '`area` VARCHAR(100),'
        '`streetAddress` VARCHAR(100),'
        '`building` VARCHAR(100),'
        '`floor` INTEGER,'
        '`phone` VARCHAR(100),'
        '`email` VARCHAR(100),'
        '`meterId` VARCHAR(100),'
        '`deleted` BOOLEAN,'
        '`purged` BOOLEAN,'
        '`dateTimeAdded` INTEGER,'
        '`dateTimeDeleted` INTEGER,'
        '`outstanding` DOUBLE,'
        '`comment` VARCHAR(100));');
    await db.execute('CREATE TABLE `$METER_READING_TABLE` ('
        '`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'
        '`referenceId` INTEGER NOT NULL,'
        '`reading` DOUBLE,'
        '`meterImage` TEXT,'
        '`date` INTEGER);');
    await db.execute('CREATE TABLE `$METER_COLLECTION_TABLE` ('
        '`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'
        '`referenceId` INTEGER NOT NULL,'
        '`amount` DOUBLE,'
        '`multiplePayment` BOOLEAN DEFAULT \'false\','
        '`date` INTEGER);');
  }



  initDB() async {
    int dbVersion = await ProjectSharedPreferences.getDataBaseVersion();
    print("DATA BASE VESION $dbVersion");
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "ashal-$dbVersion.db");
    bool temp = await ProjectSharedPreferences.isMeterReadingSync();
    temp = await ProjectSharedPreferences.isCollectionSync();
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await createTables(db);
    });
  }

  Future<int> insertClient(Client newUser) async {
    final db = await database;
    var res = await db.insert("$CLIENT_TABLE", newUser.toJson());
    return res;
  }

  Future<bool> insertClients(List<Client> clients) async {
    var batch = _database.batch();
    clients.forEach((client)=> batch.insert("$CLIENT_TABLE", client.toJson()));
    List<dynamic> results = await batch.commit();
    if(results.length<clients.length)
      throw new APIException("database.insert_clients", "Insert Error Clients");
    return true;
  }

  Future<Client> getClient(int referenceId) async {
    final db = await database;
    var res = await db.query("$CLIENT_TABLE",
        where: "referenceId = ?",
        whereArgs: [referenceId]); //ToDo removed a check
    return res.isNotEmpty ? Client.fromJson(res.first) : null;
  }

  Future<List<Client>> getClients(String startWith) async {
    if (startWith == null || startWith.isEmpty) return [];
    final db = await database;
    var res = await db.rawQuery(
        "SELECT * FROM $CLIENT_TABLE WHERE referenceId LIKE '$startWith%';");
    return res.isNotEmpty ? res.map((c) => Client.fromJson(c)).toList() : [];
  }

  Future<List<Client>> getAllClients() async {
    final db = await database;
    var res = await db.query("$CLIENT_TABLE");
    return res.isNotEmpty ? res.map((c) => Client.fromJson(c)).toList() : [];
  }

  Future<int> updateClient(Client newClient) async {
    final db = await database;
    var res = await db.update("$CLIENT_TABLE", newClient.toJson(),
        where: "id = ?", whereArgs: [newClient.id]);
    return res;
  }

  Future<int> deleteClient(int id) async {
    final db = await database;
    return db.delete("$CLIENT_TABLE", where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteAllClient() async {
    final db = await database;
    return db.rawDelete("Delete from $CLIENT_TABLE");
  }

  Future<int> insertMeterReading(MeterReading newUser) async {
    final db = await database;
    var res = await db.insert("`$METER_READING_TABLE`", newUser.toJson());
    if(res<=0)
      throw new APIException("database.insert_meter_readin_error", "");
    return res;
  }

  Future<MeterReading> getMeterReading(int referenceId) async {
    final db = await database;
    var res = await db.query("$METER_READING_TABLE",
        where: "referenceId = ?", whereArgs: [referenceId]);
    return res.isNotEmpty ? MeterReading.fromJson(res.first) : null;
  }

  Future<List<MeterReading>> getAllMeterReading() async {
    final db = await database;
    var res = await db.query("$METER_READING_TABLE");
    return res.isNotEmpty
        ? res.map((c) => MeterReading.fromJson(c)).toList()
        : [];
  }

  Future<int> updateMeterReading(MeterReading newMeterReadingModel) async {
    final db = await database;
    var res = await db.update(
        "$METER_READING_TABLE", newMeterReadingModel.toJson(),
        where: "referenceId = ?",
        whereArgs: [newMeterReadingModel.referenceId]);
    return res;
  }

  Future<int> deleteMeterReading(int referenceId) async {
    final db = await database;
    return db.delete("$METER_READING_TABLE",
        where: "referenceId = ?", whereArgs: [referenceId]);
  }

  Future<int> deleteAllMeterReading() async {
    final db = await database;
    return db.rawDelete("Delete from $METER_READING_TABLE");
  }

  Future<int> insertAmountCollection(
      AmountCollection newMeterCollectionModel) async {
    final db = await database;
    int res = await db.insert(
        "`$METER_COLLECTION_TABLE`", newMeterCollectionModel.toJson());
    if(res<=0)
      throw new APIException("database.insert_meter_collection_error", "");
    return res;
  }

  Future<AmountCollection> getMeterCollection(int referenceId) async {
    final db = await database;
    var res = await db.query("$METER_COLLECTION_TABLE",
        where: "referenceId = ?", whereArgs: [referenceId]);
    print(res.first);
    return res.isNotEmpty ? AmountCollection.fromJson(res.first) : null;
  }

  Future<List<AmountCollection>> getAllMeterCollection() async {
    final db = await database;
    var res = await db.query("$METER_COLLECTION_TABLE");
    return res.isNotEmpty
        ? res.map((c) => AmountCollection.fromJson(c)).toList()
        : [];
  }

  Future<int> updateMeterCollection(
      AmountCollection newMeterCollectionModel) async {
    final db = await database;
    var res = await db.update(
        "$METER_COLLECTION_TABLE", newMeterCollectionModel.toJson(),
        where: "referenceId = ?",
        whereArgs: [newMeterCollectionModel.referenceId]);
    return res;
  }

  Future<int> deleteMetereCollection(int referenceId) async {
    final db = await database;
    return db.delete("$METER_COLLECTION_TABLE",
        where: "referenceId = ?", whereArgs: [referenceId]);
  }

  Future<int> deleteAllMeterCollection() async {
    final db = await database;
    return db.rawDelete("Delete from $METER_COLLECTION_TABLE");
  }
}
