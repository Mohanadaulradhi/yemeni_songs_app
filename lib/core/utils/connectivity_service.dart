import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService() : _connectivity = Connectivity();

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (result) => _isConnectedResult(result),
    );
  }

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return _isConnectedResult(result);
  }

  bool _isConnectedResult(dynamic result) {
    if (result is List) {
      return !result.contains(ConnectivityResult.none);
    }
    return result != ConnectivityResult.none;
  }
}
