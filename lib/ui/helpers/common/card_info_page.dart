import 'package:ashal/core/shared_perferences.dart';
import 'package:ashal/localization.dart';
import 'package:ashal/ui/features/collection_page.dart';
import 'package:ashal/ui/features/metering_collection_page.dart';
import 'package:ashal/ui/features/metering_page.dart';
import 'package:ashal/ui/features/requests_page.dart';
import 'package:ashal/ui/features/sync_page.dart';
import 'package:ashal/ui/models/card_item.dart';
import 'package:ashal/ui/models/card_items.dart';
import 'package:flutter/material.dart';
import 'package:ashal/ui/theme.dart' as Theme;

class CardInfoPage extends StatefulWidget {
  final CardItem cardItem;

  CardInfoPage(String id) : cardItem = CardItemsDao.getCardByID(id);

  @override
  _CardInfoPageState createState() => _CardInfoPageState();
}

class _CardInfoPageState extends State<CardInfoPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(Localization.of(context, widget.cardItem.name)),
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        color: Theme.Colors.cardPageBackground,
        child: buildChildPage(),
      ),
    );
  }

  Widget buildChildPage() {
    if ((ProjectSharedPreferences.instance.isMeterReadingSync() ||
            ProjectSharedPreferences.instance.isCollectionSync()) &&
        widget.cardItem.id != '1')
      return SyncPage('1', true);
    else if (widget.cardItem.id == '1')
      return SyncPage(widget.cardItem.id, false);
    else if (widget.cardItem.id == '2')
      return MeteringPage(widget.cardItem.id);
    else if (widget.cardItem.id == '3')
      return CollectionPage(widget.cardItem.id);
    else if (widget.cardItem.id == '4')
      return RequestsPage (widget.cardItem.id);

    return Container();
  }
}
