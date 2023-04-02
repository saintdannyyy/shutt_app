import 'package:cloud_firestore/cloud_firestore.dart';

class RideAlt {
  String uid;
  String startPoint;
  String stopPoint;
  String userID;
  String busID;
  double fare;
  String status;
  double rating;
  Timestamp date;

  RideAlt(
      {required this.uid,
      required this.startPoint,
      required this.stopPoint,
      required this.userID,
      required this.busID,
      required this.status,
      required this.fare,
      required this.date,
      required this.rating});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'startPointID': startPoint,
      'stopPointID': stopPoint,
      'userID': userID,
      'busID': busID,
      'fare': fare,
      'date': date,
      'status': status,
      'rating': rating
    };
  }

  RideAlt.fromMap(Map<String, dynamic> map)
      : uid = map["uid"],
        startPoint = map["startPoint"],
        stopPoint = map["stopPoint"],
        userID = map["userID"],
        busID = map["busID"],
        rating = map["rating"],
        status = map["status"],
        date = map["date"],
        fare = map["fare"];

  RideAlt.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : uid = doc.id,
        startPoint = doc.data()!["startPoint"],
        stopPoint = doc.data()!["stopPoint"],
        userID = doc.data()!["userID"],
        busID = doc.data()!["busID"],
        status = doc.data()!["status"],
        rating = doc.data()!["rating"],
        date = doc.data()!["date"],
        fare = doc.data()!["fare"];
}
