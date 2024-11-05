import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:nova_ai/Utils/Helper/helper_function.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final StreamController<ConnectivityResult> _connectivityStreamController =
      StreamController<ConnectivityResult>.broadcast();

  final BuildContext context;
  bool _initialCheckDone = false; // Flag to track the initial connection check

  ConnectivityService(this.context) {
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      for (ConnectivityResult result in results) {
        _connectivityStreamController.add(result);
        if (!_initialCheckDone) {
          _initialCheckDone = true;
          if (result == ConnectivityResult.none) {
            HelperFunction.showSnackbar(
                text: "No Internet Connection",
                context: context,
                color: Colors.red);
          }
        } else {
          if (result == ConnectivityResult.none) {
            HelperFunction.showSnackbar(
                text: "No Internet Connection",
                context: context,
                color: Colors.red);
          } else {
            final bool hasInternet = await _hasInternetConnection();
            if (!hasInternet) {
              HelperFunction.showSnackbar(
                  text: "No Internet Access",
                  context: context,
                  color: Colors.red);
            } else {
              HelperFunction.showSnackbar(
                  text: "Internet Restored",
                  context: context,
                  color: Colors.green);
            }
          }
        }
      }
    });
  }

  /// Stream for live connectivity updates
  Stream<ConnectivityResult> get connectivityStream =>
      _connectivityStreamController.stream;

  /// Manual check for the current connectivity status
  Future<bool> checkConnectivity() async {
    List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      return false;
    } else {
      return await _hasInternetConnection();
    }
  }

  /// Check if the internet is actually accessible by pinging a reliable server
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityStreamController.close();
  }
}
