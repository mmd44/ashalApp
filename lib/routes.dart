import 'package:ashal/ui/helpers/common/card_info_page.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class Routes {
  static final Router _router = new Router();

  static var inputPageHandler  = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
        List<String> temp = params['id'];
        return new CardInfoPage(temp[0]);
      });

  static void initRoutes() {
    _router.define("/sync/:id", handler: inputPageHandler);
    _router.define("/metering/:id", handler: inputPageHandler);
    _router.define("/collection/:id", handler: inputPageHandler);
    _router.define("/requests/:id", handler: inputPageHandler);
  }

  static void navigateTo(context, String route, {TransitionType transition}) {
    _router.navigateTo(context, route, transition: transition);
  }

}