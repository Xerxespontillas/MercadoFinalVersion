//new
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../providers/organization_provider.dart';

class OrganizationLocationScreen extends StatefulWidget {
  static const routeName = '/organizations-location';

  const OrganizationLocationScreen({super.key});

  static Route route() {
    return MaterialPageRoute(
      builder: (BuildContext context) => const OrganizationLocationScreen(),
    );
  }

  @override
  OrganizationLocationScreenState createState() =>
      OrganizationLocationScreenState();
}

class OrganizationLocationScreenState
    extends State<OrganizationLocationScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  LatLng _organizationLocation = const LatLng(10.293992, 123.897498);
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

  Future<BitmapDescriptor> organizationMarker() async {
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'assets/images/farmers_org_marker.png',
    );
  }

  void _subscribeToLocationUpdates() {
    final OrganizationProvider organizationProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    Geolocator.isLocationServiceEnabled().then((serviceEnabled) {
      if (!serviceEnabled) {
        return;
      }

      Geolocator.checkPermission().then((permission) async {
        if (permission == LocationPermission.denied) {
          return;
        }

        final organization =
            await organizationProvider.getCurrentorganization();

        _positionStreamSubscription = Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
          timeLimit: Duration(seconds: 5),
        )).listen((Position position) async {
          final organizationIcon = await organizationMarker();
          if (mounted) {
            setState(() {
              _organizationLocation =
                  LatLng(position.latitude, position.longitude);
              _markers.clear(); // Clear previous markers
              _markers.add(
                Marker(
                  markerId: MarkerId(organization?.orgName ?? 'organization'),
                  position: _organizationLocation,
                  icon: organizationIcon, // Use custom bus marker icon
                  infoWindow: InfoWindow(
                    title: organization?.orgName ?? 'Farmers Organization',
                    snippet: organization?.address ?? 'Organization Address',
                  ),
                ),
              );
              _mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: _organizationLocation, zoom: 20),
                ),
              );
              if (organization != null) {
                FirebaseFirestore.instance
                    .collection('orgLocations')
                    .doc(organization.orgName)
                    .set({
                  'latitude': _organizationLocation.latitude,
                  'longitude': _organizationLocation.longitude,
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
      appBar: AppBar(title: const Text('Organization Current Location')),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _organizationLocation,
          zoom: 20,
        ),
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _organizationLocation, zoom: 15),
          ),
        ),
        child: const Icon(
          Icons.center_focus_strong,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
