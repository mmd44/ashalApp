import 'package:ashal/routes.dart';
import 'package:ashal/model/card_item.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:ashal/ui/theme.dart' as Theme;

class CardRow extends StatelessWidget {

  final CardItem cardItem;

  CardRow(this.cardItem);

  @override
  Widget build(BuildContext context) {
    final cardItemThumbnail = new Container(
      alignment: new FractionalOffset(0.0, 0.5),
      margin: const EdgeInsets.only(left: 24.0),
      child: new Hero(
        tag: 'card-icon-${cardItem.id}',
        child: new Image(
          image: new AssetImage(cardItem.image),
          height: Theme.Dimens.cardHeight,
          width: Theme.Dimens.cardWidth,
        ),
      ),
    );

    final itemCard = new Container(
      margin: const EdgeInsets.only(left: 72.0, right: 24.0),
      decoration: new BoxDecoration(
        color: Theme.Colors.itemCard,
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          new BoxShadow(color: Colors.black,
            blurRadius: 10.0,
            offset: new Offset(0.0, 10.0))
        ],
      ),
      child: new Container(
        margin: const EdgeInsets.only(top: 16.0, left: 72.0),
        constraints: new BoxConstraints.expand(),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(cardItem.name, style: Theme.TextStyles.cardTitle),
            new Text(cardItem.description, style: Theme.TextStyles.cardSubtitle),
            new Container(
              color: const Color(0xFF00C6FF),
              width: 24.0,
              height: 1.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0)
            ),
            /*new Row(
              children: <Widget>[
                new Icon(Icons.location_on, size: 14.0,
                  color: Theme.Colors.cardDistance),
                new Text(
                  cardItem.distance, style: Theme.TextStyles.cardExtraInfo),
                new Container(width: 24.0),
                new Icon(Icons.flight_land, size: 14.0,
                  color: Theme.Colors.cardDistance),
                new Text(
                  cardItem.gravity, style: Theme.TextStyles.cardExtraInfo),
              ],
            )*/
          ],
        ),
      ),
    );

    return new Container(
      height: 120.0,
      margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: new FlatButton(
        onPressed: () => _navigateTo(context, cardItem.id),

        child: new Stack(
          children: <Widget>[
            itemCard,
            cardItemThumbnail,
          ],
        ),
      ),
    );
  }

  _navigateTo(context, String id) {
    Routes.navigateTo(
      context,
      '/detail/${cardItem.id}',
      transition: TransitionType.fadeIn
    );
  }
}

