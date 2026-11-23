import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityService {
  bool get isOnline;
  Stream<bool> get onStatusChanged;
}

class ConnectivityPlusService implements ConnectivityService {
  ConnectivityPlusService([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;

  @override
  bool get isOnline => _isOnline;

  @override
  Stream<bool> get onStatusChanged => _controller.stream;

  Future<void> init() async {
    _isOnline = _hasConnection(await _connectivity.checkConnectivity());
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final online = _hasConnection(results);
      if (online == _isOnline) return;
      _isOnline = online;
      _controller.add(online);
    });
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }

  static bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}

class FakeConnectivityService implements ConnectivityService {
  FakeConnectivityService({this._isOnline = true});

  final _controller = StreamController<bool>.broadcast();
  bool _isOnline;

  @override
  bool get isOnline => _isOnline;

  @override
  Stream<bool> get onStatusChanged => _controller.stream;

  void setOnline(bool value) {
    _isOnline = value;
    _controller.add(value);
  }
}
