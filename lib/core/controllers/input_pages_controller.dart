import 'dart:convert';
import 'dart:io';

import 'package:ashal/core/database.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/models/meter_collection.dart';
import 'package:ashal/core/models/meter_reading.dart';

class InputPagesController {
  final int maxInputDigits = 8;

  MeterCollection _meterCollection;
  MeterReading _meterReading;

  Client _client;

  String referenceID;

  InputPageView _view;

  bool isLoading = false;

  bool get isCollectionValid =>
      _meterReading?.referenceId != null &&
      _meterReading?.reading != null &&
      _meterReading?.meterImage != null;

  InputPagesController(InputPageView view) : _view = view;

  Client get client => _client;

  String get clientArea => _client?.area;
  String get clientStreet => _client?.streetAddress;
  String get clientBldg => _client?.building;
  String get clientFloor => _client?.floor;
  String get clientPhone => _client?.phone;

  init() {
    //setupDB();
    _meterReading = MeterReading();
  }

  initDummy() async {
    await DBProvider.db.reCreateDatabase();

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

  void setClientByReference() {
    int id;

    if (referenceID != null) {
      id = int.tryParse(referenceID);
    }

    if (id != null) {
      DBProvider.db.getClient(id).then((client) {
        _client = client;
        _meterReading.referenceId = id;
        _view.onSetClientSuccess();
      }).catchError((error) {
        print('DBGetClientError: $error');
        _view.onSetClientError('Client Not Found');
      });
    } else {
      _client = null;
      _meterReading.referenceId = null;
      _view.onSetClientError('Invalid ID');
    }
  }

  void setupDB() async {
    await DBProvider.db.reCreateDatabase();
  }

  void setImage(File image) {
    List<int> imageBytes = image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    _meterReading.meterImage = base64Image;
  }

  void setReadings(String value) {
    double readings;
    if (value != null) {
      readings = double.tryParse(value);
    }
    if (readings != null) {
      _meterReading.reading = readings;
    } else {
      _view.onReadingsError('Invalid Readings');
    }
  }
}

abstract class InputPageView {
  void onSetClientSuccess();
  void onSetClientError(String msg);
  void onReadingsError(String msg);
  void onSuccess();
  void onError();
}
