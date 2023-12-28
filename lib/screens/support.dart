import 'package:flutter/material.dart';
import 'package:shutt_app/styles/colors.dart';
import 'package:shutt_app/widgets/NavigationDrawer.dart' as nav;

class Support extends StatefulWidget {
  const Support({Key? key}) : super(key: key);

  @override
  State<Support> createState() => _SettingsState();
}

class _SettingsState extends State<Support> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Support"),
        foregroundColor: appColors.darkGreen,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: appColors.darkGreen),
      ),
      drawer: const nav.NavigationDrawer(),
      body: const Center(
        child: Text("Support Screen"),
      ),
    );
  }
}
