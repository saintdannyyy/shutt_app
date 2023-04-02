import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/material.dart';
import 'dart:math' show cos, sqrt, asin;
import 'dart:async';

import 'package:location/location.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shutt_app/models/Stop.dart';
import 'package:shutt_app/services/dbService.dart';
import 'package:shutt_app/styles/colors.dart';
import 'package:uuid/uuid.dart';

import '../models/Bus.dart';
import '../models/Ride.dart';
import '../models/BusRoute.dart';

class MapProvider with ChangeNotifier {
  initialize() async {
    // await getCurrentLocation();
    // await animateCamera();
  }

  String locationTextState = "";

  TextEditingController pickUpPointController = TextEditingController();
  TextEditingController dropOffPointController = TextEditingController();

  Location location = Location();
  LocationData? userLocation;

  Stop? pickupPoint;
  Stop? dropOffPoint;
  Bus? busOnRoute;
  double arrivalMins = 10;
  Ride? ride;
  String? rideUid;
  Marker? busMarker;
  bool loading = false;
  String snackBarMessage = "";
  BusRoute? tripRoute;
  List<Stop> allStops = [];
  final uuid = const Uuid();
  int timeToPickUp = 0;
  int timeToDropOff = 0;
  double rating = 0;

  //  this variable will listen to the status of the ride request
  StreamSubscription<QuerySnapshot>? rideRequestStream;
  // this variable will keep track of the drivers position before and during the ride
  StreamSubscription<QuerySnapshot>? busStream;
//  this stream is for all the driver on the app
  StreamSubscription<List<Bus>>? allBusesStream;

  final _dbService = dbService();

  int orderState = 1;
  // Order State 1 = Making order
  // Order State 2 = Waiting for bus
  // Order State 3 = Bus arrived at pickup
  // Order State 4 = On bus
  // Order State 5 = Bus arrived at drop off
  // Order State 6 = Rate ride

  void setOrderState(int val) {
    orderState = val;
    notifyListeners();
  }

