import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationExample extends StatefulWidget {
  const LocationExample({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LocationExampleState createState() => _LocationExampleState();
}

class _LocationExampleState extends State<LocationExample> {
  String _locationMessage = "Press the button to get your location";
  bool _isButtonEnabled = true;
  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('Location permission granted');
    } else {
      print('Location permission denied');
    }
  }

  Future<Position> getLocationWithRetry(int retries, int delaySeconds) async {
    for (int i = 0; i < retries; i++) {
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
          forceAndroidLocationManager: true,
          timeLimit: const Duration(seconds: 10),
        );
      } on TimeoutException {
        if (i == retries - 1) rethrow; // If retries exhausted, rethrow exception
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }
    throw Exception('Failed to get location after $retries retries.');
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _locationMessage = "";
      _isButtonEnabled = false;
    });
    bool serviceEnabled;
    LocationPermission permission;
    try {
      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationMessage = "Location services are disabled.";
          _isButtonEnabled = true;
        });
        return;
      }
      
      // Request permission
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationMessage = "Location permissions are denied.";
            _isButtonEnabled = true;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationMessage =
              "Location permissions are permanently denied. Cannot access location.";
          _isButtonEnabled = true;
        });
        return;
      }
    
      Position position = await getLocationWithRetry(3, 5); // 3 retries, 5s delay
      setState(() {
        _locationMessage = "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
        _isButtonEnabled = true;
      });
    } catch (e) {
      setState(() {
        _locationMessage = "Error: $e";
        _isButtonEnabled = true;
      });
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LocateWidget(locate: _locationMessage),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isButtonEnabled ? _getCurrentLocation : null,
            child: const Text('Get Current Location'),
          ),
        ],
      ),
    );
  }
}

class LocateWidget extends StatelessWidget {
  final String locate;
  const LocateWidget({super.key, required this.locate});

  @override
  Widget build(BuildContext context) {

    return locate.isEmpty
        ? const CircularProgressIndicator()
        : Text(locate);
  }
}