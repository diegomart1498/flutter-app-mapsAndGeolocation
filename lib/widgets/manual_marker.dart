import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';

import 'package:maps_app/blocs/blocs.dart';
import 'package:maps_app/helpers/helpers.dart';

class ManualMarker extends StatelessWidget {
  const ManualMarker({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return (state.displayManualMarker)
            ? const _ManualMarkerBody()
            : const SizedBox();
      },
    );
  }
}

class _ManualMarkerBody extends StatelessWidget {
  const _ManualMarkerBody();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          const Positioned(
            top: 60,
            left: 15,
            child: _BtnBack(),
          ),
          Positioned(
            bottom: 30,
            left: 26,
            child: _BtnConfirm(size),
          ),
          Center(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: BounceInDown(
                from: 100,
                child: const Icon(
                  Icons.location_on_sharp,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BtnBack extends StatelessWidget {
  const _BtnBack();
  @override
  Widget build(BuildContext context) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 300),
      child: CircleAvatar(
        maxRadius: 25,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.black,
            size: 25,
          ),
          onPressed: () {
            BlocProvider.of<SearchBloc>(context)
                .add(OnDesactivateManualMarkerEvent());
          },
        ),
      ),
    );
  }
}

class _BtnConfirm extends StatelessWidget {
  final Size size;
  const _BtnConfirm(this.size);
  @override
  Widget build(BuildContext context) {
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    final locationBloc = BlocProvider.of<LocationBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: MaterialButton(
        shape: const StadiumBorder(),
        color: Colors.black,
        minWidth: size.width - 120,
        height: 40,
        elevation: 5,
        onPressed: () async {
          final start = locationBloc.state.lastKnownLocation;
          if (start == null) return;

          final end = mapBloc.mapCenter;
          if (end == null) return;

          showLoadingMessage(context);

          final destination = await searchBloc.getCoorsStartToEnd(start, end);
          await mapBloc.drawRouteDestination(destination);

          searchBloc.add(OnDesactivateManualMarkerEvent());
          if (context.mounted) Navigator.pop(context);
        },
        child: const Text(
          'Confirmar destino',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
