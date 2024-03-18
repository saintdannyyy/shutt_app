import 'package:flutter/material.dart';
import 'package:shutt_app/styles/colors.dart';
import 'package:shutt_app/widgets/rideInfoItem.dart';

class RideInfo1 extends StatelessWidget {
  final String promptText;
  final String promptValue;
  final String infoText;
  final String pickUpPointText;
  final String dropOffPointText;
  final String busRegistrationNumber;
  final double price;
  const RideInfo1(
      {Key? key,
      required this.promptText,
      required this.promptValue,
      required this.infoText,
      required this.price,
      required this.pickUpPointText,
      required this.dropOffPointText,
      required this.busRegistrationNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, bottom: 16, left: 16),
      child: Material(
        color: appColors.appWhite,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.bus_alert,
                        size: 32,
                        color: appColors.lightGreen,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Text(
                        "${busRegistrationNumber.substring(0, 2)} ${busRegistrationNumber.substring(2, 6)} ${busRegistrationNumber.substring(6)}",
                        style: const TextStyle(
                            fontSize: 28,
                            color: appColors.textBlack,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    infoText,
                    style: const TextStyle(
                        fontSize: 16,
                        color: appColors.lightGreen,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(
                color: appColors.green,
              ),
              RideInfoItem(
                keyText: promptText,
                valueText: promptValue,
                valueWeight: FontWeight.bold,
                valueColor: appColors.textBlack,
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
                valueColor: appColors.textBlack,
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
                valueColor: appColors.textBlack,
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
                    style: TextStyle(color: appColors.green, fontSize: 14),
                  ),
                  Row(
                    children: [
                      const Text("GHc",
                          style: TextStyle(
                              color: appColors.darkGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(price.toStringAsFixed(2),
                          style: const TextStyle(
                              color: appColors.darkGreen,
                              fontSize: 28,
                              fontWeight: FontWeight.bold))
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
