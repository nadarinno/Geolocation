
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/firestoreservice.dart';
import '../services/locationservice.dart';
import '../model/store.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FirestoreService _firestore = FirestoreService();
  final LocationService _location = LocationService();

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  Position? userPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final stores = await _firestore.getStores();
      userPosition = await _location.getLocation();

      Set<Marker> tempMarkers = {};

      for (var store in stores) {
        tempMarkers.add(
          Marker(
            markerId: MarkerId(store.id),
            position: LatLng(store.lat, store.lng),
            infoWindow: InfoWindow(title: store.name),
            onTap: () {
              showStoreSheet(store);
              drawRoute(LatLng(store.lat, store.lng));
            },
          ),
        );
      }

     
      if (userPosition != null) {
        tempMarkers.add(
          Marker(
            markerId: const MarkerId("me"),
            position: LatLng(
              userPosition!.latitude,
              userPosition!.longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: const InfoWindow(title: "You"),
          ),
        );
      }

      setState(() {
        markers = tempMarkers;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading map data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  
  void handleMapTap(LatLng tappedPoint) {
    if (userPosition == null) return;

    markers.removeWhere((m) => m.markerId.value == "selected");

    final newMarker = Marker(
      markerId: const MarkerId("selected"),
      position: tappedPoint,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      ),
    );

    setState(() {
      markers.add(newMarker);
    });

    drawRoute(tappedPoint);
    showCustomLocationSheet(tappedPoint);
  }

  
  void drawRoute(LatLng target) {
    if (userPosition == null) return;

    setState(() {
      polylines.clear();
      polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          points: [
            LatLng(userPosition!.latitude, userPosition!.longitude),
            target,
          ],
          width: 5,
        ),
      );
    });
  }

  void showStoreSheet(Store store) {
    showCustomLocationSheet(LatLng(store.lat, store.lng),
        title: store.name);
  }

  void showCustomLocationSheet(LatLng point, {String title = "Selected Location"}) {
    if (userPosition == null) return;

    double distance = _location.calculateDistance(
      userPosition!.latitude,
      userPosition!.longitude,
      point.latitude,
      point.longitude,
    );

    String distanceText = _location.formatDistance(distance);
    String selectedMode = "car";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            String timeText =
                _location.estimateTravelTimeByMode(distance, selectedMode);

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 6),
                      Text("Distance: $distanceText"),
                    ],
                  ),

                  const SizedBox(height: 8),

                 
                  Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 6),
                      Text("Time: $timeText"),
                    ],
                  ),

                  const SizedBox(height: 16),

                 
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() => selectedMode = "car");
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedMode == "car"
                                  ? Colors.blue
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.directions_car),
                                SizedBox(width: 6),
                                Text("Car"),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() => selectedMode = "walk");
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedMode == "walk"
                                  ? Colors.blue
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.directions_walk),
                                SizedBox(width: 6),
                                Text("Walk"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        openMaps(point.latitude, point.longitude);
                      },
                      child: const Text("Open in Google Maps"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> openMaps(double lat, double lng) async {
    final url = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(31.95, 35.91),
                zoom: 13,
              ),
              markers: markers,
              polylines: polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,

             
              onTap: handleMapTap,
            ),
    );
  }
}