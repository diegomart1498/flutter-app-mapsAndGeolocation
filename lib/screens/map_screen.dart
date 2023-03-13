import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:maps_app/blocs/blocs.dart';
import 'package:maps_app/views/views.dart';
import 'package:maps_app/widgets/widgets.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LocationBloc locationBloc = BlocProvider.of<LocationBloc>(context);

  @override
  void initState() {
    super.initState();
    locationBloc.getCurrentPosition();
    locationBloc.startFollowingUser();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   locationBLoc.stopFollowingUser();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, locationState) {
          if (locationState.lastKnownLocation == null) {
            return const Center(child: Text('Espere por favor...'));
          }
          return BlocBuilder<MapBloc, MapState>(
            builder: (context, mapState) {
              Map<String, Polyline> polylinesToShow =
                  Map.from(mapState.polylines);
              if (!mapState.showMyRoute) {
                polylinesToShow.removeWhere((key, value) => key == 'myRoute');
              }
              return SingleChildScrollView(
                child: Stack(
                  children: [
                    MapView(
                      initialLocation: locationState.lastKnownLocation!,
                      polylines: polylinesToShow.values.toSet(),
                    ),
                    const SearchBar(),
                    const ManualMarker(),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          BtnToggleUserRoute(),
          BtnFollowUser(),
          BtnCurrentLocation(),
        ],
      ),
    );
  }
}
