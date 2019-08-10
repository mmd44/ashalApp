import 'dart:io';

import 'package:ashal/core/models/sync_meter_reading_response.dart';
import 'package:ashal/core/shared_perferences.dart';
import 'package:ashal/core/database.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/models/amount_collection.dart';
import 'package:ashal/core/models/meter_reading.dart';
import 'package:ashal/core/models/sync_client_response.dart';
import 'package:ashal/core/network/api.dart';
import 'package:ashal/core/network/client_service.dart';
import 'package:ashal/core/network/discovery_socket.dart';
import 'package:ashal/core/network/network_setup.dart';


class SyncController implements SocketCallBack {
  bool _readings=false;
  bool _collection=false;

  SyncCallBack _syncCallBack;
  bool canSend=true;
  bool get readings => _readings;
  bool get collection => _collection;

  bool isLoading = false;

  set collection(bool value) {
    _collection = value;
  }

  set readings(bool value) {
    _readings = value;
  }

  SyncController(this._syncCallBack, this._readings, this._collection) {
    DBProvider.db.databaseInit;
  }
//  Future dummy() async {
//    await DBProvider.db.reCreateDatabase();
//
//    await DBProvider.db.insertMeterReading(MeterReading(
//        date: DateTime.now(),
//        meterImage: "123213213121",
//        reading: 1232,
//        referenceId: 4444));
//    await DBProvider.db.insertMeterReading(MeterReading(
//        date: DateTime.now(),
//        meterImage: "1111",
//        reading: 1,
//        referenceId: 66666));
//    await DBProvider.db.insertMeterReading(MeterReading(
//        date: DateTime.now(),
//        meterImage: "2222",
//        reading: 2,
//        referenceId: 55555));
//    await DBProvider.db.insertMeterReading(MeterReading(
//        date: DateTime.now(),
//        meterImage: "333",
//        reading: 3,
//        referenceId: 33333));
//    await DBProvider.db.insertMeterReading(MeterReading(
//        date: DateTime.now(),
//        meterImage: "444",
//        reading: 5,
//        referenceId: 22222));
//    await DBProvider.db.insertMeterReading(MeterReading(
//        date: DateTime.now(),
//        meterImage: "555",
//        reading: 4,
//        referenceId: 11111));
//
//    await DBProvider.db.insertAmountCollection(AmountCollection(
//        referenceId: 1111,
//        amount: 2,
//        date: DateTime.now(),
//        multiplePayment: false));
//    await DBProvider.db.insertAmountCollection(AmountCollection(
//        referenceId: 1111,
//        amount: 2,
//        date: DateTime.now(),
//        multiplePayment: false));
//    await DBProvider.db.insertAmountCollection(AmountCollection(
//        referenceId: 1111,
//        amount: 2,
//        date: DateTime.now(),
//        multiplePayment: false));
//    await DBProvider.db.insertAmountCollection(AmountCollection(
//        referenceId: 1111,
//        amount: 2,
//        date: DateTime.now(),
//        multiplePayment: false));
//    await DBProvider.db.insertAmountCollection(AmountCollection(
//        referenceId: 1111,
//        amount: 2,
//        date: DateTime.now(),
//        multiplePayment: false));
//    await DBProvider.db.insertAmountCollection(AmountCollection(
//        referenceId: 1111,
//        amount: 2,
//        date: DateTime.now(),
//        multiplePayment: false));
//
//    List<Client> l=new List();
//    l.add(Client.from('1', 2, 'test', true, true,
//        DateTime.now(), null, '03030303'));
//    l.add(Client.from('1', 234, 'test', true, true,
//        DateTime.now(), null, '03040404'));
//    l.add(Client.from('1', 4564, 'test', true, true,
//        DateTime.now(), null, '03040404'));
//    l.add(Client.from('1', 1234, 'test', true, true,
//        DateTime.now(), null, '03040404'));
//    l.add(Client.from('1', 1222, 'test', true, true,
//        DateTime.now(), null, '03040404'));
//    DBProvider.db.insertClients(l);
//
//    List<Client> clients=await DBProvider.db.getAllClients();
//    clients.forEach((clients)=>print(clients.toJson()));
//  }


  Future getServerIp() async {
    RawDatagramSocket socket=await NetworkSocket.networkSocket.getInstance(this);
//    API.ipAddress="192.168.43.184";
//    canSend=true;
    while(API.ipAddress.isEmpty&&canSend) {
      try{
        socket.send(
            "Where-are-you-ashal?".codeUnits, InternetAddress("255.255.255.255"), 8888);
      }catch(Ex){}
      await Future.delayed(const Duration(seconds: 5));
    }
    await NetworkSocket.networkSocket.dispose();
  }

