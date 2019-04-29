import 'package:ashal/localization.dart';
import 'package:flutter/material.dart';
import 'package:ashal/ui/theme.dart' as Theme;

void showErrorSnackBar(String text,
    {BuildContext context,
    GlobalKey<ScaffoldState> key,
    SnackBarAction action}) {
  if (text == null) return;
  final snackBar = SnackBar(
    content: Text(Localization.of(context, text)),
    duration: Duration(milliseconds: 1700),
    backgroundColor: Colors.red,
    action: action,
  );
  if (key != null) {
    key.currentState.showSnackBar(snackBar);
  } else {
    Scaffold.of(context).showSnackBar(snackBar);
  }
}

void showSnackBar(String text, BuildContext context,
    {GlobalKey<ScaffoldState> key, SnackBarAction action}) {
  if (text == null) return;
  final snackBar = SnackBar(
    content: Text(
      Localization.of(context, text),
      style: TextStyle(color: Colors.white),
    ),
    duration: Duration(milliseconds: 1700),
    backgroundColor: Theme.Colors.primary,
    action: action,
  );
  if (key != null) {
    key.currentState.showSnackBar(snackBar);
  } else {
    Scaffold.of(context).showSnackBar(snackBar);
  }
}

void showLoader(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
          content: Container(
        width: 200,
        height: 100,
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new CircularProgressIndicator(),
            ),
            Text(Localization.of(context, 'loading'))
          ],
        )),
      ));
    },
  );
}

void showDialogMessage(
  BuildContext context, {
  String title,
  String message,
  String buttonText,
  VoidCallback onConfirm,
  bool dismissible = false,
}) {
  if (message == null) return;

  List<Widget> children = [];
  EdgeInsets verticalPadding = EdgeInsets.symmetric(vertical: 10);
  if (title != null) {
    children.add(
      Container(
        padding: verticalPadding,
        child: Text(Localization.of(context, title)),
      ),
    );
  }
  children.add(
    Container(
      padding: verticalPadding,
      child: Text(Localization.of(context, message)),
    ),
  );

  showDialog(
    barrierDismissible: dismissible,
    context: context,
    builder: (context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: children,
          ),
        ),
        actions: [
          FlatButton(
            child: buttonText != null
                ? Text(Localization.of(context, buttonText))
                : Text(Localization.of(context, 'ok')),
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) {
                onConfirm();
              }
            },
          )
        ],
      );
    },
  );
}

void showDialogConfirm(
  BuildContext context, {
  String message = 'are_you_sure',
  VoidCallback onConfirm,
  VoidCallback onDismiss,
}) {

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: [Text(Localization.of(context, message))],
          ),
        ),
        actions: [
          FlatButton(
              child: Text(Localization.of(context, 'no')),
              onPressed: () {
                if (onDismiss != null) {
                  onDismiss();
                } else {
                  Navigator.pop(context);
                }
              }),
          FlatButton(
            child: Text(Localization.of(context, 'yes')),
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
          )
        ],
      );
    },
  );
}

Widget buildLoader(BuildContext context) {
  return Container(
    alignment: Alignment.topCenter,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        child: Opacity(
          opacity: 1,
          child: CircularProgressIndicator(
            backgroundColor: Theme.Colors.primary,
            strokeWidth: 2,
          ),
        ),
        height: 12,
      ),
    ),
  );
}
