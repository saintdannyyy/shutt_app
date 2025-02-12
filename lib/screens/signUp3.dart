import 'package:firebase_custom_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shutt_app/providers/authProvider.dart' as custom_auth;
import 'package:shutt_app/screens/authWrapper.dart';
import 'package:shutt_app/widgets/customTextField.dart';
import 'package:shutt_app/widgets/greenButton.dart';
import 'package:shutt_app/widgets/headingText.dart';
import 'package:shutt_app/styles/colors.dart';

import '../services/authService.dart';

class SignUp3 extends StatefulWidget {
  const SignUp3({Key? key}) : super(key: key);

  @override
  State<SignUp3> createState() => _SignUp3State();
}

class _SignUp3State extends State<SignUp3> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const Icon(
            Icons.arrow_back,
            color: appColors.green,
          )),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Consumer<custom_auth.AuthProvider>(
          builder: (context, auth, child) => Column(
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeadingText(text: "Finish Registration"),
                  const SizedBox(height: 6),
                  const Text(
                    "Please enter the following details to complete the registration process",
                    textAlign: TextAlign.left,
                    style: TextStyle(color: appColors.textGrey),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  CustomTextField(
                      onPressed: () {},
                      textController: custom_auth.firstNameController,
                      hintText: "First Name"),
                  const SizedBox(
                    height: 12,
                  ),
                  CustomTextField(
                      onPressed: () {},
                      textController: custom_auth.lastNameController,
                      hintText: "Last Name"),
                  const SizedBox(
                    height: 12,
                  ),
                  CustomTextField(
                    onPressed: () {},
                    textController: custom_auth.emailController,
                    hintText: "Email",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              )),
              greenButton(
                label: "Complete sign up",
                onPressed: () async {
                  // await auth.editDetails();

                  if (custom_auth.firstNameController.text.trim() != "" &&
                      custom_auth.lastNameController.text.trim() != "" &&
                      custom_auth = auth.emailController.text.trim() != "") {
                      await context.read<AuthService>().editCredentials(
                        firstName: custom_auth.firstNameController.text.trim(),
                        lastName: custom_auth.lastNameController.text.trim(),
                        email: custom_auth.emailController.text.trim());
                    custom_auth.setSignUpComplete(true);
                    custom_auth.signUpState = 1;
                  } else {
                    var snackBar = const SnackBar(
                        content: Text("All fields must be filled correctly"));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
