import 'dart:io';

import 'package:ashal/core/shared_perferences.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/models/amount_collection.dart';
import 'package:ashal/core/models/history.dart';
import 'package:ashal/core/models/meter_reading.dart';
import 'package:ashal/core/models/request.dart';
import 'package:ashal/core/network/api_exception.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final String CLIENT_TABLE = 'client';
  static final String HISTORY_TABLE = 'history';
  static final String METER_READING_TABLE = 'meter_reading';
  static final String METER_COLLECTION_TABLE = 'meter_collection';
  static final String REQUEST_TABLE = 'request';
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get databaseInit async {
    if (_database == null) _database = await initDB();
    // Delete the database
    return _database;
  }

  reCreateDatabase() async {
    await DBProvider.db.databaseInit;
    if (_database != null) {
      var result = await deleteDatabase(_database.path);
      await _database.close();
      _database = null;
    }
    await DBProvider.db.databaseInit;
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

  String receiptIssued;
  String category;
  var meterReader;
  var collector;
  List<String> payers;
  createTables(Database db) async {
    await db.execute('CREATE TABLE `$HISTORY_TABLE` (`id` TEXT NOT NULL,'
        '`historyId` TEXT NOT NULL PRIMARY KEY,'
        '`entryDateTime` INTEGER,'
        '`parentId` INTEGER,'
        '`subType` VARCHAR(800),'
        '`amp` INTEGER,'
        '`flatPrice` DOUBLE,'
        '`oldMeter` DOUBLE,'
        '`newMeter` DOUBLE,'
        '`subscription` VARCHAR(800),'
        '`discount` DOUBLE,'
        '`lineStatus` TEXT,'
        '`prepaid` TEXT,'
        '`bill` DOUBLE,'
        '`dependentsBill` DOUBLE,'
        '`collected` DOUBLE,'
        '`forgiven` BOOLEAN DEFAULT \'false\','
        '`receiptIssued` VARCHAR(800),'
        '`category` VARCHAR(800),'
        '`meterReader` VARCHAR(800),'
        '`collector` VARCHAR(800),'
        '`payers` TEXT);');
    await db.execute('CREATE TABLE `$CLIENT_TABLE` ('
        '`id` TEXT,'
        '`referenceId` INTEGER NOT NULL PRIMARY KEY,'
        '`category` VARCHAR(800),'
        '`organizationName` VARCHAR(800),'
        '`sharedDescription` VARCHAR(800),'
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
        '`comment` VARCHAR(800),'
        '`monthlyDataReferences` TEXT);');
    await db.execute('CREATE TABLE `$METER_READING_TABLE` ('
        '`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'
        '`referenceId` INTEGER NOT NULL,'
        '`reading` DOUBLE,'
        '`subType` TEXT,'
        '`lineStatus` TEXT,'
        '`prepaid` TEXT,'
        '`amp` INTEGER,'
        '`meterImage` TEXT,'
        '`date` INTEGER);');
    await db.execute('CREATE TABLE `$METER_COLLECTION_TABLE` ('
        '`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'
        '`referenceId` INTEGER NOT NULL,'
        '`historyId` TEXT,'
        '`amount` DOUBLE,'
        '`date` INTEGER);');

    await db.execute('CREATE TABLE `$REQUEST_TABLE` ('
        '`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'
        '`referenceId` INTEGER NOT NULL,'
        '`lineStatus` TEXT,'
        '`amp` INTEGER,'
        '`subType` TEXT,'
        '`comment` TEXT,'
        '`prepaid` TEXT,'
        '`date` INTEGER);');
  }

  initDB() async {
    int dbVersion =
        await ProjectSharedPreferences.instance.getDataBaseVersion();
    print("DATA BASE VESION $dbVersion");
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "ashal-$dbVersion.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await createTables(db);
    });
  }

  Future<int> insertClient(Client newUser) async {
    final db = await databaseInit;
    var res = await db.insert("$CLIENT_TABLE", newUser.toJson());
    return res;
  }

  Future<bool> insertClients(List<Client> clients) async {
    var batch = _database.batch();
    clients.forEach((client) => batch.insert("$CLIENT_TABLE", client.toJson()));
    List<dynamic> results = await batch.commit();
    if (results.length < clients.length)
      throw new APIException("database.insert_clients", "Insert Error Clients");
    return true;
  }

  Future<Client> getClient(int referenceId) async {
    final db = await databaseInit;
    var res = await db.query("$CLIENT_TABLE",
        where: "referenceId = ?",
        whereArgs: [referenceId]);
    return res.isNotEmpty ? Client.fromJson(res.first) : null;
  }

  Future<List<Client>> getClients(String startWith) async {
    if (startWith == null || startWith.isEmpty) return [];
    final db = await databaseInit;
    var res = await db.rawQuery(
        "SELECT * FROM $CLIENT_TABLE WHERE referenceId LIKE '$startWith%';");
    return res.isNotEmpty ? res.map((c) => Client.fromJson(c)).toList() : [];
  }

  Future<List<Client>> getAllClients() async {
    final db = await databaseInit;
    var res = await db.query("$CLIENT_TABLE");
    return res.isNotEmpty ? res.map((c) => Client.fromJson(c)).toList() : [];
  }

  Future<int> updateClient(Client newClient) async {
    final db = await databaseInit;
    var res = await db.update("$CLIENT_TABLE", newClient.toJson(),
        where: "id = ?", whereArgs: [newClient.id]);
    return res;
  }

  Future<int> deleteClient(int id) async {
    final db = await databaseInit;
    return db.delete("$CLIENT_TABLE", where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteAllClient() async {
    final db = await databaseInit;
    return db.rawDelete("Delete from $CLIENT_TABLE");
  }

  Future<int> insertMeterReading(MeterReading newMeterReading) async {
    final db = await databaseInit;
    var res =
        await db.insert("`$METER_READING_TABLE`", newMeterReading.toJson());
    if (res <= 0)
      throw new APIException("database.insert_meter_readin_error", "");
    return res;
  }

  Future<MeterReading> getMeterReading(int referenceId) async {
    final db = await databaseInit;
    var res = await db.query("$METER_READING_TABLE",
        where: "referenceId = ?", whereArgs: [referenceId]);
    return res.isNotEmpty ? MeterReading.fromJson(res.first) : null;
  }

  Future<List<MeterReading>> getAllMeterReading() async {
    final db = await databaseInit;
    var res = await db.query("$METER_READING_TABLE");
    return res.isNotEmpty
        ? res.map((c) => MeterReading.fromJson(c)).toList()
        : [];
  }

  Future<int> updateMeterReading(MeterReading newMeterReadingModel) async {
    final db = await databaseInit;
    var res = await db.update(
        "$METER_READING_TABLE", newMeterReadingModel.toJsonUpdate(),
        where: "referenceId = ?",
        whereArgs: [newMeterReadingModel.referenceId]);
    return res;
  }

  Future<int> deleteMeterReading(int referenceId) async {
    final db = await databaseInit;
    return db.delete("$METER_READING_TABLE",
        where: "referenceId = ?", whereArgs: [referenceId]);
  }

  Future<int> deleteAllMeterReading() async {
    final db = await databaseInit;
    return db.rawDelete("Delete from $METER_READING_TABLE");
  }

  Future<int> insertAmountCollection(
      AmountCollection newMeterCollectionModel) async {
    final db = await databaseInit;
    int res = await db.insert(
        "`$METER_COLLECTION_TABLE`", newMeterCollectionModel.toJson());
    if (res <= 0)
      throw new APIException("database.insert_meter_collection_error", "");
    return res;
  }

  Future<AmountCollection> getMeterCollection(int referenceId) async {
    final db = await databaseInit;
    var res = await db.query("$METER_COLLECTION_TABLE",
        where: "referenceId = ?", whereArgs: [referenceId]);
    return res.isNotEmpty ? AmountCollection.fromJson(res.first) : null;
  }

  Future<AmountCollection> getMeterCollectionByHistroyId(
      int referenceId, String histroyId) async {
    if (histroyId == null) return null;
    final db = await databaseInit;
    var res = await db.query("$METER_COLLECTION_TABLE",
        where: "referenceId = ? and historyId = ?",
        whereArgs: [referenceId, histroyId]);
    return res.isNotEmpty ? AmountCollection.fromJson(res.first) : null;
  }

  Future<List<AmountCollection>> getAllMeterCollection() async {
    final db = await databaseInit;
    var res = await db.query("$METER_COLLECTION_TABLE");
    return res.isNotEmpty
        ? res.map((c) => AmountCollection.fromJson(c)).toList()
        : [];
  }

  Future<int> updateMeterCollection(
      AmountCollection newMeterCollectionModel) async {
    final db = await databaseInit;
    var res = await db.update(
        "$METER_COLLECTION_TABLE", newMeterCollectionModel.toJson(),
        where: "referenceId = ? and historyId = ?",
        whereArgs: [newMeterCollectionModel.referenceId,newMeterCollectionModel.historyId]);
    if (res <= 0)
      throw new APIException("database.update_meter_collection_error", "");
    return res;
  }

  Future<int> deleteMetereCollection(int referenceId) async {
    final db = await databaseInit;
    return db.delete("$METER_COLLECTION_TABLE",
        where: "referenceId = ?", whereArgs: [referenceId]);
  }

  Future<int> deleteAllMeterCollection() async {
    final db = await databaseInit;
    return db.rawDelete("Delete from $METER_COLLECTION_TABLE");
  }

  Future<int> insertRequest(Request newRequest) async {
    final db = await databaseInit;
    int res = await db.insert("`$REQUEST_TABLE`", newRequest.toJson());
    if (res <= 0) throw new APIException("database.insert_request_error", "");
    return res;
  }

  Future<int> deleteAllRequest() async {
    final db = await databaseInit;
    return db.rawDelete("Delete from $REQUEST_TABLE");
  }

  Future<List<Request>> getAllRequest() async {
    final db = await databaseInit;
    var res = await db.query("$REQUEST_TABLE");
    return res.isNotEmpty ? res.map((c) => Request.fromJson(c)).toList() : [];
  }

  Future<bool> insertHistory(List<History> historyList) async {
    var batch = _database.batch();
    historyList
        .forEach((history) => batch.insert("$HISTORY_TABLE", history.toJson()));
    List<dynamic> results = await batch.commit();
    if (results.length < historyList.length)
      throw new APIException("database.insert_clients", "Insert Error Clients");
    return true;
  }

  Future<int> deleteAllHistory() async {
    final db = await databaseInit;
    return db.rawDelete("Delete from $HISTORY_TABLE");
  }

  Future<List<History>> getHistoryList(List<String> historyIdList) async {
    final db = await databaseInit;
    String ids = '\'' + historyIdList.join('\',\'') + '\'';
    var res = await db.rawQuery(
        "SELECT * FROM $HISTORY_TABLE WHERE historyId IN ($ids) ORDER BY entryDateTime DESC;");
    return res.isNotEmpty ? res.map((c) => History.fromJson(c)).toList() : [];
  }

  Future<List<History>> getHistoryListByRefId(int referenceId) async {
    final db = await databaseInit;
    var res = await db.rawQuery(
        "SELECT * FROM $HISTORY_TABLE WHERE parentId = ($referenceId) ORDER BY entryDateTime DESC;");
    return res.isNotEmpty ? res.map((c) => History.fromJson(c)).toList() : [];
  }
  Future<History> getLastHistory(int referenceId) async {
    Client client = await getClient(referenceId);
    List<History> historyList =new List<History>();
    if(client?.monthlyDataReferences != null &&
        client.monthlyDataReferences.length > 0) {
      historyList= await getHistoryList(client.monthlyDataReferences);
    }
//    List<History> historyList2 = await getHistoryListByRefId(client.referenceId);
//    historyList.addAll(historyList2);
    if (historyList.isEmpty) return null;
    History chosen = historyList[0];
    for (var i = 1; i < historyList.length; i++) {
      if (historyList[i].entryDateTime.isAfter(chosen?.entryDateTime))
        chosen = historyList[i];
    }
    return chosen;
  }

  Future<List<History>> getUnpaidHistory(int referenceId) async {
    Client client = await getClient(referenceId);
    List<History> historyList =new List<History>();
    if(client?.monthlyDataReferences != null &&
        client.monthlyDataReferences.length > 0) {
      historyList= await getHistoryList(client.monthlyDataReferences);
    }
//    List<History> historyList2 = await getHistoryListByRefId(client.referenceId);
//    if(historyList2!=null)
//      historyList=historyList2;
    if (historyList.isEmpty) return List<History>();
    List<History> unpaidHistories = new List<History>();
    List<DateTime> dates = new List();
    for (var i = 0; i < historyList.length; i++) {
      double collected = historyList[i]?.collected ?? 0;
      double bill = historyList[i]?.bill ?? 0;
      bool forgiven = historyList[i]?.forgiven ?? false;
      if (collected < bill &&
          !forgiven &&
          historyList[i].entryDateTime != null) {
        if (!dates.contains(historyList[i].entryDateTime)) {
          historyList[i].bill=historyList[i].bill-historyList[i].collected;
          dates.add(historyList[i].entryDateTime);
          unpaidHistories.add(historyList[i]);
        }
      }
    }
    return unpaidHistories;
  }
}
