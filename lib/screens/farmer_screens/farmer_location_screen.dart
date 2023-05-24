//new
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../providers/farmers_provider.dart';

class FarmerLocationScreen extends StatefulWidget {
  static const routeName = '/farmers-location';

  const FarmerLocationScreen({super.key});

  static Route route() {
    return MaterialPageRoute(
      builder: (BuildContext context) => const FarmerLocationScreen(),
    );
  }

  @override
  FarmerLocationScreenState createState() => FarmerLocationScreenState();
}

class FarmerLocationScreenState extends State<FarmerLocationScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  LatLng _farmersLocation = const LatLng(10.293992, 123.897498);
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _subscribeToLocationUpdates();
  }

  Future<void> _requestLocationPermission() async {
    await Permission.location.request();
  }

  Future<BitmapDescriptor> farmersMarker() async {
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'assets/images/farmers_marker.png',
    );
  }

  void _subscribeToLocationUpdates() {
    final FarmersProvider farmersProvider =
        Provider.of<FarmersProvider>(context, listen: false);

    Geolocator.isLocationServiceEnabled().then((serviceEnabled) {
      if (!serviceEnabled) {
        return;
      }

      Geolocator.checkPermission().then((permission) async {
        if (permission == LocationPermission.denied) {
          return;
        }

        final farmers = farmersProvider.currentFarmers;
        _positionStreamSubscription = Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
          timeLimit: Duration(seconds: 5),
        )).listen((Position position) async {
          final farmersIcon = await farmersMarker();
          if (mounted) {
            setState(() {
              _farmersLocation = LatLng(position.latitude, position.longitude);
              _markers.clear(); // Clear previous markers
              _markers.add(
                Marker(
                  markerId: MarkerId(farmers?.fullName ?? 'farmers'),
                  position: _farmersLocation,
                  icon: farmersIcon, // Use custom bus marker icon
                  infoWindow: InfoWindow(
                    title: farmers?.fullName ?? 'Farmer',
                    snippet: farmers?.address ?? 'Farmer\'s Address',
                  ),
                ),
              );
              _mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: _farmersLocation, zoom: 20),
                ),
              );
              if (farmers != null) {
                FirebaseFirestore.instance
                    .collection('farmersLocations')
                    .doc(farmers.fullName)
                    .set({
                  'latitude': _farmersLocation.latitude,
                  'longitude': _farmersLocation.longitude,
                });
              }
            });
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmers Current Location')),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _farmersLocation,
          zoom: 20,
        ),
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _farmersLocation, zoom: 15),
          ),
        ),
        child: const Icon(
          Icons.center_focus_strong,
          color: Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
