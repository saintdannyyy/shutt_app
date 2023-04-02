import 'package:awesome_icons/awesome_icons.dart';
import "package:flutter/material.dart";
import 'package:shutt_app/services/dbService.dart';
import 'package:shutt_app/styles/colors.dart';
import 'package:shutt_app/widgets/customTextField.dart';
import 'package:provider/provider.dart';
import 'package:shutt_app/providers/mapProvider.dart';
import 'package:shutt_app/models/Stop.dart';

class LocationSet extends StatefulWidget {
  const LocationSet({Key? key}) : super(key: key);

  @override
  State<LocationSet> createState() => LocationSetState();
}

class LocationSetState extends State<LocationSet> {
  TextEditingController pickupPoint = TextEditingController();
  TextEditingController dropoffPoint = TextEditingController();

  late FocusNode pickUpFocusNode;
  late FocusNode dropOffFocusNode;

  List<Stop> stops = [];
  List<Stop> filteredStops = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pickUpFocusNode = FocusNode();
    dropOffFocusNode = FocusNode();

    pickUpFocusNode.requestFocus();
    // stops = Provider.of<MapProvider>(context, listen: false).getStops();
    retrieveStops();
  }

  retrieveStops() async {
    List<Stop> temp = await context.read<dbService>().retrieveStops();
    // print(temp);
    setState(() {
      stops = temp;
      filteredStops = temp;
    });
  }

  filterStops(String text) {
    List<Stop> temp = stops
        .where((stop) => stop.name.toLowerCase().contains(text.toLowerCase()))
        .toList();
    // print("Temp is $temp");
    setState(() {
      filteredStops = temp;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    pickUpFocusNode.dispose();
    dropOffFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    Provider.of<MapProvider>(context, listen: false).getAllStops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: appColors.green,
        backgroundColor: Colors.transparent,
        // leading: const Icon(
        // Icons.arrow_back,
        // color: appColors.green,
        // ),
        elevation: 0,
      ),
      body: Consumer<MapProvider>(
        builder: (context, map, child) => Column(children: [
          Material(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 12.0, left: 12, bottom: 16, right: 12),
              child: Column(
                children: [
                  TextField(
                    onChanged: (text) {
                      filterStops(text);
                    },
                    focusNode: pickUpFocusNode,
                    controller: map.pickUpPointController,
                    onTap: () {
                      map.locationTextState = "pickUp";
                    },
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        fillColor: appColors.offWhite,
                        filled: true,
                        hintText: "Pickup point",
                        hintStyle: TextStyle(color: appColors.textGrey)),
                  ),
                  TextField(
                    onChanged: (text) {
                      filterStops(text);
                    },
                    focusNode: dropOffFocusNode,
                    controller: map.dropOffPointController,
                    onTap: () {
                      map.locationTextState = "dropOff";
                    },
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        fillColor: appColors.offWhite,
                        filled: true,
                        hintText: "Dropoff point",
                        hintStyle: TextStyle(color: appColors.textGrey)),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Flexible(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: filteredStops.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                      onTap: () {
                        if (map.locationTextState == 'pickUp') {
                          map.pickUpPointController.text =
                              filteredStops[index].name;
                          map.pickupPoint = filteredStops[index];

                          pickUpFocusNode.unfocus();
                          dropOffFocusNode.requestFocus();
                          map.locationTextState = 'dropOff';

                          dropOffFocusNode.requestFocus();
                        } else if (map.locationTextState == 'dropOff') {
                          map.dropOffPointController.text =
                              filteredStops[index].name;
                          map.dropOffPoint = filteredStops[index];

                          map.locationTextState = '';
                        }

                        if (map.pickUpPointController.text != "" &&
                            map.dropOffPointController.text != "" &&
                            map.locationTextState == "") {
                          Navigator.pop(context);
                        }
                      },
                      leading: const Icon(FontAwesomeIcons.mapMarkerAlt),
                      title: Text(filteredStops[index].name));
                }),
          ),
        ]),
      ),
    );
  }
}
