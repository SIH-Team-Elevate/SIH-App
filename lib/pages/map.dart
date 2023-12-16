import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sih_app/database/maps_api.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';
  MapController mapController = MapController();
  List listofpoints = [];
  List<LatLng> points = [];
  getCoordniates() async {
    var res = await http.get(getRouteUrl("77.1928,28.54", "77.1928,28.5357"));

    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);

      setState(() {
        listofpoints = data['features'][0]['geometry']['coordinates'];
        points = listofpoints.map((e) => LatLng(e[1], e[0])).toList();
        print(points);
      });
    }
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final camera = mapController;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    // Note this method of encoding the target destination is a workaround.
    // When proper animated movement is supported (see #1263) we should be able
    // to detect an appropriate animated movement event which contains the
    // target zoom/center.
    final startIdWithTarget =
        '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  void initState() {
    getCoordniates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: MediaQuery.of(context).size.width - 40,
      child: FlutterMap(
        options: MapOptions(
            initialCenter: const LatLng(
                28.54, 77.1928), // Center of the map (initially set to (0,0))
            initialZoom: 15.0,
            interactiveFlags: ~InteractiveFlag.rotate,
            keepAlive: true // Initial zoom level
            ),
        nonRotatedChildren: [
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () {},
              ),
            ],
          ),
        ],
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.insien',
            tileUpdateTransformer: _animatedMoveTileUpdateTransformer,
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 45.0,
                height: 45.0,
                point: const LatLng(28.5457,
                    77.1928), // Example landmark coordinates (San Francisco)
                child: Container(
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 45.0,
                  ),
                ),
              ),
              Marker(
                width: 45.0,
                height: 45.0,
                point: const LatLng(28.5357,
                    77.1928), // Example landmark coordinates (San Francisco)
                child: Container(
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 45.0,
                  ),
                ),
              ),
              // Add more markers for other landmarks here...
            ],
          ),
          PolylineLayer(polylines: [Polyline(points: points,color: Colors.blue,strokeWidth: 5)])
        ],
      ),
    );
  }
}

final _animatedMoveTileUpdateTransformer =
    TileUpdateTransformer.fromHandlers(handleData: (updateEvent, sink) {
  final mapEvent = updateEvent.mapEvent;

  final id = mapEvent is MapEventMove ? mapEvent.id : null;
  if (id?.startsWith(_MapScreenState._startedId) == true) {
    final parts = id!.split('#')[2].split(',');
    final lat = double.parse(parts[0]);
    final lon = double.parse(parts[1]);
    final zoom = double.parse(parts[2]);

    // When animated movement starts load tiles at the target location and do
    // not prune. Disabling pruning means existing tiles will remain visible
    // whilst animating.
    sink.add(
      updateEvent.loadOnly(
        loadCenterOverride: LatLng(lat, lon),
        loadZoomOverride: zoom,
      ),
    );
  } else if (id == _MapScreenState._inProgressId) {
    // Do not prune or load whilst animating so that any existing tiles remain
    // visible. A smarter implementation may start pruning once we are close to
    // the target zoom/location.
  } else if (id == _MapScreenState._finishedId) {
    // We already prefetched the tiles when animation started so just prune.
    sink.add(updateEvent.pruneOnly());
  } else {
    sink.add(updateEvent);
  }
});
