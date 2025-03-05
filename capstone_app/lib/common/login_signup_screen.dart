import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:capstone_app/mobile_screens/dashboard_screen.dart';


// ignore: use_key_in_widget_constructors
class LoginSignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Login/Sign Up'),
      // ),
      body: Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Placeholder for company logo
                Image.asset(
                'assets/images/logo.png',
                height: 100,
                ),
              SizedBox(height: 20),
              // Text(
              //   'Log In',
              //   style: TextStyle(
              //     fontSize: 24, 
              //     color: Colors.red,
              //     fontWeight:FontWeight.bold),
              // ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  //labelText: 'Email',
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Handle login/signup action
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
                },
                child: Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
