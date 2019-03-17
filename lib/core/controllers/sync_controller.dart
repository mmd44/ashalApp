import 'package:ashal/core/controllers/shared_perferences.dart';
import 'package:ashal/core/database.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/models/meter_collection.dart';
import 'package:ashal/core/models/meter_reading.dart';

class SyncController
{
  bool _readings;
  bool _collection;
  SyncCallBack _syncCallBack;
  bool get readings => _readings;

  bool get collection => _collection;

  set collection(bool value) {
    _collection = value;
  }
  set readings(bool value) {
    _readings = value;
  }

  SyncController(this._syncCallBack,this._readings, this._collection){
    DBProvider.db.database;
  }
  Future dummy() async
  {
    await DBProvider.db.reCreateDatabase();

    await DBProvider.db.insertMeterReading(MeterReading(date: DateTime.now(),
        meterImage: "123213213121",
        reading: 1232,
        referenceId: 4444));
    await DBProvider.db.insertMeterReading(MeterReading(date: DateTime.now(),
        meterImage: "1111",
        reading: 1,
        referenceId: 66666));
    await DBProvider.db.insertMeterReading(MeterReading(date: DateTime.now(),
        meterImage: "2222",
        reading: 2,
        referenceId: 55555));
    await DBProvider.db.insertMeterReading(MeterReading(date: DateTime.now(),
        meterImage: "333",
        reading: 3,
        referenceId: 33333));
    await DBProvider.db.insertMeterReading(MeterReading(date: DateTime.now(),
        meterImage: "444",
        reading: 5,
        referenceId: 22222));
    await DBProvider.db.insertMeterReading(MeterReading(date: DateTime.now(),
        meterImage: "555",
        reading: 4,
        referenceId: 11111));


    await DBProvider.db.insertMeterCollection(
        MeterCollection(1111, 2, DateTime.now(), false));
    await DBProvider.db.insertMeterCollection(
        MeterCollection(1111, 2, DateTime.now(), false));
    await DBProvider.db.insertMeterCollection(
        MeterCollection(1111, 2, DateTime.now(), false));
    await DBProvider.db.insertMeterCollection(
        MeterCollection(1111, 2, DateTime.now(), false));
    await DBProvider.db.insertMeterCollection(
        MeterCollection(1111, 2, DateTime.now(), false));
    await DBProvider.db.insertMeterCollection(
        MeterCollection(1111, 2, DateTime.now(), false));

    await DBProvider.db.insertClient(Client.from('1', 2, 'test', true, true,
        DateTime.now(), DateTime.now(), '03030303'));
    await DBProvider.db.insertClient(Client.from('1', 234, 'test', true, true,
        DateTime.now(), DateTime.now(), '03040404'));
    await DBProvider.db.insertClient(Client.from('1', 4564, 'test', true, true,
        DateTime.now(), DateTime.now(), '03040404'));
    await DBProvider.db.insertClient(Client.from('1', 1234, 'test', true, true,
        DateTime.now(), DateTime.now(), '03040404'));
    await DBProvider.db.insertClient(Client.from('1', 1232, 'test', true, true,
        DateTime.now(), DateTime.now(), '03040404'));
    await DBProvider.db.insertClient(Client.from('1', 1222, 'test', true, true,
        DateTime.now(), DateTime.now(), '03040404'));
  }

  Future syncMeterReading() async
  {
    var readings = await DBProvider.db.getAllMeterReading();

    readings.forEach((m)=>print(m.toJson()));
    bool success=true;
    if(success) {
      ProjectSharedPreferences.setMeterReadingSync(true);
      _readings = true;
      _syncCallBack.onMeterReadingSyncSuccess();
    }else{
      _readings=false;
      ProjectSharedPreferences.setMeterReadingSync(false);
      _syncCallBack.onMeterReadingSyncError("error");
    }
  }

  Future syncCollection() async {
    var collection = await DBProvider.db.getAllMeterCollection();
    collection.forEach((f)=>print(f.toJson()));

    bool success=true;
    if(success) {
      ProjectSharedPreferences.setCollectionSync(true);
      _collection=true;
      _syncCallBack.onMeterCollectionSyncSuccess();
    }else{
      _collection=false;
      ProjectSharedPreferences.setCollectionSync(false);
      _syncCallBack.onMeterCollectionSyncError("error");
    }
  }

  Future clearMeterData()  async
  {
    collection=await ProjectSharedPreferences.isCollectionSync();
    readings=await ProjectSharedPreferences.isMeterReadingSync();
    if(collection&&readings) {
      int dbVersion=await ProjectSharedPreferences.getDataBaseVersion();
      bool success=await ProjectSharedPreferences.setDataBaseVersion(dbVersion+1);
      if(success)
      {
        await ProjectSharedPreferences.setMeterReadingSync(false);
        await ProjectSharedPreferences.setCollectionSync(false);
        await DBProvider.db.changeDatabaseVesion();
        collection=false;
        readings=false;
      }
    }
    await syncClients();
  }

  Future syncClients() async
  {
    await DBProvider.db.deleteAllClient();

    bool success=true;
    if(success) {
      _syncCallBack.onClientSyncSuccess();
    }else{
      _syncCallBack.onClientSyncError("error");
    }
  }


}

abstract class SyncCallBack {
  void onClientSyncSuccess();
  void onClientSyncError(String msg);
  void onMeterReadingSyncSuccess();
  void onMeterReadingSyncError(String msg);
  void onMeterCollectionSyncSuccess();
  void onMeterCollectionSyncError(String msg);
}