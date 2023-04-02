import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shutt_app/services/authService.dart';

class AuthProvider extends ChangeNotifier {
  TextEditingController phoneNumController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String verificationId = "";
  bool signUpComplete = false;
  int _signUpState = 1;

  User? _user;

  void setUser(user) {
    _user = user;
    notifyListeners();
  }

  get user {
    return _user;
  }

  get signUpState {
    return _signUpState;
  }

  set signUpState(state) {
    _signUpState = state;
    notifyListeners();
  }

  setSignUpComplete(bool state) {
    signUpComplete = state;
    notifyListeners();
  }

  // Edit users info in signUp 3
  editDetails() async {
    await AuthService().editCredentials(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim()); // notifyListeners();
  }
}
