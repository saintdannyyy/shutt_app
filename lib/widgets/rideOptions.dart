import 'package:awesome_icons/awesome_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shutt_app/providers/mapProvider.dart';
import 'package:shutt_app/screens/rides/private_ride_select.dart';
import 'package:shutt_app/styles/colors.dart';
import 'package:shutt_app/widgets/customTextField2.dart';
import 'package:shutt_app/screens/locationSet.dart';

class RideOptions extends StatelessWidget {
  final TextEditingController pickupController;
  final TextEditingController dropoffController;
  final Function goPressed;
  const RideOptions(
      {Key? key,
      required this.pickupController,
      required this.goPressed,
      required this.dropoffController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Material(
            borderRadius: const BorderRadius.all(Radius.circular(2)),
            elevation: 1,
            child: Container(
                padding: const EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(2),
                  ),
                ),
                // color: appColors.appWhite,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 64,
                  child: Column(
                    children: [
                      CustomTextField2(
                        onPressed: () {
                          Provider.of<MapProvider>(context, listen: false)
                              .locationTextState = 'pickUp';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LocationSet(),
                            ),
                          );
                        },
                        textIcon: FontAwesomeIcons.mapMarkerAlt,
                        textController: pickupController,
                        readOnly: true,
                        hintText: "Select pick up point",
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      CustomTextField2(
                        onPressed: () {
                          Provider.of<MapProvider>(context, listen: false)
                              .locationTextState = 'dropOff';
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LocationSet()));
                        },
                        textIcon: FontAwesomeIcons.mapPin,
                        textController: dropoffController,
                        readOnly: true,
                        hintText: "Select drop off point",
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      BookPrivateButton(
                        callback: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PrivateRideSelect(),
                              ));
                        },
                      )
                    ],
                  ),
                )),
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Material(
                  elevation: 1,
                  color: appColors.appWhite,
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(appColors.appWhite)),
                    onPressed: () {},
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.clock,
                            color: appColors.green,
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Text(
                            "Depart at:",
                            style: TextStyle(color: appColors.textGrey),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            "Now",
                            style: TextStyle(color: appColors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              Expanded(
                  flex: 1,
                  child: Material(
                    elevation: 1,
                    child: TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(appColors.appWhite)),
                      onPressed: () {
                        goPressed();
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          "Go",
                          style: TextStyle(
                              color: appColors.green,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ))
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          const Material(
            elevation: 1,
            color: appColors.appWhite,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Fare:",
                      style: TextStyle(
                          color: appColors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  Row(
                    children: [
                      Text("GHC",
                          style: TextStyle(
                              color: appColors.textBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "-- --",
                        style: TextStyle(
                          color: appColors.textGrey,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class BookPrivateButton extends StatelessWidget {
  final VoidCallback callback;
  const BookPrivateButton({Key? key, required this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: appColors.green,
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Center(
          child: Text(
            "Book private rides",
            style: TextStyle(
              color: appColors.appWhite,
            ),
          ),
        ),
      ),
    );
  }
}
