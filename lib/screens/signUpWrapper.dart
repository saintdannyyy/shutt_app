import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shutt_app/providers/authProvider.dart';
import 'package:shutt_app/screens/signUp1.dart';
import 'package:shutt_app/screens/home.dart';
import 'package:shutt_app/screens/signUp2.dart';
import 'package:shutt_app/screens/signUp3.dart';
import 'package:shutt_app/services/authService.dart';

class signUpWrapper extends StatelessWidget {
  const signUpWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int signUpState = Provider.of<AuthProvider>(context).signUpState;

    if (signUpState == 1) {
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
