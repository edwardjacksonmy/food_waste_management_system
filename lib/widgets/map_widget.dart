// map_widget.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final Function(double, double)? onLocationChanged;
  final bool isInteractive;

  const MapWidget({
    Key? key,
    required this.latitude,
    required this.longitude,
    this.onLocationChanged,
    this.isInteractive = true,
  }) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _controller;
  late LatLng _markerPosition;

  @override
  void initState() {
    super.initState();
    _markerPosition = LatLng(widget.latitude, widget.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.latitude, widget.longitude),
            zoom: 15,
          ),
          onMapCreated: (controller) {
            _controller = controller;
          },
          markers: {
            Marker(
              markerId: MarkerId('selected_location'),
              position: _markerPosition,
              draggable: widget.isInteractive,
              onDragEnd: (newPosition) {
                setState(() {
                  _markerPosition = newPosition;
                });
                if (widget.onLocationChanged != null) {
                  widget.onLocationChanged!(
                    newPosition.latitude,
                    newPosition.longitude,
                  );
                }
              },
            ),
          },
          onTap:
              widget.isInteractive
                  ? (position) {
                    setState(() {
                      _markerPosition = position;
                    });
                    if (widget.onLocationChanged != null) {
                      widget.onLocationChanged!(
                        position.latitude,
                        position.longitude,
                      );
                    }
                  }
                  : null,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          mapToolbarEnabled: false,
        ),
        if (widget.isInteractive)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Tap or drag marker to set location',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
