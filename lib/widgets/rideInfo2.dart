import 'package:flutter/material.dart';
import 'package:shutt_app/styles/colors.dart';
import 'package:shutt_app/widgets/rideInfoItem.dart';

class RideInfo2 extends StatelessWidget {
  final String promptText;
  final String pickUpPointText;
  final String dropOffPointText;
  final String busRegistrationNumber;
  final double price;
  const RideInfo2(
      {Key? key,
      required this.promptText,
      required this.pickUpPointText,
      required this.dropOffPointText,
      required this.price,
      required this.busRegistrationNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        color: appColors.appWhite,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bus_alert,
                    size: 32,
                    color: appColors.green,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    busRegistrationNumber,
                    style: const TextStyle(
                        fontSize: 28,
                        color: appColors.green,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(
                color: appColors.green,
              ),
              Text(
                promptText,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: appColors.green),
              ),
              const SizedBox(
                height: 12,
              ),
              RideInfoItem(
                keyText: "Pickup point: ",
                valueText: pickUpPointText.length > 30
                    ? "${pickUpPointText.substring(0, 30)}..."
                    : pickUpPointText,
                valueSize: 16,
                valueWeight: FontWeight.w300,
                valueColor: appColors.darkGreen,
              ),
              const SizedBox(
                height: 12,
              ),
              RideInfoItem(
                keyText: "Dropoff point: ",
                valueText: dropOffPointText.length > 30
                    ? "${dropOffPointText.substring(0, 30)}..."
                    : dropOffPointText,
                valueSize: 16,
                valueWeight: FontWeight.w300,
                valueColor: appColors.darkGreen,
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Fare:",
                    style: TextStyle(color: appColors.green, fontSize: 12),
                  ),
                  Row(
                    children: [
                      const Text("GHc",
                          style: TextStyle(
                              color: appColors.darkGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.w500)),
                      Text(price.toStringAsFixed(2),
                          style: const TextStyle(
                              color: appColors.darkGreen,
                              fontSize: 28,
                              fontWeight: FontWeight.normal))
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
