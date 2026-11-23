import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_approval_app/core/connectivity/connectivity_service.dart';

class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(this._service) : super(_service.isOnline) {
    _subscription = _service.onStatusChanged.listen(emit);
  }

  final ConnectivityService _service;
  late final StreamSubscription<bool> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}