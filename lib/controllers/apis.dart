import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

/// More examples see https://github.com/cfug/dio/blob/main/example
class ApiConnect {
  final bool needUdpValidation;
  ApiConnect({this.needUdpValidation = false});

  static Future<dynamic> hitApiPost(
      String url, Map<String, dynamic> params) async {
    debugPrint("Urls passing $url");
    debugPrint("Payload passing ${jsonEncode(params)}");
    final dio = Dio();
    final response = await dio
        .post(
          url,
          data: (params),
        )
        .timeout(Duration(seconds: 30));
    debugPrint("Api Response $response");
    debugPrint(response.data.toString());
    return response.data;
  }

  static Future<dynamic> hitApiGet(String url) async {
    debugPrint("Urls passing $url");
    final dio = Dio();
    final response = await dio.get(url);
    debugPrint("Api Response $response");
    debugPrint(response.data.toString());
    return response.data;
  }
}
