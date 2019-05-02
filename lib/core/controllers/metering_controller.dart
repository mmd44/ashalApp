import 'dart:convert';
import 'dart:io';
import 'package:ashal/core/controllers/collection_controller.dart';
import 'package:ashal/core/database.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/models/history.dart';
import 'package:ashal/core/models/meter_reading.dart';
import 'package:ashal/ui/models/card_item.dart';

class MeteringController {
  final int maxInputDigits = 8;

  MeterReading _meterReading;

  Client _client;
  History _clientLastHistory;

  String referenceID;

  InputPageView _view;

  bool isLoading = false;
  bool isValidAMPField = false;
  bool isValidReading = false;

  File meterImageFile;

  DateTime todayDate;

  MeteringController(CardItem cardItem, InputPageView view) : _view = view;

  Client get client => _client;
  History get lastHistory => _clientLastHistory;

  String get clientArea => _client?.area;
  String get clientStreet => _client?.streetAddress;
  String get clientBldg => _client?.building;
  String get clientFloor => _client?.floor.toString();
  String get clientPhone => _client?.phone;

  init() {
    setupDB();
    initDummy();
    resetFields();
  }

  initDummy() async {
    await DBProvider.db.reCreateDatabase();

    await DBProvider.db.insertClient(Client.from(
        id: '1',
        referenceId: 2222,
        prefix: 'Mr',
        firstName: 'John',
        familyName: 'Whick',
        organizationName: 'Ashal Co',
        sharedDescription: 'Cafe Near Road',
        area: 'Ashrafieh',
        streetAddress: 'Independence Str',
        building: 'Queen',
        floor: 10,
        category: 'Individual',
        deleted: true,
        purged: true,
        dateTimeAdded: DateTime.now(),
        dateTimeDeleted: DateTime.now(),
        phone: '70300673',
        monthlyDataReferences: ['ref1', 'ref2']));

    await DBProvider.db.insertClient(Client.from(
      id: '2',
      referenceId: 2345,
      category: 'test',
      deleted: true,
      purged: true,
      dateTimeAdded: DateTime.now(),
      dateTimeDeleted: DateTime.now(),
      phone: '03030303',
    ));

    await DBProvider.db.insertClient(Client.from(
      id: '3',
      referenceId: 4564,
      category: 'test',
      deleted: true,
      purged: true,
      dateTimeAdded: DateTime.now(),
      dateTimeDeleted: DateTime.now(),
      phone: '03030303',
    ));

    await DBProvider.db.insertClient(Client.from(
        id: '4',
        referenceId: 1234,
        category: 'test',
        deleted: true,
        purged: true,
        dateTimeAdded: DateTime.now(),
        dateTimeDeleted: DateTime.now(),
        phone: '03030303',
        monthlyDataReferences: ['ref1', 'ref2']));

    await DBProvider.db.insertClient(Client.from(
      id: '5',
      referenceId: 1232,
      category: 'test',
      deleted: true,
      purged: true,
      dateTimeAdded: DateTime.now(),
      dateTimeDeleted: DateTime.now(),
      phone: '03030303',
    ));

    await DBProvider.db.insertClient(Client.from(
        id: '6',
        referenceId: 1222,
        category: 'test',
        deleted: true,
        purged: true,
        dateTimeAdded: DateTime.now(),
        dateTimeDeleted: DateTime.now(),
        phone: '03030303',
        monthlyDataReferences: ['ref1', 'ref2']),
    );


    ///Dummy History
    await DBProvider.db.insertHistory([
      History.from(
        id: '1',
        historyId: 'ref1',
        entryDateTime: DateTime.now(),
        parentId: 2,
        subType: SubscriptionType('Metered'),
        amp: 20,
        lineStatus: 'on',
        prepaid: 'no',
        oldMeter: 170,
        newMeter: 270,
        payers: ['Ali', 'Hussein'],
      ),
    ]);
  }

