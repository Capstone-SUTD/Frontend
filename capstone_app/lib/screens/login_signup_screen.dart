import 'package:flutter/material.dart';
import '../common/login_widget.dart';

class LoginSignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login/Sign Up'),
      ),
      body: LoginSignupWidget(),
    );
  }
}
