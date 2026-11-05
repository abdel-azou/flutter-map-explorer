import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/mural.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MuralMap extends StatefulWidget {
  const MuralMap({super.key, required this.murals});

  final List<Mural> murals;

  @override
  State<MuralMap> createState() => _MuralMapState();
}

class _MuralMapState extends State<MuralMap> {
  final _mapController = MapController.withPosition(
    initPosition: GeoPoint(latitude: 50.8466, longitude: 4.3528),
  );

  @override
  void dispose() {
    // Libération des ressources du contrôleur
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OSMFlutter(
      controller: _mapController,
      onMapIsReady: _onMapReady,
      onGeoPointClicked: _onMarkerTap,
      osmOption: OSMOption(
        zoomOption: const ZoomOption(
          initZoom: 13,
          minZoomLevel: 5,
          maxZoomLevel: 19,
        ),
      ),
      mapIsLoading: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _onMapReady(bool isReady) async {
    if (!isReady) return;
    final geoPoints = widget.murals.map((mural) {
      return GeoPoint(latitude: mural.latitude, longitude: mural.longitude);
    }).toList();
    for (final geoPoint in geoPoints) {
      await _mapController.addMarker(
        geoPoint,
        markerIcon: const MarkerIcon(
          iconWidget: SizedBox.square(
            dimension: 48,
            child: Icon(Icons.place, color: Colors.red, size: 48),
          ),
        ),
      );
    }
  }

  void _onMarkerTap(GeoPoint point) {
    final mural = widget.murals.firstWhere(
          (mural) =>
      mural.latitude == point.latitude &&
          mural.longitude == point.longitude,
    );
    context.go('/mural', extra: mural);
  }
}