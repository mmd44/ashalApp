import 'dart:io';

import 'package:ashal/core/controllers/shared_perferences.dart';
import 'package:ashal/core/database.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/models/meter_collection.dart';
import 'package:ashal/core/models/meter_reading.dart';
import 'package:ashal/core/network/client_service.dart';
import 'package:ashal/core/network/discovery_socket.dart';
import 'package:multicast_lock/multicast_lock.dart';

class SyncController implements SocketCallBack {
  bool _readings=false;
  bool _collection=false;

  SyncCallBack _syncCallBack;
  bool get readings => _readings;
  bool get collection => _collection;

  String _serverIpAddress;

  set collection(bool value) {
    _collection = value;
  }

  set readings(bool value) {
    _readings = value;
  }

  String get serverIpAddress => _serverIpAddress;

  SyncController(this._syncCallBack, this._readings, this._collection) {
    DBProvider.db.database;
  }
  Future dummy() async {
    await DBProvider.db.reCreateDatabase();

    await DBProvider.db.insertMeterReading(MeterReading(
        date: DateTime.now(),
        meterImage: "123213213121",
        reading: 1232,
        referenceId: 4444));
    await DBProvider.db.insertMeterReading(MeterReading(
        date: DateTime.now(),
        meterImage: "1111",
        reading: 1,
        referenceId: 66666));
    await DBProvider.db.insertMeterReading(MeterReading(
        date: DateTime.now(),
        meterImage: "2222",
        reading: 2,
        referenceId: 55555));
    await DBProvider.db.insertMeterReading(MeterReading(
        date: DateTime.now(),
        meterImage: "333",
        reading: 3,
        referenceId: 33333));
    await DBProvider.db.insertMeterReading(MeterReading(
        date: DateTime.now(),
        meterImage: "444",
        reading: 5,
        referenceId: 22222));
    await DBProvider.db.insertMeterReading(MeterReading(
        date: DateTime.now(),
        meterImage: "555",
        reading: 4,
        referenceId: 11111));

    await DBProvider.db.insertMeterCollection(MeterCollection(
        referenceId: 1111,
        amount: 2,
        date: DateTime.now(),
        multiplePayment: false));
    await DBProvider.db.insertMeterCollection(MeterCollection(
        referenceId: 1111,
        amount: 2,
        date: DateTime.now(),
        multiplePayment: false));
    await DBProvider.db.insertMeterCollection(MeterCollection(
        referenceId: 1111,
        amount: 2,
        date: DateTime.now(),
        multiplePayment: false));
    await DBProvider.db.insertMeterCollection(MeterCollection(
        referenceId: 1111,
        amount: 2,
        date: DateTime.now(),
        multiplePayment: false));
    await DBProvider.db.insertMeterCollection(MeterCollection(
        referenceId: 1111,
        amount: 2,
        date: DateTime.now(),
        multiplePayment: false));
    await DBProvider.db.insertMeterCollection(MeterCollection(
        referenceId: 1111,
        amount: 2,
        date: DateTime.now(),
        multiplePayment: false));

    List<Client> l=new List();
    l.add(Client.from('1', 2, 'test', true, true,
        DateTime.now(), null, '03030303'));
    l.add(Client.from('1', 234, 'test', true, true,
        DateTime.now(), null, '03040404'));
    l.add(Client.from('1', 4564, 'test', true, true,
        DateTime.now(), null, '03040404'));
    l.add(Client.from('1', 1234, 'test', true, true,
        DateTime.now(), null, '03040404'));
    l.add(Client.from('1', 1222, 'test', true, true,
        DateTime.now(), null, '03040404'));
    DBProvider.db.insertClients(l);

    List<Client> clients=await DBProvider.db.getAllClients();
    clients.forEach((clients)=>print(clients.toJson()));
  }


  Future getServerIp() async {
    RawDatagramSocket socket=await NetworkSocket.networkSocket.getInstance(this);
    while(_serverIpAddress==null) {
      socket.send(
          "Where-are-you-ashal?".codeUnits, InternetAddress("255.255.255.255"),
          8888);
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  Future syncMeterReading() async {
    if(_serverIpAddress==null)
      return;
    var readings = await DBProvider.db.getAllMeterReading();

    readings.forEach((m) => print(m.toJson()));
    bool success = true;
    if (success) {
      ProjectSharedPreferences.setMeterReadingSync(true);
      _readings = true;
      _syncCallBack.onMeterReadingSyncSuccess();
    } else {
      _readings = false;
      ProjectSharedPreferences.setMeterReadingSync(false);
      _syncCallBack.onMeterReadingSyncError("error");
    }
  }

  Future syncCollection() async {
    if(_serverIpAddress==null)
      return;
    var collection = await DBProvider.db.getAllMeterCollection();
    collection.forEach((f) => print(f.toJson()));

    bool success = true;
    if (success) {
      ProjectSharedPreferences.setCollectionSync(true);
      _collection = true;
      _syncCallBack.onMeterCollectionSyncSuccess();
    } else {
      _collection = false;
      ProjectSharedPreferences.setCollectionSync(false);
      _syncCallBack.onMeterCollectionSyncError("error");
    }
  }

  Future clearMeterData() async {

    if(_serverIpAddress==null)
      return;
    collection = await ProjectSharedPreferences.isCollectionSync();
    readings = await ProjectSharedPreferences.isMeterReadingSync();
    if (collection && readings) {
      int dbVersion = await ProjectSharedPreferences.getDataBaseVersion();
      bool success =
          await ProjectSharedPreferences.setDataBaseVersion(dbVersion + 1);
      if (success) {
        await ProjectSharedPreferences.setMeterReadingSync(false);
        await ProjectSharedPreferences.setCollectionSync(false);
        await DBProvider.db.changeDatabaseVesion();
        collection = false;
        readings = false;
      }
    }
    await syncClients();
  }

  Future syncClients() async {
    if(_serverIpAddress==null)
      return;
    await DBProvider.db.deleteAllClient();
    ClientService _service = ClientService();
    _service.syncClients().then((clients)async {
      await DBProvider.db.insertClients(clients);
      _syncCallBack.onClientSyncSuccess();
    }).catchError((error) {
      print('errorClientService $error');
      _syncCallBack.onClientSyncError("error");
    });
  }

  @override
  void onFoundAddress(String address) {
    _serverIpAddress=address;
    _syncCallBack.onConnect(address);
  }

  void dispose() async {
    NetworkSocket.networkSocket.dispose();
  }
}

abstract class SyncCallBack {
  void onClientSyncSuccess();
  void onClientSyncError(String msg);
  void onMeterReadingSyncSuccess();
  void onMeterReadingSyncError(String msg);
  void onMeterCollectionSyncSuccess();
  void onMeterCollectionSyncError(String msg);
  void onConnect(String serverAddressIp);
}
