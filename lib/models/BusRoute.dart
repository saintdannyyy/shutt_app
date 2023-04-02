import 'package:cloud_firestore/cloud_firestore.dart';

class BusRoute {
  String uid;
  String name;
  List stopIDs;

  BusRoute({required this.uid, required this.name, required this.stopIDs});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'stopIDs': stopIDs,
    };
  }

  BusRoute.fromMap(Map<String, dynamic> map)
      : uid = map["uid"],
        name = map["name"],
        stopIDs = map["stopIDs"];

  BusRoute.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : uid = doc.id,
        name = doc.data()!["name"],
        stopIDs = doc.data()!["stopIDs"];
}
