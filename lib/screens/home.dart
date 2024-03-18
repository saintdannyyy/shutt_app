import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shutt_app/providers/mapProvider.dart';
import 'package:shutt_app/styles/colors.dart';
import 'package:shutt_app/widgets/NavigationDrawer.dart' as nav;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shutt_app/widgets/rideInfo1.dart';
import 'package:shutt_app/widgets/rideInfo2.dart';
import 'package:shutt_app/widgets/rideOptions.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../models/Bus.dart';
import '../services/dbService.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  // static const _initialCameraPosition =
  //     CameraPosition(target: LatLng(5.6506, -0.1962), zoom: 15.5);
  GoogleMapController? _googleMapController;

  TextEditingController pickupController = TextEditingController();
  TextEditingController dropoffController = TextEditingController();

  Location location = Location();
  CameraPosition? initialCameraPosition;
  bool cameraPositionSet = true;

  List<Bus> buses = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserLocation();
    //getUserCurrentLocation();
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value){
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR"+error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  getUserLocation() async {
    try {
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
      LocationData userPosition = await location.getLocation();
      print("loading..........");
      setState(() {
        initialCameraPosition = CameraPosition(
            target: LatLng(userPosition.latitude ?? 5.6506,
                userPosition.longitude ?? -0.1962),
            zoom: 15.5);

        cameraPositionSet = true;
      });

      getUserCurrentLocation();


    } catch (e) {
      print(e.toString());
    }
  }

  addBusMarkers() async {
    List<Bus> temp = await context.read<dbService>().retrieveBuses();
    print(temp);
    // setState(() {
    //   buses = temp;
    // });
    for (Bus bus in temp) {
      LatLng latLng = LatLng(bus.location.latitude, bus.location.longitude);
      await Provider.of<MapProvider>(context, listen: false)
          .addMarker(latLng, bus.registrationNumber);
    }
  }

  @override
  void didChangeDependencies() {
   
    super.didChangeDependencies();
    // Provider.of<MapProvider>(context).animateCamera();
  }

  @override
  void dispose() {

    _googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const nav.NavigationDrawer(),
      key: scaffoldKey,
      body: Consumer<MapProvider>(
        builder: (context, map, child) => Stack(
          children: [
            cameraPositionSet && !map.loading
                ? GoogleMap(
                    // initialCameraPosition: initialCameraPosition!,
                    initialCameraPosition: const CameraPosition(
                        target: LatLng(5.6506, -0.1962), zoom: 14),
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    markers: map.markers,
                    myLocationEnabled: true,
                    onMapCreated: map.onMapCreated,
                    polylines: map.polylines,
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MaterialButton(
                            padding: const EdgeInsets.all(12),
                            shape: const CircleBorder(),
                            color: appColors.appWhite,
                            elevation: 2,
                            child: const Icon(
                              Icons.menu,
                              color: appColors.green,
                            ),
                            onPressed: () =>
                                scaffoldKey.currentState?.openDrawer(),
                          ),
                          MaterialButton(
                            color: appColors.appWhite,
                            elevation: 2,
                            padding: const EdgeInsets.all(12),
                            shape: const CircleBorder(),
                            child: const Icon(Icons.my_location,
                                color: appColors.green),
                            onPressed: () async {
                              await map.animateCamera();
                              //await getUserLocation();
                            },
                          )
                        ]),
                    map.orderState == 1 // Order State 1 = Making order
                        ? RideOptions(
                            pickupController: map.pickUpPointController,
                            dropoffController: map.dropOffPointController,
                            goPressed: () async {
                              map.loading = true;
                              bool busOnRoute = await map.onGoPressed();
                              if (!busOnRoute) {
                                var snackBar = const SnackBar(
                                    content: Text("No active bus on route"));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            },
                          )
                        : map.orderState == 2 // Order State 2 = Waiting for bus
                            ? Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        MaterialButton(
                                          elevation: 0,
                                          // minWidth: double.infinity,
                                          color: appColors.lightGreen,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          onPressed: () {
                                            map.cancelTrip();
                                          },
                                          child: const Text(
                                            "Cancel",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: appColors.appWhite),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  RideInfo1(
                                    infoText: "Pickup",
                                    promptText: "Arrival time:",
                                    promptValue:
                                        "${map.timeToPickUp.toString()} mins",
                                    price: 3.00,
                                    pickUpPointText:
                                        map.pickupPoint?.name ?? "",
                                    dropOffPointText:
                                        map.dropOffPoint?.name ?? "",
                                    busRegistrationNumber:
                                        map.busOnRoute?.registrationNumber ??
                                            "",
                                  )
                                ],
                              )
                            : map.orderState ==
                                    3 // Order State 3 = Bus arrived at pickup
                                ? Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            MaterialButton(
                                              elevation: 0,
                                              // minWidth: double.infinity,
                                              color: appColors.lightGreen,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                              onPressed: () {
                                                map.cancelTrip();
                                              },
                                              child: const Text(
                                                "Cancel",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: appColors.appWhite),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      RideInfo2(
                                        price: 1.50,
                                        busRegistrationNumber: map.busOnRoute
                                                ?.registrationNumber ??
                                            "",
                                        pickUpPointText:
                                            map.pickupPoint?.name ?? "",
                                        dropOffPointText:
                                            map.dropOffPoint?.name ?? "",
                                        promptText: "Bus Has Arrived",
                                      ),
                                    ],
                                  )
                                : map.orderState == 4 // Order State 4 = On bus
                                    ? Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                MaterialButton(
                                                  elevation: 0,
                                                  // minWidth: double.infinity,
                                                  color: appColors.lightGreen,
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                  onPressed: () {
                                                    map.cancelTrip();
                                                  },
                                                  child: const Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color:
                                                            appColors.appWhite),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          RideInfo1(
                                            infoText: "Dropoff",
                                            promptText: "Arrival Time",
                                            promptValue:
                                                "${map.timeToDropOff.toString()} mins",
                                            price: 1.50,
                                            pickUpPointText:
                                                map.pickupPoint!.name,
                                            dropOffPointText:
                                                map.dropOffPoint!.name,
                                            busRegistrationNumber: map
                                                .busOnRoute!.registrationNumber,
                                          ),
                                        ],
                                      )
                                    : map.orderState ==
                                            5 // Order State 5 = Bus arrived at drop off
                                        ? RideInfo2(
                                            price: 1.50,
                                            busRegistrationNumber: map
                                                    .busOnRoute
                                                    ?.registrationNumber ??
                                                "",
                                            pickUpPointText:
                                                map.pickupPoint?.name ?? "",
                                            dropOffPointText:
                                                map.dropOffPoint?.name ?? "",
                                            promptText: "You have Arrived",
                                          )
                                        : const SizedBox(
                                            height: 12,
                                          )
                  ],
                ),
              ),
            ),
            // Positioned(
            //     top: 24,
            //     right: 24,
            //     child: )
          ],
        ),
      ),
    );
  }

  onGoPressed(MapProvider map) async {
    // await context.watch<dbService>().trackBus(bus);
  }
}
