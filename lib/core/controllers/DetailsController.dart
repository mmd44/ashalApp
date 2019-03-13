import 'package:ashal/core/database.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/models/meter_collection.dart';
import 'package:ashal/core/models/meter_reading.dart';

class DetailsController {

  final int maxInputDigits = 8;

  MeterCollection _meterCollection;
  MeterReading _meterReading;

  DetailsController();

  init () async {

    await DBProvider.db.reCreateDatabase();

    await DBProvider.db.insertClient(Client.dummy('1',2, 'test', true, true, DateTime.now(),DateTime.now()));
    await DBProvider.db.insertClient(Client.dummy('1',234, 'test', true, true, DateTime.now(),DateTime.now()));
    await DBProvider.db.insertClient(Client.dummy('1',4564, 'test', true, true, DateTime.now(),DateTime.now()));
    await DBProvider.db.insertClient(Client.dummy('1',1234, 'test', true, true, DateTime.now(),DateTime.now()));
    await DBProvider.db.insertClient(Client.dummy('1',1232, 'test', true, true, DateTime.now(),DateTime.now()));
    await DBProvider.db.insertClient(Client.dummy('1',1222, 'test', true, true, DateTime.now(),DateTime.now()));
  }

}