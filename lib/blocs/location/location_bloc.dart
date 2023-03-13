import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:maps_app/blocs/blocs.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  StreamSubscription<Position>? positionStream;
  final GpsBloc _gpsBloc = GpsBloc();

  LocationBloc() : super(const LocationState()) {
    on<OnNewUserLocationEvent>((event, emit) {
      emit(state.copyWith(
        lastKnownLocation: event.newLocation,
        myLocationHistory: [...state.myLocationHistory, event.newLocation],
      ));
    });

    on<OnStartFollowingUserEvent>((event, emit) {
      emit(state.copyWith(followingUser: true));
    });

    on<OnStopFollowingUserEvent>((event, emit) {
      emit(state.copyWith(followingUser: false));
    });
  }

  Future getCurrentPosition() async {
    if (_gpsBloc.state.isAllGranted) return;
    final position = await Geolocator.getCurrentPosition();
    add(OnNewUserLocationEvent(LatLng(position.latitude, position.longitude)));
  }

  void startFollowingUser() {
    if (_gpsBloc.state.isAllGranted) return;
    add(OnStartFollowingUserEvent());
    positionStream = Geolocator.getPositionStream().listen((event) {
      add(OnNewUserLocationEvent(LatLng(event.latitude, event.longitude)));
    });
  }

  void stopFollowingUser() {
    positionStream?.cancel();
    add(OnStopFollowingUserEvent());
  }

  @override
  Future<void> close() {
    stopFollowingUser();
    return super.close();
  }
}