  Set<Marker> markers = {};
  // Map<PolylineId, Polyline> polylines = {};
  Set<Polyline> polylines = {};
  final Geolocator geolocator = Geolocator();
  Position? currentPosition;
  GoogleMapController? mapController;
  PolylinePoints? polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Completer<GoogleMapController> controller = Completer();
  String? userID;
  BitmapDescriptor? busIcon;
  BitmapDescriptor? locationIcon;
  LatLng? _center;
  LatLng get center => _center ?? const LatLng(0, 0);
  CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(5.6506, -0.1962), zoom: 15.5);

  String? placeDistance;

  onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    trackUserLocation();
    notifyListeners();

    await animateCamera();

    busIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/Bus_icon.png",
    );
    locationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/location_marker.png",
    );
    notifyListeners();
  }

  trackUserLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    try {
      location.onLocationChanged.listen((LocationData currentLocation) {
        userLocation = currentLocation;
        // print(
        // "User Location: {${userLocation!.latitude}, ${userLocation!.longitude})");
        notifyListeners();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  animateCamera() async {
    var pos = await location.getLocation();
    mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(pos.latitude!, pos.longitude!), zoom: 17)));
    notifyListeners();
  }

  moveCamera(LatLng newPosition) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: newPosition,
          zoom: 18.0,
        ),
      ),
    );
  }

  addMarker(LatLng location, title,
      {BitmapDescriptor icon = BitmapDescriptor.defaultMarker}) {
    Marker newMarker = Marker(
      markerId: MarkerId('${location.latitude}-${location.longitude}'),
      position: location,
      infoWindow: InfoWindow(
        title: title,
      ),
      icon: icon,
    );

    markers.add(newMarker);

    notifyListeners();
  }

  addBusToMap(Bus bus) {
    LatLng latLng = new LatLng(bus.location.latitude, bus.location.longitude);

    print("Bus icon: $busIcon");

    Marker newMarker = Marker(
      markerId: MarkerId('${latLng.latitude}-${latLng.longitude}'),
      position: latLng,
      infoWindow: InfoWindow(
        title: bus.registrationNumber,
      ),
      icon: busIcon ?? BitmapDescriptor.defaultMarker,
    );

    markers.add(newMarker);
    busMarker = newMarker;
    notifyListeners();
  }

  getAllStops() async {
    allStops = await _dbService.retrieveStops();
    notifyListeners();
  }

  addBusesToMap(List<Bus> buses) {
    // markers = {};
    for (Bus bus in buses) {
      LatLng latLng = new LatLng(bus.location.latitude, bus.location.longitude);

      Marker newMarker = Marker(
        markerId: MarkerId('${latLng.latitude}-${latLng.longitude}'),
        position: latLng,
        infoWindow: InfoWindow(
          title: bus.registrationNumber,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      markers.add(newMarker);
    }

    notifyListeners();
  }

  Future<void> createPolylines(LatLng start, LatLng destination, color) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult? result = await polylinePoints?.getRouteBetweenCoordinates(
      'AIzaSyA1fhjNGWYmYfsdccOjT8tQkdYZHTh6ve0', // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
    );

    // Adding the coordinates to the list
    if (result?.points.isNotEmpty ?? false) {
      result?.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: color,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    // polylines[id] = polyline;
    polylines.add(polyline);
    notifyListeners();
  }

  onCreate(GoogleMapController controller) {
    mapController = controller;
    notifyListeners();
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  calculateDistance() {
    double totalDistance = 0.0;

// Calculating the total distance by adding the distance
// between small segments
    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += _coordinateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }

    placeDistance = totalDistance.toStringAsFixed(2);
    print('DISTANCE: $placeDistance km');
  }

  Future<void> gotoLocation(double lat, double long) async {
    final GoogleMapController _controller = await controller.future;
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 15,
      tilt: 50.0,
      bearing: 45.0,
    )));
    notifyListeners();
  }

  setCustomMapPin(String image) async {
    BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), image);
    return icon;
  }

  // getStops() {
  //   final Stream<QuerySnapshot> stops =
  //       FirebaseFirestore.instance.collection("stops").snapshots();
  // }

  listenToBuses() {
    allBusesStream = _dbService.getBuses().listen(addBusesToMap);
  }

  listenToBus() {
    print("listening to bus....");
    busStream = _dbService.busStream().listen((event) {
      event.docChanges.forEach((change) async {
        // print(change.doc.data());
        if (change.doc.id == busOnRoute?.uid) {
          var tempBus = (change.doc.data() as Map<String, dynamic>);
          tempBus["uid"] = change.doc.id;

          busOnRoute = Bus.fromDocumentSnapshot(
              (change.doc as DocumentSnapshot<Map<String, dynamic>>));
          // code to update marker

          markers.remove(busMarker);
          addBusToMap(busOnRoute!);

          // print('${busToPickUp()}----${userToPickUp()}');
          // print(orderState);

          trackRideState();
          trackRideVars();
        }
      });
    });

    notifyListeners();
  }

  trackRideVars() {
    if (orderState == 2) {
      print("llllllllllllllllllllllllllllllllllllllllllllllllllllllll");
      print(busToPickUp());
      print(busOnRoute!.speed);
      var temp = ((busToPickUp() / 1000) / busOnRoute!.speed) * 60;
      if ((temp - timeToPickUp).abs() > 2) {
        timeToPickUp = temp.ceil() < 30 ? temp.ceil() : 30;
      }
    } else if (orderState == 4) {
      var temp = ((busToDropOff() / 1000) / busOnRoute!.speed) * 60;
      if ((temp - timeToDropOff).abs() > 2) {
        timeToDropOff = temp.ceil() < 30 ? temp.ceil() : 30;
      }
    }
    notifyListeners();
  }

  trackRideState() async {
    if (orderState == 2 && busToPickUp() < 30) {
      // Waiting - Arrived
      orderState = 3;
    } else if (orderState == 3 && checkIsOnBus()) {
      // Arrived - Board
      orderState = 4;
      ride!.status = "enRoute";
      await _dbService.updateRide(ride!);
    } else if (orderState == 4 && busToDropOff() < 30) {
      // Board - Dropoff
      orderState = 5;
      ride!.status = "dropOff";
      await _dbService.updateRide(ride!);
    } else if (orderState == 5 && checkIsDroppedOff()) {
      orderState == 6;
    }

    notifyListeners();
  }

  completeRide() async {
    orderState = 1;
    pickUpPointController.text = "";
    dropOffPointController.text = "";
    markers = {};
    polylines = {};
    ride!.status = "completed";
    await _dbService.updateRide(ride!);
    notifyListeners();
  }

  onGoPressed() async {
    try {
      if (pickUpPointController.text != "" &&
          dropOffPointController.text != "") {
        print("Go pressed............................");
        busOnRoute =
            await _dbService.findBusOnRoute(pickupPoint!, dropOffPoint!);

        if (busOnRoute == null) {
          // snackBarMessage = "No active bus on route";
          loading = false;
          notifyListeners();
          return false;
        }
        markers = {};
        await createRide();

        listenToBus();

        addMarker(
            LatLng(pickupPoint!.location.latitude,
                pickupPoint!.location.longitude),
            "Pick up");
        addMarker(
            LatLng(dropOffPoint!.location.latitude,
                dropOffPoint!.location.longitude),
            "Drop off");

        addRoutePolyline();

        gotoLocation(
            pickupPoint!.location.latitude, pickupPoint!.location.longitude);
        setOrderState(2);

        loading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print(e.toString());
      loading = false;
      notifyListeners();
      return false;
    }
  }

  createRide() async {
    // String userID = AuthService().gUser.id;
    print("Creating new ride...");
    rideUid = uuid.v1();
    ride = Ride(
        uid: rideUid!,
        startPointID: pickupPoint!.uid,
        stopPointID: dropOffPoint!.uid,
        userID: userID!,
        busID: busOnRoute!.uid,
        status: 'pickup',
        date: Timestamp.now(),
        fare: 1.30,
        rating: 5.0);
    print(ride);
    await _dbService.addRide(ride!);
    notifyListeners();
  }

  cancelTrip() async {
    orderState = 1;
    pickUpPointController.text = "";
    dropOffPointController.text = "";
    markers = {};
    polylines = {};
    ride!.status = 'cancelled';
    await _dbService.updateRide(ride!);
    notifyListeners();
  }

  double busToPickUp() {
    return _coordinateDistance(
            pickupPoint!.location.latitude,
            pickupPoint!.location.longitude,
            busOnRoute!.location.latitude,
            busOnRoute!.location.longitude) *
        1000;
  }

  double userToPickUp() {
    return _coordinateDistance(
            pickupPoint!.location.latitude,
            pickupPoint!.location.longitude,
            userLocation!.latitude,
            userLocation!.longitude) *
        1000;
  }

  double busToDropOff() {
    return _coordinateDistance(
            dropOffPoint!.location.latitude,
            dropOffPoint!.location.longitude,
            busOnRoute!.location.latitude,
            busOnRoute!.location.longitude) *
        1000;
  }

  bool checkIsBoarded() {
    double busToPickup = _coordinateDistance(
            pickupPoint!.location.latitude,
            pickupPoint!.location.longitude,
            busOnRoute!.location.latitude,
            busOnRoute!.location.longitude) *
        1000; //Convert to meters

    double userToBus = _coordinateDistance(
            pickupPoint!.location.latitude,
            pickupPoint!.location.longitude,
            userLocation!.latitude,
            userLocation!.longitude) *
        1000; //Convert to meters

    print("User to bus: $userToBus");
    print("Bus to pickup: $busToPickup");
    if (busToPickup < 15 && userToBus < 15) {
      return true;
    }
    return false;
  }

  bool checkIsOnBus() {
    double userToBus = _coordinateDistance(
            busOnRoute!.location.latitude,
            busOnRoute!.location.longitude,
            userLocation!.latitude,
            userLocation!.longitude) *
        1000;

    double spdDiff = (userLocation!.speed! - busOnRoute!.speed).abs();

    if (userToBus < 15 && spdDiff < 10) {
      return true;
    }

    return false;
  }

  bool checkIsDroppedOff() {
    double userToBus = _coordinateDistance(
            busOnRoute!.location.latitude,
            busOnRoute!.location.longitude,
            userLocation!.latitude,
            userLocation!.longitude) *
        1000;

    double userToPickup = _coordinateDistance(
            pickupPoint!.location.latitude,
            pickupPoint!.location.longitude,
            userLocation!.latitude,
            userLocation!.longitude) *
        1000;

    if (userToBus > 20 && userToPickup < 30) {
      return true;
    }

    return false;
  }

  addRoutePolyline() async {
    tripRoute = await _dbService.getRoute(busOnRoute!.routeID);

    LatLng pickupPointLatLng =
        LatLng(pickupPoint!.location.latitude, pickupPoint!.location.longitude);
    LatLng dropOffPointLatLng = LatLng(
        dropOffPoint!.location.latitude, dropOffPoint!.location.longitude);

    // addMarker(pickupPointLatLng, Icon(Icons.abc), pickupPoint!.name);
    // addMarker(dropOffPointLatLng, Icon(Icons.abc), dropOffPoint!.name);

    createPolylines(
      pickupPointLatLng,
      dropOffPointLatLng,
      appColors.lightGreen,
    );

    // print("TripRoute is: ... $tripRoute");
    // print("All stops: $allStops");

    // List routeStops = tripRoute!.stopIDs;
    // for (var i = 0; i < routeStops.length; i++) {
    //   Stop? currentStop =
    //       allStops.where((element) => element.uid == routeStops[i]).first;
    //   Stop? nextStop;
    //   if (i == routeStops.length - 1) {
    //     nextStop =
    //         allStops.where((element) => element.uid == routeStops[0]).first;
    //   } else {
    //     nextStop =
    //         allStops.where((element) => element.uid == routeStops[i + 1]).first;
    //   }

    //   LatLng currentStopLatLng =
    //       LatLng(currentStop.location.latitude, currentStop.location.longitude);
    //   LatLng nextStopLatLng =
    //       LatLng(nextStop.location.latitude, nextStop.location.longitude);
    //   print(nextStopLatLng);

    //   addMarker(currentStopLatLng, Icon(Icons.abc), "$i: ${currentStop.name}");

    //   createPolylines(
    //     currentStopLatLng,
    //     nextStopLatLng,
    //     appColors.lightGreen,
    //   );
    //   // "${currentStop.name}-${nextStop.name}");
    // }

    // print("Map Polylines: $polylines");
  }
}
