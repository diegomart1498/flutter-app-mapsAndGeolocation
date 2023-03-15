import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:maps_app/blocs/blocs.dart';
import 'package:maps_app/helpers/helpers.dart';
import 'package:maps_app/models/models.dart';
import 'package:maps_app/themes/themes.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final LocationBloc locationBloc;
  GoogleMapController? _mapController;
  LatLng? mapCenter;
  StreamSubscription<LocationState>? locationStateSubscription;

  MapBloc({required this.locationBloc}) : super(const MapState()) {
    on<OnMapInitializedEvent>(_onInitMap);

    locationStateSubscription = locationBloc.stream.listen((locationState) {
      if (locationState.lastKnownLocation != null) {
        add(UpdateUserPolylinesEvent(locationState.myLocationHistory));
      }
      if (!state.isFollowingUser) return;
      if (locationState.lastKnownLocation == null) return;
      moveCamera(locationState.lastKnownLocation!);
    });

    on<UpdateUserPolylinesEvent>(_onPolylineNewPoint);

    on<OnStartFolloUserEvent>((event, emit) {
      emit(state.copyWith(isFollowingUser: true));
      if (locationBloc.state.lastKnownLocation == null) return;
      moveCamera(locationBloc.state.lastKnownLocation!);
    });

    on<OnStopFollowUserEvent>((event, emit) {
      emit(state.copyWith(isFollowingUser: false));
    });

    on<OnToggleUserRoute>((event, emit) {
      emit(state.copyWith(showMyRoute: !state.showMyRoute));
    });

    on<OnDisplayPolylinesEvent>((event, emit) {
      emit(state.copyWith(polylines: event.polylines, markers: event.markers));
    });
  }

  void _onInitMap(OnMapInitializedEvent event, Emitter<MapState> emit) {
    _mapController = event.controller;
    _mapController!.setMapStyle(jsonEncode(uberMapTheme));
    emit(state.copyWith(isMapInitialized: true));
  }

  void _onPolylineNewPoint(
      UpdateUserPolylinesEvent event, Emitter<MapState> emit) {
    final myRoute = Polyline(
      polylineId: const PolylineId('myRoute'),
      color: Colors.black,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      points: event.userLocations,
    );
    final currentPolylines = Map<String, Polyline>.from(state.polylines);
    currentPolylines['myRoute'] = myRoute;
    emit(state.copyWith(polylines: currentPolylines));
  }

  Future<void> drawRouteDestination(RouteDestination destination) async {
    final myRoute = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.black,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      points: destination.points,
    );

    double kms = (((destination.distance / 1000) * 100).floorToDouble() / 100);
    kms = ((kms * 10).floorToDouble()) / 10;
    int tripDuration = (destination.duration / 60).floorToDouble().toInt();

    // Custom Markers
    // final startMarkerIcon = await getAssetImageMarker();
    // final endMarketIcon = await getNetworkImageMarker();
    final startMarkerIcon =
        await getStartCustomMarker(tripDuration, 'Punto de partida');
    final endMarketIcon =
        await getEndCustomMarker(kms, destination.endPlace.text);

    final startMarker = Marker(
      markerId: const MarkerId('start'),
      position: destination.points.first,
      anchor: const Offset(0.05, 1),
      // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      icon: startMarkerIcon,
    );
    final endMarker = Marker(
      markerId: const MarkerId('end'),
      position: destination.points.last,
      icon: endMarketIcon,
    );

    final currentPolylines = Map<String, Polyline>.from(state.polylines);
    final currentMarkers = Map<String, Marker>.from(state.markers);
    currentPolylines['route'] = myRoute;
    currentMarkers['start'] = startMarker;
    currentMarkers['end'] = endMarker;

    add(OnDisplayPolylinesEvent(currentPolylines, currentMarkers));
    await Future.delayed(const Duration(milliseconds: 300));
    _mapController?.showMarkerInfoWindow(const MarkerId('end'));
  }

  void moveCamera(LatLng newLocation) {
    final cameraUpdate = CameraUpdate.newLatLngZoom(newLocation, 17);
    _mapController?.animateCamera(cameraUpdate);
  }

  void startFollowingUser() {
    add(OnStartFolloUserEvent());
  }

  void stopFollowingUser() {
    add(OnStopFollowUserEvent());
  }

  // @override
  // Future<void> close() {
  //   locationStateSubscription?.cancel();
  //   return super.close();
  // }
}
