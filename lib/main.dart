import 'dart:io';


import 'package:ashal/routes.dart';
import 'package:ashal/ui/home/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ashal/localization.dart';
import 'package:flutter/material.dart';
import 'package:ashal/ui/theme.dart' as Theme;

void main() => runApp(MainApp());

class MainApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainAppState();
  }
}

class MainAppState extends State<MainApp> {
  Key key = new UniqueKey();

  @override
  Widget build(BuildContext context) {

    Routes.initRoutes();
    return new MaterialApp(
        key: key,
        title: 'Ashal Mobile',
        theme: ThemeData(
          primaryColor: Theme.Colors.itemCard,
        ),
        supportedLocales: LocalizationDelegate.supportedLocales,
        localizationsDelegates: [
          LocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        localeResolutionCallback:
            (Locale locale, Iterable<Locale> supportedLocales) {
          if (locale == null) {
            return supportedLocales.first;
          }
          for (Locale supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        home: HomePage());
  }
}
