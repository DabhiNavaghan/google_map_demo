import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  LocationData? currentLocation;

  getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then((value) {
      setState(() {
        currentLocation = value;
      });
    });

    GoogleMapController googleMapController = await controller.future;
    location.onLocationChanged.listen((event) {
      setState(() {
        currentLocation = event;
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(event.latitude!, event.longitude!), zoom: 14.5)));
      });
    });
    await getPont();
  }

  final Completer<GoogleMapController> controller = Completer();

  static const LatLng sourceLocation = LatLng(22.723912310847656, 71.65063850191078);
  static const LatLng destination = LatLng(22.71909908415007, 71.65542534717225);
  List<LatLng> polyPoints = [];

  Future<void> getPont() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );
    print(result.points);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) => polyPoints.add(LatLng(point.latitude, point.longitude)));
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Track order",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  getPont();
                },
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.black,
                ))
          ],
        ),
        body: currentLocation == null
            ? const Text("Loading....")
            : Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              // color: primaryTextGreyColor,
              width: 0.2,
            ),
          ),
          padding: const EdgeInsets.only(bottom: 5),
          margin: const EdgeInsets.only(top: 5),

              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                          zoom: 14.5,
                        ),
                      mapType: MapType.normal,
                      compassEnabled: false,
                      zoomControlsEnabled: false,
                      zoomGesturesEnabled: true,
                      rotateGesturesEnabled: false,
                      myLocationEnabled: true,
                      scrollGesturesEnabled: true,
                      myLocationButtonEnabled: true,
                        markers: {
                          Marker(markerId:  const MarkerId("currentLocation"), position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!)),
                          const Marker(markerId: MarkerId("destination"), position: destination),
                        },
                        onMapCreated: (mapController) {
                          controller.complete(mapController);
                        },
                      ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: Platform.isAndroid ? 5 : 65,
                    // top: !Platform.isAndroid ? 0 : 65.sp,
                    child: FloatingActionButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(300),
                      ),
                      elevation: 3.5,
                      onPressed: () {
                        String googleUrl =
                            "https://www.google.com/maps/search/?api=1&query=${currentLocation!.latitude!},${currentLocation!.longitude!}";
                        launch(googleUrl);

                      },
                      child: const Icon(
                        Icons.navigation,
                      ),
                    ),
                  )
                ],
              ),
            ));
  }
}
