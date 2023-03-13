import 'package:dio/dio.dart';

const String accessToken =
    'pk.eyJ1IjoiaXJhZ2FuYXNoIiwiYSI6ImNsZjRvYWdjajBobDUzeW83a3hobWN0aWwifQ.UyKaklsiZJ45fwZsQQ4yng';

class TrafficInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters.addAll({
      'alternatives': true,
      'geometries': 'polyline6',
      'overview': 'simplified',
      'steps': false,
      'access_token': accessToken,
    });
    super.onRequest(options, handler);
  }
}
