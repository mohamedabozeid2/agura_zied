import 'package:dio/dio.dart';

class AgoraDiohelper {
  static Dio? dio;
  // static String apiKey = 'a33a26fbf615c3f68bcd6ebc1fb6e018';
  // static String accessToken = '52b26587434c7c19927c23d1e7467aa1';
  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.147.17.76:8080',
        receiveDataWhenStatusError: true,
      ),
    );
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
  }) async {
    dio!.options.headers = {
      'Content-Type': 'application/json',
    };
    return await dio!.get(url, queryParameters: query);
  }

  // static Future<Response> postData({
  //   required String url,
  //   required Map<String, dynamic> data,
  //   Map<String, dynamic>? query,
  // }) async {
  //   dio!.options.headers = {
  //     'Authorization': 'Bearer $accessToken',
  //     'Content-Type': 'application/json',
  //     'Accept': 'application/vnd.vimeo.*+json;version=3.4',
  //   };

  //   return await dio!.post(url, data: data, queryParameters: query);
  // }
}
