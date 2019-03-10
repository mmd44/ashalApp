import 'package:ashal/localization.dart';
import 'package:ashal/model/card_item.dart';
import 'package:ashal/ui/card_detail/subscriber_info.dart';
import 'package:flutter/material.dart';
import 'package:ashal/theme.dart' as Theme;

class CardDetailBody extends StatefulWidget {
  final CardItem cardItem;

  CardDetailBody(this.cardItem);

  @override
  _CardDetailBodyState createState() => _CardDetailBodyState();
}

class _CardDetailBodyState extends State<CardDetailBody> {
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
          SubscriberInfo(),
        ],
      ),
    );
  }
}

