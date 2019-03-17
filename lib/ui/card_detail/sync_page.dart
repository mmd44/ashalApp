import 'package:ashal/core/controllers/sync_controller.dart';
import 'package:ashal/ui/models/card_item.dart';
import 'package:ashal/ui/models/card_items.dart';
import 'package:flutter/cupertino.dart';
import 'package:ashal/ui/theme.dart' as Theme;

class SyncPage extends StatefulWidget {

  final CardItem cardItem;

  SyncPage(String id) : cardItem = CardItemsDao.getCardByID(id);

  SyncController _controller;

  @override
  _SyncPageState createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  @override
  Widget build(BuildContext context) {
    return new Container(
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
        ],
      ),
    );
  }
}
