import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shutt_app/providers/mapProvider.dart';
import 'package:shutt_app/screens/homeWrapper.dart';
import 'package:shutt_app/screens/signUp1.dart';
import 'package:shutt_app/screens/signUp2.dart';
import 'package:shutt_app/screens/signUp3.dart';

import '../providers/authProvider.dart' as custom_auth;

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    bool signUpComplete = Provider.of<custom_auth.AuthProvider>(context).signUpComplete;
    int signUpState = Provider.of<custom_auth.AuthProvider>(context).signUpState;

    if (firebaseUser != null &&
            firebaseUser.displayName != null &&
            firebaseUser.displayName != "" ||
        signUpComplete == true) {
      print(firebaseUser);
      Provider.of<MapProvider>(context, listen: false).userID =
          firebaseUser?.uid ?? "fgDwVf05CrUA5SlHrrNloY82vrg1";
      return const HomeWrapper();
    } else if (signUpState == 1) {
      return const SignUp1();
    } else if (signUpState == 2) {
      return const SignUp2();
    } else if (signUpState == 3) {
      return const SignUp3();
    } else {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
  }
}