  bool get isMeteringValid => (referenceID?.isNotEmpty ?? false) &&
      ((isSubMetered &&
              _meterReading?.reading != null &&
              _meterReading?.meterImage != null) ||
          !isSubMetered) &&
      _meterReading?.subType != null &&
      _meterReading?.lineStatus != null &&
      _meterReading?.amp != null;

  set meteringDate(DateTime dateTime) {
    todayDate = dateTime;
    _meterReading.date = dateTime;
  }

  set lineStatus(bool val) {
    switch (val) {
      case true:
        _meterReading.lineStatus = 'on';
        break;
      case false:
        _meterReading.lineStatus = 'off';
        break;
    }
  }

  set amp(int val) {
    if (val != null && val >= 0) {
      _meterReading.amp = val;
      isValidAMPField = true;
    } else {
      _meterReading.amp = null;
      isValidAMPField = false;
    }
  }

  String get ampStr => _meterReading?.amp?.toString() ?? '';

  set subType(SubscriptionType val) {
    _meterReading.subType = val;
    if (!isSubMetered) {
      _meterReading.meterImage = null;
      _meterReading.reading = null;
    }
  }

  SubscriptionType get subType => _meterReading?.subType ?? null;

  set isPrepaid(String val) => _meterReading.prepaid = val;
  String get isPrepaid => _meterReading?.prepaid ?? '';

  String get oldMetering => _clientLastHistory?.oldMeter?.toString() ?? '';

  double get newMetering => _meterReading?.reading;

  bool get isTypePrepaid => [SubscriptionType.amp,SubscriptionType.flat].contains(_meterReading?.subType);

  bool get isSubMetered => _meterReading?.subType==SubscriptionType.meter;

  get lineStatus {
    if (_meterReading?.lineStatus == null) return false;
    switch (_meterReading?.lineStatus) {
      case 'on':
        return true;
      case 'off':
        return false;
    }
  }

  void setClientByReference(String ref) {
    resetFields();
    referenceID = ref;
    int id = int.tryParse(referenceID);
    if (id != null) {
      DBProvider.db.getClient(id).then((client) {
        _client = client;
        _meterReading.referenceId = id;
        if (_client?.monthlyDataReferences != null &&
            _client.monthlyDataReferences.length > 0)
          return DBProvider.db.getLastHistory(id);
        else
          return null;
      }).then((history) {
        print('history $history');
        if (history != null) setupHistoryFields(history);
        _view.onSetClientSuccess();
      }).catchError((error) {
        print('DBGetClient: ${error.toString()}');
        resetFields();
        _view.onError(error.toString());
      });
    } else {
      _view.onError(null);
      resetFields();
    }
  }

  void setupDB() async {
    await DBProvider.db.initDB();
  }

  void setImage(File image) {
    meterImageFile = image;
    List<int> imageBytes = image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    _meterReading.meterImage = base64Image;
  }

  void setNewMetering(String value) {
    double input;
    if (value != null) {
      input = double.tryParse(value);
    }
    if (input != null && input >= (_clientLastHistory?.oldMeter ?? 0)) {
      isValidReading = true;
      _meterReading.reading = input;
      _view.onSuccess(null);
    } else {
      _meterReading.reading = null;
      isValidReading = false;
      _view.onError(null, initTextControllers: false);
    }
  }

  void submit() {
    isLoading = true;
    insertReading();
  }

  void insertReading() {
    DBProvider.db.insertMeterReading(_meterReading).then((result) {
      _view.onSuccess('reading_success');
    }).catchError((error) {
      print('DBinsertReadingError: $error');
      _view.onError('reading_error');
    }).whenComplete(() {
      isLoading = false;
    });
  }

  void resetFields() {
    referenceID = null;
    meterImageFile = null;
    _client = null;
    _clientLastHistory = null;
    _meterReading = MeterReading();
    meteringDate = DateTime.now();
  }

  void setupHistoryFields(History history) {
    _clientLastHistory = history;
    subType = history.subType;
    amp = history.amp;
    isPrepaid = history.prepaid;
    _meterReading.lineStatus = history.lineStatus;
  }
}
