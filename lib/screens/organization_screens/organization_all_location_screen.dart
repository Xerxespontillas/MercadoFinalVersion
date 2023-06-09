//new
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:permission_handler/permission_handler.dart';

class OrgAllLocationScreen extends StatefulWidget {
  static const routeName = '/org-all-location';

  const OrgAllLocationScreen({super.key});

  @override
  OrgAllLocationScreenState createState() => OrgAllLocationScreenState();
}

class OrgAllLocationScreenState extends State<OrgAllLocationScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Marker> _orgMarkers = {};
  final Set<Marker> _farmerMarkers = {};
  final LatLng _userLocation = const LatLng(10.293992, 123.897498);
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _subscribeToLocationUpdates();
    _subscribeToOrgLocationUpdates();
    _subscribeToFarmersLocationUpdates();
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

  Future<BitmapDescriptor> farmersMarker() async {
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'assets/images/farmers_marker.png',
    );
  }

  void _subscribeToFarmersLocationUpdates() {
    final FirebaseFirestore database = FirebaseFirestore.instance;
    final farmerLocationRef = database.collection('farmersLocations');
    farmerLocationRef.snapshots().listen((QuerySnapshot snapshot) async {
      // Clear all previous farmeranization markers
      _farmerMarkers.clear();

      // Loop through each document in the snapshot
      for (DocumentSnapshot doc in snapshot.docs) {
        // Get farmeranization data from document
        Map<String, dynamic> farmerData = doc.data() as Map<String, dynamic>;

        // Extract latitude and longitude values from the 'location' field
        double latitude = farmerData['latitude'];
        double longitude = farmerData['longitude'];

        // Create LatLng object from latitude and longitude
        LatLng farmerLocation = LatLng(latitude, longitude);

        // Fetch the farmeranization icon
        final farmerIcon = await farmersMarker();

        // Add a new Marker to the _orgMarkers Set for each organization
        _orgMarkers.add(
          Marker(
            markerId: MarkerId(doc.id), // Use the document ID as the marker ID
            position: farmerLocation,
            icon: farmerIcon,
            infoWindow: InfoWindow(
              title: doc.id, // Use the document ID as the organization name
            ),
          ),
        );
      }

      if (mounted) {
        // Update the state to reflect the new markers
        setState(() {
          _markers.addAll(_farmerMarkers);
        });
      }
    });
  }

  void _subscribeToOrgLocationUpdates() {
    final FirebaseFirestore database = FirebaseFirestore.instance;
    final orgLocationRef = database.collection('orgLocations');
    orgLocationRef.snapshots().listen((QuerySnapshot snapshot) async {
      // Clear all previous organization markers
      _orgMarkers.clear();

      // Loop through each document in the snapshot
      for (DocumentSnapshot doc in snapshot.docs) {
        // Get organization data from document
        Map<String, dynamic> orgData = doc.data() as Map<String, dynamic>;

        // Extract latitude and longitude values from the 'location' field
        double latitude = orgData['latitude'];
        double longitude = orgData['longitude'];

        // Create LatLng object from latitude and longitude
        LatLng orgLocation = LatLng(latitude, longitude);

        // Fetch the organization icon
        final orgIcon = await organizationMarker();

        // Add a new Marker to the _orgMarkers Set for each organization
        _orgMarkers.add(
          Marker(
            markerId: MarkerId(doc.id), // Use the document ID as the marker ID
            position: orgLocation,
            icon: orgIcon,
            infoWindow: InfoWindow(
              title: doc.id, // Use the document ID as the organization name
            ),
          ),
        );
      }

      if (mounted) {
        // Update the state to reflect the new markers
        setState(() {
          _markers.addAll(_orgMarkers);
        });
      }
    });
  }

  void _subscribeToLocationUpdates() {
    Geolocator.isLocationServiceEnabled().then((serviceEnabled) {
      if (!serviceEnabled) {
        return;
      }

      Geolocator.checkPermission().then((permission) async {
        if (permission == LocationPermission.denied) {
          return;
        }

        _positionStreamSubscription = Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
          timeLimit: Duration(seconds: 5),
        )).listen((Position position) async {
          if (mounted) {
            setState(() {
              _markers
                ..clear()
                ..addAll(_orgMarkers)
                ..addAll(_farmerMarkers);
              _mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: _userLocation, zoom: 15),
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
      appBar: AppBar(title: const Text('Organization All Location')),
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
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
