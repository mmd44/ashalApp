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
