import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class InternetConnectionChecker {
  Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }

    return await _checkInternetAccess();
  }

  Future<bool> _checkInternetAccess() async {
    try {
      // Use DNS lookup instead of HTTP to avoid redirect loops (e.g. Google abuse protection).
      // Probes Google's public DNS (8.8.8.8) — always reliable, no HTTP redirects.
      final result = await InternetAddress.lookup('8.8.8.8')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}
