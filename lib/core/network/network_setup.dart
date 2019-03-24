import 'dart:async';
import 'dart:convert';

import 'package:ashal/core/network/network.dart';
import 'package:http/http.dart' as http;

class NetworkSetup {
  NetworkSetup();


  void setNetworkLanguage(String languageCode) async {
    HttpRequest.defaultParams['language'] = languageCode;
  }

  void setNetworkHeaders() {
    HttpRequest.beforeMiddleware = beforeMiddleware;
    HttpRequest.afterMiddleware = afterMiddleware;
  }

  void beforeMiddleware(String url, {Object body, Map headers}) {
    print('Calling: GET ${Uri.encodeFull(url)}');
  }

  void afterMiddleware(http.Response response) async {
    final String body = response.body;
    final int statusCode = response.statusCode;
    final uuid = response.headers['x-correlation-id'];
    print('RESPONSE FOR[$uuid]: ${response.request.url}');
    print('STATUS CODE: $statusCode');
    print('HEADERS: ${response.headers}');
    print('=================================');
    print('BODY: $body');
  }
}
