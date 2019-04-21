import 'package:ashal/core/database.dart';
import 'package:ashal/core/models/amount_collection.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/models/history.dart';
import 'package:ashal/ui/models/card_item.dart';

class CollectionController {
  AmountCollection _collection;

  Client _client;
  History _clientLastHistory;

  String referenceID;

  InputPageView _view;

  bool isLoading = false;
  bool isValidCollection = false;

  DateTime todayDate;

  CollectionController(CardItem cardItem, InputPageView view) : _view = view;

  Client get client => _client;
  History get lastHistory => _clientLastHistory;

  String get clientArea => _client?.area;
  String get clientStreet => _client?.streetAddress;
  String get clientBldg => _client?.building;
  String get clientFloor => _client?.floor;
  String get clientPhone => _client?.phone;

  init() {
    setupDB();
    initDummy();
    resetFields();
  }

  initDummy() async {
    await DBProvider.db.reCreateDatabase();

    await DBProvider.db.insertClient(Client.from(
        '1', 2, 'test', true, true, DateTime.now(), DateTime.now(), '03030303',
        monthlyDataReferences: ['ref1', 'ref2']));
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

  bool get isCollectionValid => true;

  set collectionDate(DateTime dateTime) {
    todayDate = dateTime;
    _collection.date = dateTime;
  }

  String get ampStr => _clientLastHistory?.amp?.toString() ?? '';

  String get subType => _clientLastHistory?.subType?.value ?? '';
  //ToDo add sub feeSubscriptionType get subFee => _clientLastHistory?. ?? null;

  String get discount => _clientLastHistory?.discount?.toString() ?? '';

  String get flatPrice => _clientLastHistory?.flatPrice?.toString() ?? '';

  String get isPrepaid => _clientLastHistory?.prepaid ?? '';

  String get oldMetering => _clientLastHistory?.oldMeter?.toString() ?? '';
  String get newMetering => _clientLastHistory?.newMeter?.toString() ?? '';

  bool get isSubMetered => _clientLastHistory?.subType == SubscriptionType.meter;

  bool get isSubFlatPrice => _clientLastHistory?.subType == SubscriptionType.flat;

  String get lineStatus {
    if (_clientLastHistory?.lineStatus == null) return '';
    switch (_clientLastHistory?.lineStatus) {
      case 'on':
        return 'On';
      case 'off':
        return 'Off';
    }
    return '';
  }

  void setCollection (String value) {
    double input;
    if (value != null) {
      input = double.tryParse(value);
    }
    if (input != null && input <= (_clientLastHistory?.bill ?? 0)) {
      isValidCollection = true;
      _collection.amount = input;
    } else {
      _collection.amount = null;
      isValidCollection = false;
      _view.onReadingsError(null);
    }
  }

  void setClientByReference(String ref) {
    resetFields();
    referenceID = ref;
    int id = int.tryParse(referenceID);
    if (id != null) {
      DBProvider.db.getClient(id).then((client) {
        _client = client;
        _collection.referenceId = id;
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
        resetFields();
        _view.onSetClientError(error.toString());
        print('DBGetClient: ${error.toString()}');
      });
    } else {
      _view.onSetClientError(null);
      resetFields();
    }
  }

  void setupDB() async {
    await DBProvider.db.initDB();
  }

  void submit({bypassChecks = false}) {
    if (!bypassChecks && (_client == null || referenceID == null)) {
      _view
        ..showWarningDialog(
            'Invalid reference id!\nAre you sure you want to proceed?');
    } else {
      isLoading = true;
      insertCollection();
    }
  }

  void insertCollection() {
    DBProvider.db.insertAmountCollection(_collection).then((result) {
      _view.onSuccess('Collection saved successfully!');
    }).catchError((error) {
      print('DBinsertCollectionError: $error');
      _view.onError('Failed to save collection!');
    }).whenComplete(() {
      isLoading = false;
    });
  }

  void resetFields() {
    _client = null;
    _clientLastHistory = null;
    referenceID = null;
    _collection = AmountCollection();
    collectionDate = DateTime.now();
  }

  void setupHistoryFields(History history) {
    _clientLastHistory = history;
  }
}

abstract class InputPageView {
  void onSetClientSuccess();
  void onSetClientError(String msg);
  void onReadingsError(String msg);
  void onError(String error);
  void onSuccess(String msg);
  void showWarningDialog(String msg);
}
