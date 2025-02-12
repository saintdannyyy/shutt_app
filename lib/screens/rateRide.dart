import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shutt_app/providers/mapProvider.dart';
import 'package:shutt_app/services/dbService.dart';
import 'package:shutt_app/styles/colors.dart';
import 'package:shutt_app/widgets/greenButton.dart';
import 'package:shutt_app/widgets/headingText.dart' as headingText;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateRide extends StatefulWidget {
  const RateRide({Key? key}) : super(key: key);

  @override
  State<RateRide> createState() => _RateRideState();
}

class _RateRideState extends State<RateRide> {
  double _ratingValue = 0;
  TextEditingController commentController = TextEditingController();
  int maxLines = 7;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.close,
          color: appColors.darkGreen,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<MapProvider>(
        builder: (context, map, child) => Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const headingText.HeadingText(
                      text: "How was your Trip?",
                      alignment: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    RatingBar(
                        initialRating: 0,
                        glow: false,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        ratingWidget: RatingWidget(
                            full: const Icon(Icons.star,
                                size: 60, color: appColors.green),
                            half: const Icon(
                              Icons.star_half,
                              size: 60,
                              color: appColors.green,
                            ),
                            empty: const Icon(
                              Icons.star_outline,
                              size: 60,
                              color: appColors.green,
                            )),
                        onRatingUpdate: (value) {
                          setState(() {
                            map.rating = value;
                          });
                        }),
                    const SizedBox(
                      height: 24,
                    ),
                    Container(
                      height: maxLines * 24,
                      child: TextField(
                        controller: commentController,
                        keyboardType: TextInputType.multiline,
                        maxLines: maxLines * 24,
                        decoration: const InputDecoration(
                            fillColor: appColors.offWhite,
                            border: InputBorder.none,
                            filled: true,
                            hintText: "Leave  a comment...",
                            hintStyle: TextStyle(color: appColors.textGrey)),
                      ),
                    ),
                  ],
                )),
                greenButton(
                  label: "Submit",
                  onPressed: () async {
                    await map.completeRide();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
