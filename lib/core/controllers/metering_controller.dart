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
  bool isUpdate = false;

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
    //initDummy();
    resetFields();
  }

  initDummy() async {
    await DBProvider.db.insertClient(Client.fromJsonServer({
      '_id': '1',
      'referenceId': 2222,
      'prefix': 'Mr',
      'firstName': 'John',
      'familyName': 'Whick',
      'organizationName': 'Ashal Co',
      'sharedDescription': 'Cafe Near Road',
      'area': 'Ashrafieh',
      'streetAddress': 'Independence Str',
      'building': 'Queen',
      'floor': 10,
      'category': 'Individual',
      'deleted': true,
      'purged': true,
      'dateTimeAdded': "2019-02-22T22:00:00Z",
      'dateTimeDeleted': "2019-02-22T22:00:00Z",
      'phone': '70300673',
      'monthlyData_references': ['ref1', 'ref2']
    }));

    /*await DBProvider.db.insertClient(Client.from(
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

    await DBProvider.db.insertClient(
      Client.from(
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
      History.fromJsonServer({
        '_id': '1',
        'historyId': 'ref1',
        'entryDateTime': "2019-02-22T22:00:00Z",
        'parentId': 2,
        'subType': 'Metered',
        'amp': 20,
        'lineStatus': 'on',
        'prepaid': 'no',
        'oldMeter': 170,
        'newMeter': 270,
        'payers': ['Ali', 'Hussein'],
      }),
    ]);*/

    await DBProvider.db.insertHistory([
      History.fromJsonServer({
        '_id': '_1',
        'historyId': 'ref1',
        'entryDateTime': "2019-02-22T22:00:00Z",
        'parentId': 2222,
        'subType': 'Metered',
        'flatPrice': 50000,
        'amp': 20,
        'discount': 10.0,
        'bill': 80000.0,
        'lineStatus': 'on',
        'prepaid': 'no',
        'oldMeter': 170,
        'newMeter': 270,
        'collected': 36494.0,
        'payers': ['Ali', 'Hussein'],
      }),
    ]);
  }

  bool get isMeteringValid =>
      (referenceID?.isNotEmpty ?? false) &&
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

//  set lineStatus(bool val) {
//    switch (val) {
//      case true:
//        _meterReading.lineStatus = 'on';
//        break;
//      case false:
//        _meterReading.lineStatus = 'off';
//        break;
//    }
//  }
  set lineStatus(String val) {
    _meterReading.lineStatus = val;
  }

  set amp(double val) {
    if (val != null && val >= 0) {
      _meterReading.amp = val;
      isValidAMPField = true;
    } else {
      _meterReading.amp = null;
      isValidAMPField = false;
    }
  }

  String get ampStr => _meterReading?.amp?.toString() ?? '';

  SubscriptionType get historySubType => _clientLastHistory?.subType ?? SubscriptionType.meter;
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

  bool get isTypePrepaid => [SubscriptionType.amp, SubscriptionType.flat]
      .contains(_meterReading?.subType);

  bool get isSubMetered => _meterReading?.subType == SubscriptionType.meter;

  get lineStatus {
    return _meterReading?.lineStatus;
//    if (_meterReading?.lineStatus == null) return false;
//    switch (_meterReading?.lineStatus) {
//      case 'on':
//        return true;
//      case 'off':
//        return false;
//    }
  }

  void setClientByReference(String ref) {
    resetFields();
    referenceID = ref;
    int id = int.tryParse(referenceID);
    if (id != null) {
      DBProvider.db.getClient(id).then((client) async {
        _client = client;
        _meterReading.referenceId = id;
        if (_client?.monthlyDataReferences != null &&
            _client.monthlyDataReferences.length > 0) {
          return DBProvider.db.getMeterReading(id);
        } else
          return null;
      }).then((meterReading) {
        if (meterReading == null) {
          print('historyID $id');
          return DBProvider.db.getLastHistory(id);
        } else {
          isUpdate = true;
          setupFieldsFromPreviousReading(meterReading);
          return null;
        }
      }).then((history) {
        print('history $history');
        if (history != null) {
          setupFieldsFromLastHistory(history);
          _view.onSetClientSuccess();
        } else {
          _view.onError(null);
        }
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

  void setImageFromDB(String imageBase64Str) {
    _meterReading.meterImage = imageBase64Str;
    List<int> imageBytes = base64Decode(imageBase64Str);
    File imageFile=File('/data/user/0/dakroub.com.ashal/cache/${todayDate.millisecondsSinceEpoch}.jpg');
    imageFile.writeAsBytesSync(imageBytes);
    meterImageFile = imageFile;
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
    isUpdate ? updateReading() : insertReading();
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

  void updateReading() {
    DBProvider.db.updateMeterReading(_meterReading).then((result) {
      _view.onSuccess('reading_success');
    }).catchError((error) {
      print('DBupdateReadingError: $error');
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

  void setupFieldsFromLastHistory(History history) {
    _clientLastHistory = history;
    subType = history.subType;
    amp = history.amp;
    isPrepaid = history.prepaid;
    lineStatus = history.lineStatus;
  }

  void setupFieldsFromPreviousReading(MeterReading meterReading) {
    _meterReading = MeterReading();
    _meterReading.referenceId = meterReading.referenceId;
    meteringDate = DateTime.now();
    subType = meterReading.subType;
    amp = meterReading.amp;
    isPrepaid = meterReading.prepaid;
    lineStatus = meterReading.lineStatus;

    if (meterReading.reading != null)
      setNewMetering(meterReading.reading.toString());

    if (meterReading.meterImage != null)
      setImageFromDB(meterReading.meterImage);
  }
}
