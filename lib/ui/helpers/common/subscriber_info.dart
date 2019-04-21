import 'package:ashal/core/controllers/input_pages_controller.dart';
import 'package:ashal/core/database.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/ui/models/text_field_with_selection.dart';
import 'package:flutter/material.dart';
import 'package:ashal/ui/theme.dart' as Theme;

class SubscriberInfo extends StatefulWidget {
  SubscriberInfo(this.client, this.onEditingDone, {this.children = const <Widget>[]});

  final void Function(String item) onEditingDone;
  final Client client;
  
  final List<Widget> children;

  @override
  _SubscriberInfoState createState() => _SubscriberInfoState();
}

class _SubscriberInfoState extends State<SubscriberInfo>
    implements TextFieldWithSelectionView {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 40, right: 40),
      child: Column(
        children: <Widget>[
          TextFieldWithSelection((String regex) async {
            List<Client> clients = await DBProvider.db.getClients(regex);
            return clients
                .map((client) => client.referenceId.toString())
                .toList();
          },
              this,
              children: [
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          enabled: false,
                          decoration: Theme.TextStyles.textField
                              .copyWith(hintText: widget.client?.area, helperText: 'Area', helperStyle: TextStyle(color: Colors.black, height: 0.5)),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          enabled: false,
                          decoration: Theme.TextStyles.textField
                              .copyWith(hintText: widget.client?.streetAddress, helperText: 'Street', helperStyle: TextStyle(color: Colors.black, height: 0.5)),
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
                        child: TextFormField(
                          enabled: false,
                          decoration: Theme.TextStyles.textField
                              .copyWith(hintText: widget.client?.building, helperText: 'Building', helperStyle: TextStyle(color: Colors.black, height: 0.5)),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          enabled: false,
                          decoration: Theme.TextStyles.textField
                              .copyWith(hintText: widget.client?.floor, helperText: 'Floor', helperStyle: TextStyle(color: Colors.black, height: 0.5)),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    enabled: false,
                    decoration: Theme.TextStyles.textField
                        .copyWith(hintText: widget.client?.phone, helperText: 'Phone', helperStyle: TextStyle(color: Colors.black, height: 0.5)),
                  ),
                ),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  @override
  void onEditingCompleted(String value) {
    widget.onEditingDone (value);
  }
}
