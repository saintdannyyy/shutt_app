import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shutt_app/models/Bus.dart';
import 'package:shutt_app/models/RideAlt.dart';
import 'package:shutt_app/models/Stop.dart';
import 'package:shutt_app/screens/rideHistory.dart';

import '../models/Ride.dart';
import '../models/BusRoute.dart';

class dbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // CRUD for Stops
  addStop(Stop stop) async {
    await _firestore.collection("stops").add(stop.toMap());
  }

  updateStop(Stop stop) async {
    await _firestore.collection("stops").doc(stop.uid).update(stop.toMap());
  }

  Future<void> deleteStop(String documentId) async {
    await _firestore.collection("stops").doc(documentId).delete();
  }

  Future<List<Stop>> retrieveStops() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection("stops").get();

    List<Stop> stops = snapshot.docs
        .map((docSnapshot) => Stop.fromDocumentSnapshot(docSnapshot))
        .toList();

    return stops;
  }

  // CRUD for buses
  Future<List<Bus>> retrieveBuses() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection("buses").get();

    List<Bus> buses = snapshot.docs
        .map((docSnapshot) => Bus.fromDocumentSnapshot(docSnapshot))
        .toList();

    return buses;
  }

  findBusOnRoute(Stop pickUpPoint, Stop dropOffPoint) async {
    // Add new parameter for user location
    QuerySnapshot<Map<String, dynamic>> routeSnapshot = await _firestore
        .collection("routes")
        .where("stopIDs", arrayContains: pickUpPoint.uid)
        .get();

    List<BusRoute> routes = routeSnapshot.docs
        .map((docSnapshot) => BusRoute.fromDocumentSnapshot(docSnapshot))
        .toList();
    // print("Routes: $routes");

    List<Bus> busesOnRoute = [];

    for (var route in routes) {
      QuerySnapshot<Map<String, dynamic>> busSnapshot = await _firestore
          .collection("buses")
          .where("routeID", isEqualTo: route.uid)
          .where("isActive", isEqualTo: true)
          .get();
      print("Bus snapshot: ${busSnapshot.docs.length}");

      List<Bus> busesOnCurrentRoute = busSnapshot.docs
          .map((docSnapshot) => Bus.fromDocumentSnapshot(docSnapshot))
          .toList();
      busesOnRoute = busesOnRoute + busesOnCurrentRoute;
      print("Buses on Route: $busesOnRoute");

      if (routes.indexOf(route) == routes.length - 1) {
        return busesOnRoute[0];
      }
    }

    // Add change to get active bus with shortest distance to user
    if (busesOnRoute.isNotEmpty) {
      return busesOnRoute[0];
    }
  }

  Stream<List<Bus>> getBuses() {
    return _firestore.collection("buses").snapshots().map(
        (event) => event.docs.map((e) => Bus.fromDocumentSnapshot(e)).toList());
  }

  Stream<QuerySnapshot> busStream() {
    CollectionReference reference = _firestore.collection("buses");
    return reference.snapshots();
  }

  trackBus(Bus bus) {}

  addRide(Ride ride) async {
    await _firestore.collection("rides").doc(ride.uid).set(ride.toMap());
  }

  updateRide(Ride ride) async {
    await _firestore.collection("rides").doc(ride.uid).update(ride.toMap());
  }

  getRoute(String routeID) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection("routes").doc(routeID).get();

    BusRoute route = BusRoute.fromDocumentSnapshot(snapshot);

    return route;
  }

  getRideHistory() async {
    List<RideAlt> rideHistory = [];
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

      QuerySnapshot<Map<String, dynamic>> rideSnapshot = await _firestore
          .collection("rides")
          .where("userID", isEqualTo: userId)
          .get();
      List<Ride> rides = rideSnapshot.docs
          .map((docSnapshot) => Ride.fromDocumentSnapshot(docSnapshot))
          .toList();

      QuerySnapshot<Map<String, dynamic>> stopSnapshot =
          await _firestore.collection("stops").get();

      List<Stop> stops = stopSnapshot.docs
          .map((docSnapshot) => Stop.fromDocumentSnapshot(docSnapshot))
          .toList();

      for (Ride ride in rides) {
        String rideStartPoint = stops
            .where((stop) => stop.uid == ride.startPointID)
            .toList()
            .first
            .name;

        String rideStopPoint = stops
            .where((stop) => stop.uid == ride.stopPointID)
            .toList()
            .first
            .name;

        RideAlt newRide = RideAlt(
            uid: ride.uid,
            startPoint: rideStartPoint,
            stopPoint: rideStopPoint,
            userID: ride.userID,
            busID: ride.busID,
            status: ride.status,
            fare: ride.fare,
            date: ride.date,
            rating: ride.rating);

        rideHistory.add(newRide);
      }
    } catch (e) {
      print(e.toString());
    }
    // print(rideHistory);

    return rideHistory;
  }
}
