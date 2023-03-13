import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

part 'gps_event.dart';
part 'gps_state.dart';

class GpsBloc extends Bloc<GpsEvent, GpsState> {
  StreamSubscription? gpsServiceSubscription;
  GpsBloc()
      : super(const GpsState(
          isGpsEnabled: false,
          isGpsPermissionGranted: false,
        )) {
    on<GpsAndPermissionEvent>((event, emit) {
      emit(state.copyWith(
        isGpsEnabled: event.isGpsEnabled,
        isGpsPermissionGranted: event.isGpsPermissionGranted,
      ));
    });
    _init();
  }

  Future<void> _init() async {
    // final isEnabled = await _checkGpsStatus();
    // final isGranted = await _isPermissionGranted();
    //* Ejecuta los dos awaits al mismo tiempo y los guarda en una lista
    final gpsInitStatus = await Future.wait([
      _checkGpsStatus(),
      _isPermissionGranted(),
    ]);
    //* Este evento se realiza una única vez al iniciar la aplicación, por que se llama en el constructor
    add(GpsAndPermissionEvent(
      isGpsEnabled: gpsInitStatus[0],
      isGpsPermissionGranted: gpsInitStatus[1],
    ));
  }

  Future<bool> _isPermissionGranted() async {
    final isGranted = await Permission.location.isGranted;
    return isGranted;
  }

  Future<bool> _checkGpsStatus() async {
    //* Verifica si la localización está activada
    final isEnable = await Geolocator.isLocationServiceEnabled();

    //* Se queda escuchando por medio del Stream el cambio del toggle de localización
    gpsServiceSubscription =
        Geolocator.getServiceStatusStream().listen((event) {
      final isEnabled = (event.index == 1) ? true : false;
      add(GpsAndPermissionEvent(
        isGpsEnabled: isEnabled,
        isGpsPermissionGranted: state.isGpsPermissionGranted,
      ));
    });
    return isEnable;
  }

  Future<void> askGpsAccess() async {
    //* Pide permiso al usuario si no se ha solicitado antes
    //* Si ya ha sido otorgado, no se vuelve a ejecutar el dialog de solicitud
    final status = await Permission.location.request();
    switch (status) {
      case PermissionStatus.granted:
        add(GpsAndPermissionEvent(
          isGpsEnabled: state.isGpsEnabled,
          isGpsPermissionGranted: true,
        ));
        break;
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        add(GpsAndPermissionEvent(
          isGpsEnabled: state.isGpsEnabled,
          isGpsPermissionGranted: false,
        ));
        openAppSettings();
        break;
    }
  }

  @override
  Future<void> close() {
    gpsServiceSubscription?.cancel();
    return super.close();
  }
}
