import 'package:ashal/ui/models/card_item.dart';
class CardItemsDao {

  static final List<CardItem> menuItems = [
    const CardItem(
      id: "1",
      name: "Sync",
      description: "Sync your data",
      image: "assets/img/mars.png",
    ),
    const CardItem(
      id: "2",
      name: "Metering",
      description: "Type in a Meter Reading",
      image: "assets/img/neptune.png",
    ),
    const CardItem(
      id: "3",
      name: "Collection",
      description: "Collect your Money!",
      image: "assets/img/moon.png",
    ),
  ];

  static CardItem getCardByID(id) {
    return menuItems
        .where((p) => p.id == id)
        .first;
  }
}