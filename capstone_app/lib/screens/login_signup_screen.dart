import 'package:flutter/material.dart';
import '../common/login_widget.dart';
// ignore: unused_import
import 'dashboard_screen.dart';

// ignore: use_key_in_widget_constructors
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
