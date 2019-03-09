import 'dart:io';

import 'package:ashal/ClientModel.dart';
import 'package:ashal/MeterCollectionModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ashal/MeterReadingModel.dart';


class DBProvider {
  DBProvider._();
  static final String CLIENT_TABLE='client';
  static final String METER_READING_TABLE='meter_reading';
  static final String METER_COLLECTION_TABLE='meter_collection';
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database == null) _database = await initDB();
    // Delete the database
    return _database;
  }

  dropDatabase() async {
    if (_database != null) var result = await deleteDatabase(_database.path);
  }

  createTables(Database db) async {
    await db.execute('CREATE TABLE `$CLIENT_TABLE` (`id` TEXT NOT NULL,'
        '`referenceId` INT,'
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
        '`floor` INT,'
        '`phone` VARCHAR(100),'
        '`email` VARCHAR(100),'
        '`meterId` VARCHAR(100),'
        '`deleted` BOOLEAN,'
        '`purged` BOOLEAN,'
        '`dateTimeAdded` DATETIME,'
        '`dateTimeDeleted` DATETIME,'
        '`outstanding` DOUBLE,'
        '`comment` VARCHAR(100),'
        'PRIMARY KEY (`id`,`referenceId`));');
    await db.execute('CREATE TABLE `$METER_READING_TABLE` ('
        '`id` INT unsigned NOT NULL AUTO_INCREMENT,'
        '`referenceId` INT,'
        '`reading` DOUBLE,'
        '`meter_image` TEXT,'
        '`date` DATETIME,'
        '	PRIMARY KEY (`id`,`referenceId`));');
    await db.execute( 'CREATE TABLE `$METER_COLLECTION_TABLE` ('
        '`id` INT unsigned NOT NULL AUTO_INCREMENT,'
        '`referenceId` INT,'
        '`amount` DOUBLE,'
        '`multiple_payment` BOOLEAN DEFAULT \'false\','
        '`date` DATETIME,'
        'PRIMARY KEY (`id`,`referenceId`));');
  }

  batchTransaction() async {
    var batch = _database.batch();
    batch.insert('Test', {'name': 'item'});
    batch.update('Test', {'name': 'new_item'},
        where: 'name = ?', whereArgs: ['item']);
    batch.delete('Test', where: 'name = ?', whereArgs: ['item']);
    var results = await batch.commit();
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "ashal.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
            await createTables(db);
        });
  }

  insertClient(ClientModel newUser) async {
    final db = await database;
    var res = await db.insert("`client`", newUser.toJson());
    return res;
  }

  getClient(int referenceId) async {
    final db = await database;
    var res = await db.query("$CLIENT_TABLE", where: "referenceId = ? and dateTimeDeleted IS NULL", whereArgs: [referenceId]);
    return res.isNotEmpty ? ClientModel.fromJson(res.first) : Null;
  }

  getAllClients() async {
    final db = await database;
    var res = await db.query("$CLIENT_TABLE");
    List<ClientModel> list =
        res.isNotEmpty ? res.map((c) => ClientModel.fromJson(c)).toList() : [];
    return list;
  }

  updateClient(ClientModel newClient) async {
    final db = await database;
    var res = await db.update("$CLIENT_TABLE", newClient.toJson(),
        where: "id = ?", whereArgs: [newClient.id]);
    return res;
  }

  deleteClient(int id) async {
    final db = await database;
    db.delete("$CLIENT_TABLE", where: "id = ?", whereArgs: [id]);
  }

  deleteAllClient() async {
    final db = await database;
    db.rawDelete("Delete * from $CLIENT_TABLE");
  }



  insertMeterReading(MeterReadingModel newUser) async {
    final db = await database;
    var res = await db.insert("`$METER_READING_TABLE`", newUser.toJson());
    return res;
  }

  getMeterReading(int referenceId) async {
    final db = await database;
    var res = await db.query("$METER_READING_TABLE", where: "referenceId = ?", whereArgs: [referenceId]);
    return res.isNotEmpty ? MeterReadingModel.fromJson(res.first) : Null;
  }

  getAllMeterReading() async {
    final db = await database;
    var res = await db.query("$METER_READING_TABLE");
    List<ClientModel> list =
    res.isNotEmpty ? res.map((c) => MeterReadingModel.fromJson(c)).toList() : [];
    return list;
  }

  updateMeterReading(MeterReadingModel newMeterReadingModel) async {
    final db = await database;
    var res = await db.update("$METER_READING_TABLE", newMeterReadingModel.toJson(),
        where: "id = ?", whereArgs: [newMeterReadingModel.id]);
    return res;
  }

  deleteMeterReading(int referenceId) async {
    final db = await database;
    db.delete("$METER_READING_TABLE", where: "referenceId = ?", whereArgs: [referenceId]);
  }

  deleteAllMeterReading() async {
    final db = await database;
    db.rawDelete("Delete * from $METER_READING_TABLE");
  }

  insertMeterCollection(MeterCollectionModel newUser) async {
    final db = await database;
    var res = await db.insert("`$METER_COLLECTION_TABLE`", newUser.toJson());
    return res;
  }

  getMeterCollection(int referenceId) async {
    final db = await database;
    var res = await db.query("$METER_COLLECTION_TABLE", where: "referenceId = ?", whereArgs: [referenceId]);
    return res.isNotEmpty ? MeterReadingModel.fromJson(res.first) : Null;
  }

  getAllMeterCollection() async {
    final db = await database;
    var res = await db.query("$METER_COLLECTION_TABLE");
    List<ClientModel> list =
    res.isNotEmpty ? res.map((c) => MeterCollectionModel.fromJson(c)).toList() : [];
    return list;
  }

  updateMeterCollection(MeterReadingModel newMeterReadingModel) async {
    final db = await database;
    var res = await db.update("$METER_COLLECTION_TABLE", newMeterReadingModel.toJson(),
        where: "referenceId = ?", whereArgs: [newMeterReadingModel.referenceId]);
    return res;
  }

  deleteMetereCollection(int referenceId) async {
    final db = await database;
    db.delete("$METER_COLLECTION_TABLE", where: "referenceId = ?", whereArgs: [referenceId]);
  }

  deleteAllMeterCollection() async {
    final db = await database;
    db.rawDelete("Delete * from $METER_COLLECTION_TABLE");
  }
}