  Future syncMeterReading() async {
    if(API.ipAddress.isEmpty) {
      _syncCallBack.onSyncError("reading",'sync_general_error');
      return;
    }
    _syncCallBack.onStart("reading");
    var readings = await DBProvider.db.getAllMeterReading();
    ClientService _service = ClientService();
    print(API.reading);
    _service.syncMeterReadings(readings).then((clientSyncResponse)async {
      DBProvider.db.deleteAllMeterReading();
      syncMeterHistoryResponse(clientSyncResponse);
//      ProjectSharedPreferences.instance.setMeterReadingSync(true);
      _readings = true;
      _syncCallBack.onSyncSuccess("reading","sync_reading_success");
    }).catchError((error) {
      _readings = false;
//      ProjectSharedPreferences.instance.setMeterReadingSync(false);
      _syncCallBack.onSyncError("reading","sync_reading_error");
    });
  }

  Future syncRequests() async {
    if(API.ipAddress.isEmpty) {
      _syncCallBack.onSyncError("request","sync_general_error");
      return;
    }
    _syncCallBack.onStart("request");
    var requests = await DBProvider.db.getAllRequest();
    ClientService _service = ClientService();
    print(API.reading);
    _service.syncRequests(requests).then((res)async {
      if("ok".compareTo(res)==0)
      {
          DBProvider.db.deleteAllRequest();
          _syncCallBack.onSyncSuccess("request","sync_requests_success");
      }else{
        _syncCallBack.onSyncError("request","sync_requests_error");
      }

    }).catchError((error) {
      _syncCallBack.onSyncError("request","sync_requests_error");
    });
  }

  Future syncCollection() async {
    if(API.ipAddress.isEmpty) {
      _syncCallBack.onSyncError("collection","sync_general_error");
      return;
    }
    _syncCallBack.onStart("collection");
    _collection = false;
    var collections = await DBProvider.db.getAllMeterCollection();
    ClientService _service = ClientService();
    print(API.collection);
    _service.syncMeterCollection(collections).then((clientSyncResponse)async {
      if("ok".compareTo(clientSyncResponse)==0)
      {
          DBProvider.db.deleteAllMeterCollection();
          //      ProjectSharedPreferences.instance.setCollectionSync(true);
          _syncCallBack.onSyncSuccess("collection","sync_collection_success");
      }else{
        _syncCallBack.onSyncError("collection","sync_collection_error");
      }
    }).catchError((error) {
//      ProjectSharedPreferences.instance.setCollectionSync(false);
      print('errorClientService $error');
      _syncCallBack.onSyncError("collection","sync_collection_error");
    });
  }

  Future clearMeterData() async {

    if(API.ipAddress.isEmpty)
      return;
    collection = await ProjectSharedPreferences.instance.isCollectionSync();
    readings = await ProjectSharedPreferences.instance.isMeterReadingSync();
    if (collection && readings) {
      int dbVersion = await ProjectSharedPreferences.instance.getDataBaseVersion();
      bool success =
          await ProjectSharedPreferences.instance.setDataBaseVersion(dbVersion + 1);
      if (success) {
        await ProjectSharedPreferences.instance.setMeterReadingSync(false);
        await ProjectSharedPreferences.instance.setCollectionSync(false);
        await DBProvider.db.changeDatabaseVesion();
        collection = false;
        readings = false;
      }
    }
    await syncClients();
  }

  Future syncClients() async {
    if(API.ipAddress.isEmpty) {
      _syncCallBack.onSyncError("client","sync_general_error");
      return null;
    }
    _syncCallBack.onStart("client");
    ClientService _service = ClientService();
    print(API.client);
    //syncClientHistoryResponse(_service.syncClientsTest());
    _service.syncClients().then((clientSyncResponse) async {
      syncClientHistoryResponse(clientSyncResponse);
      _syncCallBack.onSyncSuccess("client","sync_client_success");
    }).catchError((error) {
      print('errorClientService $error');
      _syncCallBack.onSyncError("client","sync_client_error");
    });
  }

  syncMeterHistoryResponse(MeterSyncResponse clientSyncResponse) async
  {
    await DBProvider.db.deleteAllHistory();
    await DBProvider.db.insertHistory(clientSyncResponse.history);
  }

  syncClientHistoryResponse(ClientSyncResponse clientSyncResponse) async
  {
    await DBProvider.db.deleteAllClient();
    await DBProvider.db.deleteAllHistory();
    await DBProvider.db.insertClients(clientSyncResponse.client);
    await DBProvider.db.insertHistory(clientSyncResponse.history);
  }

  @override
  void onFoundAddress(String address) {
    NetworkSocket.networkSocket.dispose();
    setupNetwork (address);
    _syncCallBack.onConnect();
  }

  void dispose() async {
    NetworkSocket.networkSocket.dispose();
    canSend=false;
  }

  void setupNetwork(String host){
    API.ipAddress=host;
    NetworkSetup networkSetup = NetworkSetup();
    networkSetup.setNetworkHeaders();
  }
}

abstract class SyncCallBack {
  void onSyncSuccess(String fromButton,String msg);
  void onSyncError(String fromButton,String msg);
  void onConnect();
  void onStart(String from);
}
