import 'package:ashal/ui/models/card_item.dart';
import 'package:ashal/ui/models/card_items.dart';
import 'package:ashal/ui/card_detail/card_detail_body.dart';
import 'package:flutter/material.dart';
import 'package:ashal/ui/theme.dart' as Theme;

class CardDetailPage extends StatefulWidget {

  final CardItem cardItem;

  CardDetailPage(String id) :
        cardItem = CardItemsDao.getCardByID(id);


  @override
  _CardDetailPageState createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.all(8),
        color: Theme.Colors.cardPageBackground,
        child: new CardDetailBody(widget.cardItem),
      ),
    );
  }
}

