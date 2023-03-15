import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

import 'package:maps_app/models/models.dart';
import 'package:maps_app/services/services.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  TrafficService trafficService;

  SearchBloc({required this.trafficService}) : super(const SearchState()) {
    on<OnActivateManualMarkerEvent>((event, emit) {
      emit(state.copyWith(displayManualMarker: true));
    });
    on<OnDesactivateManualMarkerEvent>((event, emit) {
      emit(state.copyWith(displayManualMarker: false));
    });
    on<OnNewPlacesFoundEvent>((event, emit) {
      emit(state.copyWith(places: event.places));
    });
    on<OnAddToHistoryEvent>((event, emit) {
      final historyNames = state.history.map((place) => place.text).toList();
      final isAlready = historyNames.contains(event.place.text);
      if (isAlready) {
        final history = state.history;
        final index =
            history.indexWhere((place) => place.text == event.place.text);
        history.removeAt(index);
        final historyNew = [event.place, ...history];
        emit(state.copyWith(history: historyNew));
      } else {
        emit(state.copyWith(history: [event.place, ...state.history]));
      }
    });
  }

  Future<RouteDestination> getCoorsStartToEnd(LatLng start, LatLng end) async {
    final traffinResponse = await trafficService.getCoorsStartToEnd(start, end);
    //  Información del destino
    final endPlace = await trafficService.getInformationByCoors(end);
    final geometry = traffinResponse.routes[0].geometry;
    final distance = traffinResponse.routes[0].distance;
    final duration = traffinResponse.routes[0].duration;
    //Decodificación
    final points = decodePolyline(geometry, accuracyExponent: 6);
    final latLngList = points
        .map((coors) => LatLng(coors[0].toDouble(), coors[1].toDouble()))
        .toList();
    return RouteDestination(
      points: latLngList,
      duration: duration,
      distance: distance,
      endPlace: endPlace,
    );
  }

  Future<void> getPlacesByQuery(LatLng proximity, String query) async {
    final newPlaces = await trafficService.getResultsByQuery(proximity, query);
    add(OnNewPlacesFoundEvent(newPlaces));
  }
}
