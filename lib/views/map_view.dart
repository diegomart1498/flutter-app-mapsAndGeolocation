import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:maps_app/blocs/blocs.dart';

class MapView extends StatelessWidget {
  final LatLng initialLocation;
  final Set<Polyline> polylines;

  const MapView({
    super.key,
    required this.initialLocation,
    required this.polylines,
  });

  @override
  Widget build(BuildContext context) {
    final mapBloc = BlocProvider.of<MapBloc>(context);
    final size = MediaQuery.of(context).size;
    final CameraPosition initial = CameraPosition(
      target: initialLocation,
      zoom: 15,
    );

    return SizedBox(
      height: size.height,
      width: size.width,
      child: Listener(
        onPointerMove: (event) {
          mapBloc.stopFollowingUser();
        },
        child: GoogleMap(
          initialCameraPosition: initial,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          polylines: polylines,
          onMapCreated: (controller) =>
              mapBloc.add(OnMapInitializedEvent(controller)),
          onCameraMove: (position) => mapBloc.mapCenter = position.target,
          //TODO: Markers
        ),
      ),
    );
  }
}
