import 'package:dio/dio.dart';
import 'package:fp_ads/fp_ads.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  InternetConnection provideInternetConnection() => InternetConnection();

  @lazySingleton
  NetworkInfo provideNetworkInfo() => NetworkInfoImpl();

  @lazySingleton
  Dio provideDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );

    return dio;
  }
}
