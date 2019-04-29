import 'package:ashal/core/database.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/localization.dart';
import 'package:ashal/ui/models/text_field_with_selection.dart';
import 'package:flutter/material.dart';
import 'package:ashal/ui/theme.dart' as Theme;

class SubscriberInfo extends StatefulWidget {
  SubscriberInfo(this.client, this.onEditingDone,
      {this.children = const <Widget>[]});

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
          }, this, children: [
            Visibility(
              visible: widget.client != null,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            enabled: false,
                            decoration: Theme.TextStyles.textField.copyWith(
                              hintText: getDisplayName(),
                              helperText: Localization.of(context, 'name'),
                            ),
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
                            decoration: Theme.TextStyles.textField.copyWith(
                              hintText: widget.client?.category,
                              helperText: Localization.of(context, 'category'),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            enabled: false,
                            decoration: Theme.TextStyles.textField.copyWith(
                              hintText: widget.client?.phone?.toString(),
                              helperText: Localization.of(context, 'phone'),
                            ),
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
                            decoration: Theme.TextStyles.textField.copyWith(
                              hintText: widget.client?.area,
                              helperText: Localization.of(context, 'area'),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            enabled: false,
                            decoration: Theme.TextStyles.textField.copyWith(
                              hintText: widget.client?.streetAddress,
                              helperText: Localization.of(context, 'street'),
                            ),
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
                            decoration: Theme.TextStyles.textField.copyWith(
                              hintText: widget.client?.building,
                              helperText: Localization.of(context, 'building'),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            enabled: false,
                            decoration: Theme.TextStyles.textField.copyWith(
                              hintText: widget.client?.floor?.toString(),
                              helperText: Localization.of(context, 'floor'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  @override
  void onEditingCompleted(String value) {
    widget.onEditingDone(value);
  }

  String getDisplayName() {
    Client client = widget.client;
    if (client?.firstName != null) {
      return '${client?.prefix ?? ''} ${client?.firstName} ${client?.familyName ?? ''}';
    } else if (client?.organizationName != null) {
      return client.organizationName;
    } else {
      return client?.sharedDescription;
    }
  }
}
