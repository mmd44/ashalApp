import 'package:ashal/ui/models/card_item.dart';
import 'package:ashal/ui/models/card_items.dart';
import 'package:flutter/cupertino.dart';

class RequestsPage extends StatefulWidget {

  final CardItem cardItem;

  RequestsPage(String id) : cardItem = CardItemsDao.getCardByID(id);

  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
