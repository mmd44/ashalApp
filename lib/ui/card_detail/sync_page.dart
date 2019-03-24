import 'package:ashal/core/controllers/shared_perferences.dart';
import 'package:ashal/core/controllers/sync_controller.dart';
import 'package:ashal/core/database.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/network/api.dart';
import 'package:ashal/ui/helpers/ui_helpers.dart';
import 'package:ashal/ui/models/card_item.dart';
import 'package:ashal/ui/models/card_items.dart';
import 'package:ashal/ui/theme.dart' as Theme;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SyncPage extends StatefulWidget {
  final CardItem cardItem;
  bool showDialog;
  SyncPage(String id, this.showDialog)
      : cardItem = CardItemsDao.getCardByID(id);

  @override
  _SyncPageState createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> implements SyncCallBack {
  SyncController _controller;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.Colors.cardPageBackground,
      child: ListView(
        children: <Widget>[
          new Center(
            child: new Hero(
              tag: 'card-icon-${widget.cardItem.id}',
              child: new Image(
                image: new AssetImage(widget.cardItem.image),
                height: Theme.Dimens.cardHeight,
                width: Theme.Dimens.cardWidth,
              ),
            ),
          ),
          new Center(
            child: new Column(
              children: <Widget>[
                Text(!API.ipAddress.isEmpty
                    ? 'Connected : ${API.ipAddress}'
                    : "Searching For server"),
                _buildClearIpButton(),
                _buildSyncClientButton(),
                _buildSyncMeterReadingButton(),
                _buildSyncCollectionReadingButton(),
                Visibility(
                    visible: _controller != null &&
                        _controller.collection &&
                        _controller.readings,
                    child: _buildSyncClearMeterData())
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildClearIpButton() {
    return ButtonTheme(
      minWidth: 100.0,
      child: new FlatButton(
          child: const Text('Reconnect'),
          color: Colors.black12,
          onPressed: () async {
            API.ipAddress = '';
            setState(() {});
            _controller.getServerIp();
          },
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0))),
    );
  }

  Widget _buildSyncClientButton() {
    return Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 50.0),
        child: ButtonTheme(
          minWidth: 200.0,
          child: new RaisedButton(
              child: const Text('Sync Clients'),
              onPressed: API.ipAddress.isEmpty
                  ? null
                  : () async {
                      _controller.syncClients();
                    },
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0))),
        ));
  }

  Widget _buildSyncMeterReadingButton() {
    return Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 50.0),
        child: ButtonTheme(
            minWidth: 200.0,
            child: new RaisedButton(
                child: const Text('Sync Meter Reading'),
                onPressed: API.ipAddress.isEmpty || ProjectSharedPreferences.instance.isMeterReadingSync()
                    ? null
                    : () async {
                        await _controller.syncMeterReading();
                        setState(() {});
                      },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)))));
  }

  Widget _buildSyncCollectionReadingButton() {
    return Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 50.0),
        child: ButtonTheme(
            minWidth: 200.0,
            child: new RaisedButton(
                child: const Text('Sync Collection Reading'),
                onPressed: API.ipAddress.isEmpty || ProjectSharedPreferences.instance.isCollectionSync()
                    ? null
                    : () async {
                        await _controller.syncCollection();
                        setState(() {});
                      },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)))));
  }

  Widget _buildSyncClearMeterData() {
    return Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 50.0),
        child: ButtonTheme(
            minWidth: 200.0,
            child: new RaisedButton(
                child: const Text('Clear Meter Data and Sync Clients'),
                onPressed: API.ipAddress.isEmpty
                    ? null
                    : () async {
                        _controller.clearMeterData();
                        setState(() {});
                      },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)))));
  }

  void _showSyncDialog()
  {
    if (widget.showDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        showDialogMessage(context,
            buttonText: "ok",
            title: 'Sync',
            message: "Complete Sync and clear data to add new reading/collection",
            onConfirm: null);
      });
    }
  }
  void _init() {
    _showSyncDialog();
    var collection = ProjectSharedPreferences.instance.isCollectionSync();
    var readings = ProjectSharedPreferences.instance.isMeterReadingSync();
    _controller = new SyncController(this, readings, collection);
    _controller.getServerIp();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void onConnect() {
    if (mounted) {
      this.setState(() {});
    }
  }

  @override
  void onStart(String from) {
    showLoader(context);
  }

  @override
  void onSyncError(String fromButton, String msg) {
    Navigator.pop(context);
    showDialogMessage(context, title: 'Error', message: msg, onConfirm: null);
    if (mounted) {
      this.setState(() {});
    }
  }

  @override
  void onSyncSuccess(String fromButton, String msg) async {
    Navigator.pop(context);
    if (fromButton == 'client') {
      List<Client> clients = await DBProvider.db.getAllClients();
      clients.forEach((client) => print(client.toJson()));
    }
    showDialogMessage(context, title: 'Success', message: msg, onConfirm: null);
    if (mounted) {
      this.setState(() {});
    }
  }
}
