import 'package:ashal/core/shared_perferences.dart';
import 'package:ashal/ui/home/gradient_app_bar.dart';
import 'package:ashal/ui/home/card_list.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        centerTitle: true,
          title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: new Image.asset(
                'assets/img/ashal_logo.png',
                height: 60,
                fit: BoxFit.scaleDown,
              ))),
      body: new HomePageBody(),
    );
  }
}

class HomePageBody extends StatefulWidget {
  @override
  _HomePageBodyState createState() => new _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new CardList(),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    ProjectSharedPreferences.instance.init();
  }
}
