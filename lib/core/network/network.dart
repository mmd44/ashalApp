import 'dart:async';
import 'dart:convert';
import 'package:ashal/core/network/api_exception.dart';
import 'package:http/http.dart' as http;

class HttpRequest {
  static Map<String, String> defaultHeaders = Map<String, String>();
  static Map<String, String> defaultParams = Map<String, String>();
  static void Function(String url, {Object body, Map headers}) beforeMiddleware;
  static void Function(http.Response response) afterMiddleware;

  static Future<dynamic> get(String url,
      {Map params, Map headers, bool includeDefaultParams = true}) async {
    Map<String, String> requestHeaders = setHeaders(headers);

    url =
    includeDefaultParams ? setParams(url, params) : encodeUrl(url, params);

    if (beforeMiddleware != null) {
      await beforeMiddleware(url, headers: requestHeaders);
    }
    return http
        .get(url, headers: requestHeaders)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (afterMiddleware != null) {
        afterMiddleware(response);
      }

      int cacheTimeSeconds = 0;
      if (response.headers != null &&
          response.headers["cache-control"] != null) {
        int x = int.tryParse(response.headers['cache-control'].split('=')[1]);
        if (x != null && x > 0) {
          cacheTimeSeconds = x;
        }
      }

      //max-age =0(add the header)

      if (statusCode < 200 || statusCode >= 400) {
        try {
          throw APIException.fromJson(json.decode(res));
        } on FormatException {
          throw APIException.generic;
        }
      }

      if (response.bodyBytes == null || response.bodyBytes.isEmpty) return null;
      return json.decode(utf8.decode(response.bodyBytes));
    });
  }

  static Future<dynamic> getOuterAPI(String url) {
    print('Calling: GET ${Uri.encodeFull(url)}');
    return http.get(url).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;
      print("getOuterAPIBody: $res");

      if (statusCode < 200 || statusCode >= 400) {
        try {
          APIException error = APIException.fromJson(json.decode(res));
          if (error.code != null) {
            throw (error.code);
          } else {
            throw ('An error has occured, please try again later.');
          }
        } on FormatException catch (e) {
          throw ('An error has occured, please try again later.');
        }
      }

      if (response.bodyBytes == null || response.bodyBytes.isEmpty) return null;
      return json.decode(utf8.decode(response.bodyBytes));
    });
  }

  static Future<dynamic> post(String url, Object body,
      {Map params, headers, encoding, bool handleError = true}) async {
    Map<String, String> requestHeaders = setHeaders(headers);
    requestHeaders['Content-Type'] = 'application/json';
    url = setParams(url, params);

    if (beforeMiddleware != null) {
      await beforeMiddleware(
        url,
        body: body,
        headers: requestHeaders,
      );
    }
    return http
        .post(url,
        body: json.encode(body),
        headers: requestHeaders,
        encoding: encoding)
        .then((http.Response response) {
      final String res = 'inasd'; //response.body;
      final int statusCode = response.statusCode;

      if (afterMiddleware != null) {
        afterMiddleware(response);
      }
      if (statusCode < 200 || statusCode >= 400) {
        if (handleError) {
          try {
            throw APIException.fromJson(json.decode(res));
          } on FormatException {
            throw APIException.generic;
          }
        } else {
          if (response.bodyBytes == null || response.bodyBytes.isEmpty)
            throw APIException.generic;
          try {
            throw json.decode(utf8.decode(response.bodyBytes));
          } on FormatException {
            throw APIException.generic;
          }
        }
      }
      return json.decode(utf8.decode(response.bodyBytes));
    });
  }

  static Future<dynamic> patch(String url, Object body,
      {Map params, headers, encoding}) async {
    Map<String, String> requestHeaders = setHeaders(headers);
    url = setParams(url, params);

    if (beforeMiddleware != null) {
      await beforeMiddleware(
        url,
        body: body,
        headers: requestHeaders,
      );
    }
    return http
        .patch(url,
        body: json.encode(body),
        headers: requestHeaders,
        encoding: encoding)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (afterMiddleware != null) {
        afterMiddleware(response);
      }
      if (statusCode < 200 || statusCode >= 400) {
        try {
          throw APIException.fromJson(json.decode(res));
        } on FormatException {
          throw APIException.generic;
        }
      }
      if (response.bodyBytes == null || response.bodyBytes.isEmpty) return null;
      return json.decode(utf8.decode(response.bodyBytes));
    });
  }

  static Future<dynamic> getFile(String url, {Map<String, dynamic> map}) {}

  static Future<dynamic> delete(String url, {Map headers, encoding}) async {
    Map<String, String> requestHeaders = setHeaders(headers);
    url = setParams(url);
    print('Calling DELETE: $url');
    if (beforeMiddleware != null) {
      await beforeMiddleware(
        url,
        headers: requestHeaders,
      );
    }
    return http
        .delete(url, headers: requestHeaders)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (afterMiddleware != null) {
        afterMiddleware(response);
      }
      if (statusCode < 200 || statusCode >= 400) {
        try {
          throw APIException.fromJson(json.decode(res));
        } on FormatException {
          throw APIException.generic;
        }
      }
      if (response.bodyBytes == null || response.bodyBytes.isEmpty) return null;
      return json.decode(utf8.decode(response.bodyBytes));
    });
  }

  static Map<String, String> setHeaders(Map headers) {
    Map<String, String> requestHeaders = Map.from(defaultHeaders);

    if (headers != null) {
      headers.forEach((header, value) => requestHeaders[header] = value);
    }
    return requestHeaders;
  }

  static String setParams(String url, [Map params]) {
    Map<String, String> requestParams = Map<String, String>.from(defaultParams);

    if (params != null) {
      params.forEach((query, value) => requestParams[query] = value.toString());
    }
    return encodeUrl(url, requestParams);
  }

  static String encodeUrl(String url, Map<String, String> requestParams) {
    Uri parsedUri = Uri.parse(url);
    final uri = Uri(
        scheme: parsedUri.scheme,
        host: parsedUri.host,
        path: parsedUri.path,
        port: parsedUri.port,
        queryParameters: requestParams);
    return uri.toString();
  }
}

enum RequestMethod { POST, PATCH, GET, DELETE }
