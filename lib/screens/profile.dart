import 'package:flutter/material.dart';
import 'package:shutt_app/styles/colors.dart';
import 'package:shutt_app/widgets/NavigationDrawer.dart' as nav;

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: appColors.darkGreen),
        elevation: 0,
      ),
      drawer: const nav.NavigationDrawer(),
      body: const Center(child: Text("Profile Screen")),
    );
  }
}
