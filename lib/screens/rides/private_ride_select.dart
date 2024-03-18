import 'package:flutter/material.dart';
import 'package:shutt_app/widgets/NavigationDrawer.dart' as nav;

class PrivateRideSelect extends StatelessWidget {
  const PrivateRideSelect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available shuttles"),
      ),
      drawer: const nav.NavigationDrawer(),
      body: const Center(
        child: Text(
          "No Private shuttles available",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
