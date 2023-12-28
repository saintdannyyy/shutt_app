import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shutt_app/models/RideAlt.dart';
import 'package:shutt_app/services/dbService.dart';
import 'package:shutt_app/styles/colors.dart';
import 'package:shutt_app/widgets/NavigationDrawer.dart' as nav;
import 'package:shutt_app/widgets/historyCard.dart';

class RideHistory extends StatefulWidget {
  const RideHistory({Key? key}) : super(key: key);

  @override
  State<RideHistory> createState() => _SettingsState();
}

class _SettingsState extends State<RideHistory> {
  List<int> history = [1, 2, 3, 4, 5, 6, 7];

  List<RideAlt> rideHistory = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRideHistory();
  }

  getRideHistory() async {
    List<RideAlt> temp = await context.read<dbService>().getRideHistory();
    print("6666666666666666666666666666666666666666666666666666666");
    print(temp);
    setState(() {
      rideHistory = temp;
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ride History"),
        foregroundColor: appColors.green,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: appColors.green),
      ),
      drawer: const nav.NavigationDrawer(),
      body: SafeArea(
          child: rideHistory.isEmpty
              ? const Center(
                  child: Text(
                    "No Ride History. Try going on a few rides",
                    style: TextStyle(fontSize: 14, color: appColors.textGrey),
                  ),
                )
              : Column(
                  children: [
                    const Divider(),
                    Flexible(
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: rideHistory.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                HistoryCard(
                                    date: rideHistory[index].date,
                                    pickup: rideHistory[index].startPoint,
                                    dropoff: rideHistory[index].stopPoint,
                                    status: rideHistory[index].status),
                                const Divider()
                              ],
                            );
                          }),
                    )

                    // : const Center(
                    //     child: Text("No Ride History. Try going on a few rides"),
                    //   )
                  ],
                )),
    );
  }
}
