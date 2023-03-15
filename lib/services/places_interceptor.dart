import 'package:dio/dio.dart';

const String accessToKen =
    'pk.eyJ1IjoiaXJhZ2FuYXNoIiwiYSI6ImNsZjRvYWdjajBobDUzeW83a3hobWN0aWwifQ.UyKaklsiZJ45fwZsQQ4yng';

class PlacesInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters.addAll({
      // 'country': 'co',
      'language': 'es',
      'access_token': accessToKen,
    });
    super.onRequest(options, handler);
  }
}
