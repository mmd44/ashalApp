import 'package:ashal/localization.dart';
import 'package:ashal/model/card_item.dart';
import 'package:flutter/material.dart';
import 'package:ashal/theme.dart' as Theme;

class SubscriberInfo extends StatefulWidget {
  SubscriberInfo();

  @override
  _SubscriberInfoState createState() => _SubscriberInfoState();
}

class _SubscriberInfoState extends State<SubscriberInfo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 40, right: 40),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: null,
              decoration:
                  Theme.TextStyles.textField.copyWith(hintText: 'Reference ID'),
            ),
          ),
          Visibility(
            visible: true,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          enabled: false,
                          onChanged: null,
                          decoration: Theme.TextStyles.textField
                              .copyWith(hintText: 'Area'),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          enabled: false,
                          onChanged: null,
                          decoration: Theme.TextStyles.textField
                              .copyWith(hintText: 'Street'),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          enabled: false,
                          onChanged: null,
                          decoration: Theme.TextStyles.textField
                              .copyWith(hintText: 'Building'),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          enabled: false,
                          onChanged: null,
                          decoration: Theme.TextStyles.textField
                              .copyWith(hintText: 'Floor'),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    enabled: false,
                    onChanged: null,
                    decoration:
                        Theme.TextStyles.textField.copyWith(hintText: 'Phone'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
