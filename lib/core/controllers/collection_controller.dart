import 'package:ashal/core/database.dart';
import 'package:ashal/core/models/amount_collection.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/models/history.dart';
import 'package:ashal/ui/models/card_item.dart';

class CollectionController {
  AmountCollection _collection;
  AmountCollection _collectedAmount;

  Client _client;
  History _clientSelectedHistory;
  List<History> clientHistoryList;
  String referenceID;

  InputPageView _view;

  bool isLoading = false;
  bool isValidCollection = false;

  DateTime todayDate;

  CollectionController(CardItem cardItem, InputPageView view) : _view = view;

  Client get client => _client;
  History get selectedHistory => _clientSelectedHistory;

  setupClientSelectedHistory(History value) async {
    _clientSelectedHistory = value;
    _collection.historyId = _clientSelectedHistory.historyId;
    _collectedAmount = await DBProvider.db.getMeterCollectionByHistroyId(
        client?.referenceId, _clientSelectedHistory?.historyId);
  }

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
        flatPrice: 50000,
        amp: 20,
        discount: 10,
        bill: 80000,
        lineStatus: 'on',
        prepaid: 'no',
        oldMeter: 170,
        newMeter: 270,
        payers: ['Ali', 'Hussein'],
      ),
    ]);
    await DBProvider.db.insertAmountCollection(AmountCollection(
        referenceId: 2,
        historyId: "ref1",
        date: DateTime.now(),
        amount: 5000,
        id: 1));
  }

  bool get isCollectionValid =>
      isValidCollection && (referenceID?.isNotEmpty ?? false);

  set collectionDate(DateTime dateTime) {
    todayDate = dateTime;
    _collection.date = dateTime;
  }

  String get ampStr => _clientSelectedHistory?.amp?.toString() ?? '';

  String get subType => _clientSelectedHistory?.subType?.value ?? '';
  //ToDo add sub feeSubscriptionType get subFee => _clientLastHistory?. ?? null;

  String get discount => _clientSelectedHistory?.discount?.toString() ?? '';

  String get flatPrice => _clientSelectedHistory?.flatPrice?.toString() ?? '';

  String get bill => _clientSelectedHistory?.bill?.toString() ?? '';

  String get collectedAmount {
    return _collectedAmount?.amount?.toString() ?? '';
  }

  String get isPrepaid => _clientSelectedHistory?.prepaid ?? '';

  String get oldMetering => _clientSelectedHistory?.oldMeter?.toString() ?? '';
  String get newMetering => _clientSelectedHistory?.newMeter?.toString() ?? '';

  bool get isSubMetered =>
      _clientSelectedHistory?.subType == SubscriptionType.meter;

  bool get isSubFlatPrice =>
      _clientSelectedHistory?.subType == SubscriptionType.flat;

  String get lineStatus {
    if (_clientSelectedHistory?.lineStatus == null) return '';
    switch (_clientSelectedHistory?.lineStatus) {
      case 'on':
        return 'On';
      case 'off':
        return 'Off';
    }
    return '';
  }

  double get amount => _collection?.amount;

  void setCollection(String value) {
    double input;
    if (value != null) {
      input = double.tryParse(value);
    }
    double test = double.parse('${_clientSelectedHistory?.bill ?? 0}') -
            _collectedAmount?.amount ?? 0;
    if (input != null && input <= test) {
      isValidCollection = true;
      _collection.amount = input;
      _view.onSuccess(null);
    } else {
      _collection.amount = null;
      isValidCollection = false;
      _view.onError(null, initTextControllers: false);
    }
  }

  void setClientByReference(String ref) {
    resetFields();
    referenceID = ref;
    int id = int.tryParse(referenceID);
    if (id != null) {
      DBProvider.db.getClient(id).then((client) async {
        _client = client;
        _collection.referenceId = id;
        if (_client?.monthlyDataReferences != null &&
            _client.monthlyDataReferences.length > 0) {
          return DBProvider.db.getUnpaidHistory(id);
        } else
          return null;
      }).then((historyList) {
        clientHistoryList = historyList;
        //if (history != null) setupHistoryFields(history);
        _view.onSetClientSuccess();
      }).catchError((error) {
        resetFields();
        _view.onError(error.toString());
        print('DBGetClient: ${error.toString()}');
      });
    } else {
      _view.onError(null);
      resetFields();
    }
  }

  void setupDB() async {
    await DBProvider.db.initDB();
  }

  void submit() {
    isLoading = true;
    if (_collectedAmount != null) {
      _collectedAmount.amount = _collectedAmount.amount + _collection.amount;
      _collectedAmount.date = DateTime.now();
      updateCollection();
    } else {
      insertCollection();
    }
  }

  void updateCollection() {
    DBProvider.db.updateMeterCollection(_collectedAmount).then((result) {
      _view.onSuccess('collection_success');
    }).catchError((error) {
      print('DBinsertCollectionError: $error');
      _view.onError('collection_error');
    }).whenComplete(() {
      isLoading = false;
    });
  }

  void insertCollection() {
    DBProvider.db.insertAmountCollection(_collection).then((result) {
      _view.onSuccess('collection_success');
    }).catchError((error) {
      print('DBinsertCollectionError: $error');
      _view.onError('collection_error');
    }).whenComplete(() {
      isLoading = false;
    });
  }

  void resetFields() {
    _client = null;
    _clientSelectedHistory = null;
    referenceID = null;
    _collection = AmountCollection();
    collectionDate = DateTime.now();
    _collectedAmount = null;
  }
}

abstract class InputPageView {
  void onSetClientSuccess();
  void onError(String error, {bool initTextControllers = true});
  void onSuccess(String msg);
}
