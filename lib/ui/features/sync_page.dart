import 'package:ashal/core/shared_perferences.dart';
import 'package:ashal/core/controllers/sync_controller.dart';
import 'package:ashal/core/database.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/network/api.dart';
import 'package:ashal/localization.dart';
import 'package:ashal/ui/helpers/ui_helpers.dart';
import 'package:ashal/ui/models/card_item.dart';
import 'package:ashal/ui/models/card_items.dart';
import 'package:ashal/ui/theme.dart' as Theme;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SyncPage extends StatefulWidget {

  final CardItem cardItem;
  final bool showDialog;

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
                Text(API.ipAddress.isNotEmpty
                    ? '${Localization.of(context, 'connected')}  : ${API.ipAddress}'
                    : Localization.of(context, "searching_for_server")),
                _buildClearIpButton(),
                _buildSyncClientButton(),
                _buildSyncMeterReadingButton(),
                _buildSyncCollectionReadingButton(),
                _buildSyncRequestsButton(),
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
          child: Text(Localization.of(context, 'reconnect')),
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
              child:  Text(Localization.of(context, 'sync_clients')),
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
                child:  Text(Localization.of(context, 'sync_meter_reading')),
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
                child: Text(Localization.of(context, 'sync_collection_reading')),
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
                child: Text(Localization.of(context, "clear_data")),
                onPressed: API.ipAddress.isEmpty
                    ? null
                    : () async {
                        _controller.clearMeterData();
                        setState(() {});
                      },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)))));
  }

  Widget _buildSyncRequestsButton() {
    return Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 50.0),
        child: ButtonTheme(
            minWidth: 200.0,
            child: new RaisedButton(
                child:  Text(Localization.of(context, 'sync_requests')),
                onPressed: API.ipAddress.isEmpty
                    ? null
                    : () async {
                  await _controller.syncRequests();
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
            buttonText: 'ok',
            title: 'sync',
            message: 'sync_message',
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
    showDialogMessage(context, title: 'error', message: msg, onConfirm: null);
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
    showDialogMessage(context, title: 'success', message: msg, onConfirm: null);
    if (mounted) {
      this.setState(() {});
    }
  }
}
