import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shutt_app/styles/colors.dart';

class HistoryCard extends StatelessWidget {
  final Timestamp date;
  final String pickup;
  final String dropoff;
  final String status;
  const HistoryCard(
      {Key? key,
      required this.date,
      required this.pickup,
      required this.dropoff,
      required this.status})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${date.toDate().day}/${date.toDate().month}/${date.toDate().year}",
            style: const TextStyle(
                fontSize: 16,
                color: appColors.lightGreen,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              const Text(
                "Pickup: ",
                style: TextStyle(
                    fontSize: 16,
                    color: appColors.green,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                pickup,
                style: const TextStyle(
                  fontSize: 16,
                  color: appColors.textBlack,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              const Text(
                "Dropoff: ",
                style: TextStyle(
                    fontSize: 16,
                    color: appColors.green,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                dropoff,
                style: const TextStyle(
                  fontSize: 16,
                  color: appColors.textBlack,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                "Status: ",
                style: TextStyle(
                    fontSize: 14,
                    color: appColors.green,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                status,
                style: const TextStyle(
                  fontSize: 14,
                  color: appColors.textBlack,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
