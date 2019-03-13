import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ashal/ui/theme.dart' as Theme;

class TextFieldWithSelection extends StatefulWidget {
  //final List<String> items;

  //TextFieldWithSelection(this.items);

  final Future<List<String>> Function(String regex) recommandedItems;

  TextFieldWithSelection(this.recommandedItems);

  @override
  _TextFieldWithSelectionState createState() => _TextFieldWithSelectionState();
}

class _TextFieldWithSelectionState extends State<TextFieldWithSelection> {
  List<String> items;

  String selectedValue;

  bool get isVisible => items!=null && items.length > 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextField(

            keyboardType: TextInputType.number,
            onChanged: (value) async {
              items = await widget.recommandedItems(value);
            },
            textAlign: TextAlign.center,
            decoration: Theme.TextStyles.textField.copyWith(
                errorText: null, counterText: '', hintText: selectedValue ?? 'Reading', ),
          ),
          Visibility(
            visible: true,
            child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile (
                    title: Text(items[index]),
                    onTap:() => selectedValue = items[index],
                  );
                },
                separatorBuilder: (BuildContext context, int index) => new Divider(),
                itemCount: items?.length ?? 0),
          ),
        ],
      ),
    );
  }
}
