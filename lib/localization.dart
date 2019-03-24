import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Localization {
  Localization(this.locale);

  final Locale locale;

  static String of(BuildContext context, String key) {
    return Localizations.of<Localization>(context, Localization).translate(key);
  }


  Map<String, String> _sentences;

  Future<bool> load() async {

    String data = await rootBundle
        .loadString('assets/i18n/${this.locale.languageCode}.json');
    Map<String, dynamic> _result = json.decode(data);

    this._sentences = new Map();
    _result.forEach((String key, dynamic value) {
      this._sentences[key] = value.toString();
    });

    return true;
  }

  String translate(String key) {
    return this._sentences[key] ?? '${key}_';
  }
}

class LocalizationDelegate extends LocalizationsDelegate<Localization> {
  const LocalizationDelegate();

  static final supportedCodes = ['en', 'ar'];
  static final supportedLocales = supportedCodes.map((c) => Locale(c));

  @override
  bool isSupported(Locale locale) => supportedCodes.contains(locale.languageCode);

  @override
  Future<Localization> load(Locale locale) async {

    Localization localization = new Localization(locale);
    await localization.load();

    print("Loaded language: ${locale.languageCode}");

    return localization;
  }

  @override
  bool shouldReload(LocalizationDelegate old) => false;
}
