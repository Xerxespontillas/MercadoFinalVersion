//new
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:merkado/providers/customer_provider.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class UserLocationScreen extends StatefulWidget {
  static const routeName = '/user-location';

  const UserLocationScreen({super.key});

  @override
  UserLocationScreenState createState() => UserLocationScreenState();
}

class UserLocationScreenState extends State<UserLocationScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  LatLng _userLocation = const LatLng(10.298333, 123.893366);
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

  Future<BitmapDescriptor> userMarker() async {
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'assets/images/user_marker.png',
    );
  }

  void _subscribeToLocationUpdates() {
    final CustomersProvider customersProvider =
        Provider.of<CustomersProvider>(context, listen: false);

    Geolocator.isLocationServiceEnabled().then((serviceEnabled) {
      if (!serviceEnabled) {
        return;
      }

      Geolocator.checkPermission().then((permission) async {
        if (permission == LocationPermission.denied) {
          return;
        }

        final customer = customersProvider.currentCustomers;
        _positionStreamSubscription = Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
          timeLimit: Duration(seconds: 5),
        )).listen((Position position) async {
          final userIcon = await userMarker();
          if (mounted) {
            setState(() {
              _userLocation = LatLng(position.latitude, position.longitude);
              _markers.clear(); // Clear previous markers
              _markers.add(
                Marker(
                  markerId: MarkerId(customer?.name ?? 'user'),
                  position: _userLocation,
                  icon: userIcon, // Use custom bus marker icon
                  infoWindow: InfoWindow(
                    title: customer?.name ?? 'User',
                  ),
                  consumeTapEvents: false,
                ),
              );
              _mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: _userLocation, zoom: 20),
                ),
              );
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
      appBar: AppBar(title: const Text('User Current Location')),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _userLocation,
          zoom: 20,
        ),
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _userLocation, zoom: 15),
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
