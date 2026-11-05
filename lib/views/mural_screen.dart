import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart'; // Import nécessaire pour Geolocator.distanceBetween
import '../models/mural.dart';

class MuralScreen extends StatefulWidget {
  const MuralScreen({super.key, required this.mural, this.userPosition});

  final Mural mural;
  final Position? userPosition;

  @override
  State<MuralScreen> createState() => _MuralScreenState();
}

class _MuralScreenState extends State<MuralScreen> {
  late final MapController _miniMapController;

  @override
  void initState() {
    super.initState();
    _miniMapController = MapController.withPosition(
      initPosition: GeoPoint(
        latitude: widget.mural.latitude,
        longitude: widget.mural.longitude,
      ),
    );
  }

  @override
  void dispose() {
    _miniMapController.dispose();
    super.dispose();
  }

  Future<void> _onMiniMapReady(bool isReady) async {
    if (!isReady) return;

    await _miniMapController.addMarker(
      GeoPoint(
        latitude: widget.mural.latitude,
        longitude: widget.mural.longitude,
      ),
      markerIcon: const MarkerIcon(
        iconWidget: SizedBox.square(
          dimension: 48,
          child: Icon(Icons.place, color: Colors.red, size: 48),
        ),
      ),
    );


    final userPosition = widget.userPosition;
    if (userPosition != null) {
      await _miniMapController.addMarker(
        GeoPoint(
          latitude: userPosition.latitude,
          longitude: userPosition.longitude,
        ),
        markerIcon: const MarkerIcon(
          iconWidget: SizedBox.square(
            dimension: 48,
            child: Icon(Icons.my_location, color: Colors.blue, size: 48),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 800;


    double? distance;
    var userPosition = widget.userPosition;
    if (userPosition != null) {
      distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        widget.mural.latitude,
        widget.mural.longitude,
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Détails de la fresque'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(widget.mural.imageUrl, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.80),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.mural.name,
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.mural.artist,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.mural.year} • ${widget.mural.publisher}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.mural.address,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: isWide ? 300 : 150,
                            height: isWide ? 160 : 120,
                            child: OSMFlutter(
                              controller: _miniMapController,
                              onMapIsReady: _onMiniMapReady,
                              osmOption: OSMOption(
                                showZoomController: false,
                                zoomOption: const ZoomOption(
                                  initZoom: 16,
                                  minZoomLevel: 5,
                                  maxZoomLevel: 19,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Distance : ${distance != null ? '${distance.toStringAsFixed(2)} m' : '--- m'}",
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}