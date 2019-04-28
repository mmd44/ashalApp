import 'package:ashal/localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ashal/ui/theme.dart' as Theme;

class TextFieldWithSelection extends StatefulWidget {
  //final List<String> items;

  //TextFieldWithSelection(this.items);

  final Future<List<String>> Function(String regex) recommendedItems;
  final List<Widget> children;
  final double childrenPadding;
  final TextFieldWithSelectionView view;

  TextFieldWithSelection(this.recommendedItems, this.view,
      {this.children = const <Widget>[], this.childrenPadding = 48});

  @override
  _TextFieldWithSelectionState createState() => _TextFieldWithSelectionState();
}

class _TextFieldWithSelectionState extends State<TextFieldWithSelection> {
  List<String> items;

  bool get isVisible =>
      inputTextFocusNode.hasFocus &&
          isVisibleOnTap &&
          (items != null && items.length > 1) ||
      (items != null && items.length == 1 && selectedValue.text != items[0]);

  bool isVisibleOnTap = true;

  var selectedValue = new TextEditingController();

  FocusNode inputTextFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> base = <Widget>[
      TextField(
        focusNode: inputTextFocusNode,
        controller: selectedValue,
        keyboardType: TextInputType.number,
        onChanged: (value) async {
          items = await widget.recommendedItems(value);
          isVisibleOnTap = true;
          widget.view.onEditingCompleted(selectedValue.text);
          setState(() {});
        },
        onTap: () {
          isVisibleOnTap = true;
          setState(() {});
        },
        textAlign: TextAlign.center,
        decoration: Theme.TextStyles.textField.copyWith(
            errorText: null,
            counterText: '',
            hintText: Localization.of(context, 'reference_id'),
            helperText: !isVisible && isVisibleOnTap
                ? 'Please enter a reference ID in order to proceed'
                : null,
            border: OutlineInputBorder()),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Visibility(
          visible: isVisible,
          child: Container(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            decoration: new BoxDecoration(
                color: Color.fromRGBO(64, 75, 96, 1),
                borderRadius: new BorderRadius.circular(5),
                border: Border.all(width: 1.0, color: Colors.black12)),
            child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    child: InkWell(
                      child: Center(
                        child: Text(
                          items[index],
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () async {
                        selectedValue.text = items[index];
                        isVisibleOnTap = false;
                        items = await widget.recommendedItems(items[index]);
                        inputTextFocusNode.unfocus();
                        widget.view.onEditingCompleted(selectedValue.text);
                        setState(() {});
                      },
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    new Divider(
                      color: Colors.white,
                    ),
                itemCount: items?.length ?? 0),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: widget.childrenPadding),
        child: Column(
          children: widget.children,
        ),
      ),
    ];
    //base.addAll(widget.children);
    return Stack(
      children: base,
    );
  }
}

abstract class TextFieldWithSelectionView {
  void onEditingCompleted(String value);
}
