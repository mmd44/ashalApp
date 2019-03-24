import 'package:ashal/localization.dart';
import 'package:flutter/material.dart';

void showErrorSnackbar(String text,
    {BuildContext context,
      GlobalKey<ScaffoldState> key,
      SnackBarAction action}) {
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

void showSnackbar(String text,
    BuildContext context,
    {GlobalKey<ScaffoldState> key,
      SnackBarAction action}) {
  final ThemeData theme = Theme.of(context);
  final snackBar = SnackBar(
    content: Text(
      text,
      style: TextStyle(color: Colors.white),
    ),
    duration: Duration(milliseconds: 1700),
    backgroundColor: theme.primaryColor,
    action: action,
  );
  if (key != null) {
    key.currentState.showSnackBar(snackBar);
  } else {
    Scaffold.of(context).showSnackBar(snackBar);
  }
}

void showDialogMessage(
    BuildContext context, {
      String title,
      String message,
      String buttonText,
      VoidCallback onConfirm,
      bool dismissible = false,
    }) {
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
  if (message != null) {
    children.add(
      Container(
        padding: verticalPadding,
        child: Text(message),
      ),
    );
  }

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
                if (onDismiss!=null) {
                  onDismiss();
                } else {
                  Navigator.pop(context);
                }
              }
          ),
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
