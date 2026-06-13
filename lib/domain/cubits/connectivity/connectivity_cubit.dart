import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'connectivity_state.dart';
import '../../../core/utils/connectivity_service.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService _connectivityService;
  StreamSubscription? _subscription;

  ConnectivityCubit(this._connectivityService)
      : super(const ConnectivityState()) {
    _monitorConnectivity();
  }

  void _monitorConnectivity() {
    _connectivityService.isConnected().then((connected) {
      emit(state.copyWith(isOnline: connected));
    });

    _subscription = _connectivityService.onConnectivityChanged.listen((isOnline) {
      emit(state.copyWith(isOnline: isOnline));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
