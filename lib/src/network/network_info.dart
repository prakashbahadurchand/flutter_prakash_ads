import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Contract for monitoring network connectivity status.
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<InternetStatus> get onStatusChange;
}

/// Standard implementation of [NetworkInfo] backed by [InternetConnection].
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl([InternetConnection? internetConnection])
      : _internetConnection = internetConnection ?? InternetConnection();

  final InternetConnection _internetConnection;

  @override
  Future<bool> get isConnected => _internetConnection.hasInternetAccess;

  @override
  Stream<InternetStatus> get onStatusChange =>
      _internetConnection.onStatusChange;
}
