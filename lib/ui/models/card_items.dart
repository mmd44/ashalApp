import 'package:ashal/ui/models/card_item.dart';
class CardItemsDao {

  static final List<CardItem> menuItems = [
    const CardItem(
      id: "1",
      name: "sync",
      description: "sync_desc",
      image: "assets/img/pc_sync.png",
    ),
    const CardItem(
      id: "2",
      name: "metering",
      description: "metering_desc",
      image: "assets/img/metering.png",
    ),
    const CardItem(
      id: "3",
      name: "collection",
      description: "collection_desc",
      image: "assets/img/bill_tools.png",
    ),
    const CardItem(
      id: "4",
      name: "requests",
      description: "requests_desc",
      image: "assets/img/requests.png",
    ),
  ];

  static CardItem getCardByID(id) {
    return menuItems
        .where((p) => p.id == id)
        .first;
  }
}