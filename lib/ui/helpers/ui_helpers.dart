import 'package:ashal/localization.dart';
import 'package:flutter/material.dart';
import 'package:ashal/ui/theme.dart' as Theme;

void showErrorSnackBar(String text,
    {BuildContext context,
    GlobalKey<ScaffoldState> key,
    SnackBarAction action}) {
  if (text == null) return;
  final snackBar = SnackBar(
    content: Text(text),
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
      text,
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
            new Text("Loading")
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
        child: Text(title),
      ),
    );
  }
  children.add(
    Container(
      padding: verticalPadding,
      child: Text(message),
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
                ? Text(buttonText)
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
  String message,
  VoidCallback onConfirm,
  VoidCallback onDismiss,
}) {
  message ??= Localization.of(context, 'are_you_sure');

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: [Text(message)],
          ),
        ),
        actions: [
          FlatButton(
              child: Text('No'), //Text(Localization.of(context, 'no')),
              onPressed: () {
                if (onDismiss != null) {
                  onDismiss();
                } else {
                  Navigator.pop(context);
                }
              }),
          FlatButton(
            child: Text('Yes'), //Text(Localization.of(context, 'yes')),
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
