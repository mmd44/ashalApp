import 'package:ashal/ui/models/card_items.dart';
import 'package:ashal/ui/home/card_row.dart';
import 'package:flutter/material.dart';
import 'package:ashal/ui/theme.dart' as Theme;

class CardList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Flexible(
      child: new Container(
        color: Theme.Colors.cardPageBackground,
        child: new ListView.builder(
          itemExtent: 160.0,
          itemCount: CardItemsDao.menuItems.length,
          itemBuilder: (_, index) => new CardRow(CardItemsDao.menuItems[index]),
        ),
      ),
    );
  }
}