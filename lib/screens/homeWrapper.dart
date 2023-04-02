import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shutt_app/providers/mapProvider.dart';
import 'package:shutt_app/screens/home.dart';
import 'package:shutt_app/screens/rateRide.dart';

class HomeWrapper extends StatelessWidget {
  const HomeWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int orderState = Provider.of<MapProvider>(context).orderState;

    if (orderState == 6) {
      return const RateRide();
    } else {
      return const Home();
    }
  }
}
